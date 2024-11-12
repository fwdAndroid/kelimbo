import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:group_button/group_button.dart';
import 'package:kelimbo/screens/hiring/hiring_service.dart';
import 'package:kelimbo/utils/colors.dart';
import 'package:kelimbo/widgets/save_button.dart';

class Filters extends StatefulWidget {
  const Filters({super.key});

  @override
  State<Filters> createState() => _FiltersState();
}

class _FiltersState extends State<Filters> {
  // Filter options
  List<String> specialSituations = [
    "Precio más alto",
    "Precio más bajo",
    "Calificación más alta",
    "Calificación más baja",
    "Más trabajo realizado",
    "Menos trabajo realizado",
  ];

  List<String> selectedFilters = []; // Holds currently selected filter options
  List<String> appliedFilters = []; // Holds applied filters for list display
  final currentUserId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Ordenar Por:",
          style: GoogleFonts.inter(
              fontWeight: FontWeight.bold, fontSize: 22, color: colorBlack),
        ),
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.close)),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(left: 20, right: 20, top: 10),
            child: GroupButton(
              options: GroupButtonOptions(
                buttonWidth: 150,
                unselectedTextStyle:
                    GoogleFonts.poppins(color: colorBlack, fontSize: 11),
                selectedTextStyle:
                    GoogleFonts.poppins(color: colorWhite, fontSize: 11),
                textAlign: TextAlign.center,
                selectedBorderColor: mainColor,
                borderRadius: BorderRadius.circular(20),
              ),
              onSelected: (value, index, isSelected) {
                setState(() {
                  if (isSelected) {
                    selectedFilters.add(value); // Add to selected filters
                  } else {
                    selectedFilters.remove(value); // Remove if deselected
                  }
                });
              },
              isRadio: false, // Allows multiple selections
              buttons: specialSituations,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: 200,
              child: SaveButton(
                title: "Ordenar",
                onTap: () {
                  // Apply the selected filters
                  setState(() {
                    appliedFilters = List.from(selectedFilters);
                  });
                },
              ),
            ),
          ),
          Expanded(
            child: appliedFilters.isEmpty
                ? Center(
                    child: Text(
                      "No filters selected. Please select a filter.",
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    ),
                  )
                : StreamBuilder(
                    stream: _getFilteredQuery(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      if (snapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Text(
                            "No hay servicios disponibles para los filtros seleccionados.",
                            style: TextStyle(color: Colors.black),
                          ),
                        );
                      }
                      return ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          final DocumentSnapshot document =
                              snapshot.data!.docs[index];
                          final data = document.data() as Map<String, dynamic>;
                          final List<dynamic> favorites =
                              data['favorite'] ?? [];

                          // Check if the current user has marked this service as favorite
                          bool isFavorite = favorites.contains(currentUserId);

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (builder) => HiringService(
                                    serviceId: data['uuid'],
                                    currencyType: data['currency'],
                                    price: data['price'].toString(),
                                    userEmail: data['userEmail'],
                                    userImage: data['userImage'],
                                    userName: data['userName'],
                                    category: data['category'],
                                    totalReviews:
                                        data['totalReviews'].toString(),
                                    uuid: data['uuid'],
                                    uid: data['uid'],
                                    totalRating: data['totalRate'].toString(),
                                    title: data['title'],
                                    perHrPrice: data['pricePerHr'].toString(),
                                    photo: data['photo'],
                                    description: data['description'],
                                  ),
                                ),
                              );
                            },
                            child: Card(
                              child: Column(
                                children: [
                                  ListTile(
                                    trailing: IconButton(
                                      icon: Icon(
                                        Icons.favorite,
                                        color: isFavorite
                                            ? Colors.red
                                            : Colors.grey,
                                      ),
                                      onPressed: () async {
                                        if (isFavorite) {
                                          await FirebaseFirestore.instance
                                              .collection('services')
                                              .doc(document.id)
                                              .update({
                                            'favorite': FieldValue.arrayRemove(
                                                [currentUserId])
                                          });
                                        } else {
                                          await FirebaseFirestore.instance
                                              .collection('services')
                                              .doc(document.id)
                                              .update({
                                            'favorite': FieldValue.arrayUnion(
                                                [currentUserId])
                                          });
                                        }
                                      },
                                    ),
                                    leading: CircleAvatar(
                                      backgroundImage:
                                          NetworkImage(data['userImage']),
                                    ),
                                    title: Text(
                                      data['userName'],
                                      style: GoogleFonts.inter(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                    subtitle: Text(
                                      data['category'],
                                      style: GoogleFonts.inter(
                                          color: Color(0xff9C9EA2),
                                          fontWeight: FontWeight.w300,
                                          fontSize: 15),
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Column(
                                        children: [
                                          Text(
                                            "€" + data['price'].toString(),
                                            style: GoogleFonts.inter(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20),
                                          ),
                                          Text(
                                            data['priceType'],
                                            style: GoogleFonts.inter(
                                                color: Color(0xff9C9EA2),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 19),
                                          ),
                                        ],
                                      ),
                                      Image.asset(
                                        "assets/line.png",
                                        height: 40,
                                        width: 52,
                                      ),
                                      Column(
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.star,
                                                color: Colors.yellow,
                                              ),
                                              Text(
                                                data['totalReviews'].toString(),
                                                style: GoogleFonts.inter(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            data['ratingCount'].toString() +
                                                " Reviews",
                                            style: GoogleFonts.inter(
                                                color: Color(0xff9C9EA2),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 19),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Stream<QuerySnapshot> _getFilteredQuery() {
    final servicesCollection =
        FirebaseFirestore.instance.collection("services");

    if (appliedFilters.isEmpty) {
      // No filters applied, return an empty stream
      return Stream<QuerySnapshot>.empty();
    }

    Query query = servicesCollection;

    // Apply sorting based on the selected filters
    for (String filter in appliedFilters) {
      if (filter == "Precio más alto") {
        query = query.orderBy("price", descending: true);
      } else if (filter == "Precio más bajo") {
        query = query.orderBy("price");
      } else if (filter == "Calificación más alta") {
        query = query.orderBy("ratingCount", descending: true);
      } else if (filter == "Calificación más baja") {
        query = query.orderBy("ratingCount");
      } else if (filter == "Más trabajo realizado") {
        query = query.orderBy("totalReviews", descending: true);
      } else if (filter == "Menos trabajo realizado") {
        query = query.orderBy("totalReviews");
      }
    }

    return query.snapshots();
  }
}
