import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:group_button/group_button.dart';
import 'package:kelimbo/screens/hiring/hiring_service.dart';
import 'package:kelimbo/screens/search/location_filter.dart';
import 'package:kelimbo/utils/colors.dart';
import 'package:kelimbo/widgets/save_button.dart';

class Filters extends StatefulWidget {
  const Filters({Key? key}) : super(key: key);

  @override
  State<Filters> createState() => _FiltersState();
}

class _FiltersState extends State<Filters> {
  // List of available filter options. Make sure that the strings used here
  // match exactly with those used in the query builder below.
  List<String> specialSituations = [
    "Precio más alto",
    "Precio más bajo",
    "Calificación más alta",
    "Calificación más baja",
    "Más trabajo realizado",
    "Menos trabajo realizado",
    // You can also add "Ubicación" here if you want to combine it.
    "Ubicación",
  ];

  // This list will store the selected filter(s)
  List<String> selectedFilters = [];
  List<String> appliedFilters = [];

  // Get the current user's uid.
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
            icon: const Icon(Icons.close)),
      ),
      body: Column(
        children: [
          // GroupButton displays filter options
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
              // Using isRadio:true so only one filter is selected at a time.
              onSelected: (value, index, isSelected) {
                setState(() {
                  // Clear previous selections since we're using a radio style
                  selectedFilters.clear();
                  if (isSelected) {
                    selectedFilters.add(value);
                  }
                  // Update the appliedFilters list
                  appliedFilters = List.from(selectedFilters);
                });
              },
              isRadio: true,
              buttons: specialSituations,
            ),
          ),
          const SizedBox(height: 20),
          // SaveButton for location filtering (navigates to a LocationFilter screen)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: 200,
              child: SaveButton(
                title: "Ubicación",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LocationFilter(),
                    ),
                  );
                },
              ),
            ),
          ),
          // Expanded widget displays the query results or an appropriate message.
          Expanded(
            child: appliedFilters.isEmpty
                ? Center(
                    child: Text(
                      "No se han seleccionado filtros. Seleccione un filtro.",
                      style: TextStyle(color: Colors.black, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  )
                : StreamBuilder<QuerySnapshot>(
                    stream: _getFilteredQuery(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Text(
                            "Resultado no encontrado",
                            style: TextStyle(color: Colors.black, fontSize: 16),
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
                          bool isFavorite = favorites.contains(currentUserId);

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HiringService(
                                    serviceDescription: data['description'],
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
                                          color: const Color(0xff9C9EA2),
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
                                                color: const Color(0xff9C9EA2),
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
                                              const Icon(
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
                                                color: const Color(0xff9C9EA2),
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

  /// Builds a Firestore query based on the applied filters.
  /// For the "Más trabajo realizado" and "Menos trabajo realizado" filters,
  /// it orders by the denormalized field "numberOfJobs".
  Stream<QuerySnapshot> _getFilteredQuery() {
    final servicesCollection =
        FirebaseFirestore.instance.collection("services");

    // Start with the base collection.
    Query query = servicesCollection;

    // Filter by Price.
    if (appliedFilters.contains("Precio más alto") &&
        !appliedFilters.contains("Precio más bajo")) {
      query = query.orderBy("price", descending: true);
    } else if (appliedFilters.contains("Precio más bajo") &&
        !appliedFilters.contains("Precio más alto")) {
      query = query.orderBy("price");
    }

    // Filter by Rating.
    if (appliedFilters.contains("Calificación más alta") &&
        !appliedFilters.contains("Calificación más baja")) {
      query = query.orderBy("ratingCount", descending: true);
    } else if (appliedFilters.contains("Calificación más baja") &&
        !appliedFilters.contains("Calificación más alta")) {
      query = query.orderBy("ratingCount");
    }

    // Filter by Work Done using the denormalized field "numberOfJobs".
    if (appliedFilters.contains("Más trabajo realizado") &&
        !appliedFilters.contains("Menos trabajo realizado")) {
      query = query.orderBy("numberOfJobs", descending: true);
    } else if (appliedFilters.contains("Menos trabajo realizado") &&
        !appliedFilters.contains("Más trabajo realizado")) {
      query = query.orderBy("numberOfJobs", descending: false);
    }

    // Optional: Filter by Location if the filter "Ubicación" is applied.
    if (appliedFilters.contains("Ubicación")) {
      query = query.orderBy("location", descending: false);
    }

    return query.snapshots();
  }
}
