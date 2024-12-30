import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kelimbo/screens/hiring/hiring_service.dart';

class LocationFilter extends StatefulWidget {
  const LocationFilter({super.key});

  @override
  State<LocationFilter> createState() => _LocationFilterState();
}

class _LocationFilterState extends State<LocationFilter> {
  TextEditingController controller = TextEditingController();
  final currentUserId = FirebaseAuth.instance.currentUser!.uid;
  List<String> appliedFilters = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: controller,
              onChanged: (value) {
                setState(() {}); // Trigger rebuild to update results
              },
              decoration: InputDecoration(
                labelText: "Enter location",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: appliedFilters.isEmpty
                ? Center(
                    child: Text(
                      "No se han seleccionado filtros. Seleccione un filtro.",
                      style: TextStyle(color: Colors.black, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  )
                : StreamBuilder(
                    stream: _getFilteredQuery(controller.text),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
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

  Stream<QuerySnapshot> _getFilteredQuery(String location) {
    final servicesCollection =
        FirebaseFirestore.instance.collection("services");

    // If the input is empty, return all results
    if (location.isEmpty) {
      return servicesCollection.snapshots();
    }

    // Filter by location
    return servicesCollection
        .where('location', isEqualTo: location.trim())
        .snapshots();
  }
}
