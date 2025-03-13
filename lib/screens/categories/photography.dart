import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kelimbo/screens/hiring/hiring_service.dart';
import 'package:kelimbo/screens/main/pages/favourite_page.dart';
import 'package:kelimbo/screens/services/edit_service.dart';
import 'package:kelimbo/utils/colors.dart';

class Photography extends StatefulWidget {
  const Photography({super.key});

  @override
  State<Photography> createState() => _PhotographyState();
}

class _PhotographyState extends State<Photography> {
  final String? currentUserUid = FirebaseAuth.instance.currentUser?.uid;
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Fotografía Y Video"),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Buscar",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
        ),
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("services")
              .where("category", isEqualTo: "Fotografía y video")
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.data!.docs.isEmpty) {
              return Center(
                child: Text(
                  "No hay servicio disponible",
                  style: TextStyle(color: colorBlack),
                ),
              );
            }
            final List<DocumentSnapshot> filteredDocuments =
                snapshot.data!.docs.where((doc) {
              final Map<String, dynamic> data =
                  doc.data() as Map<String, dynamic>;
              final String userName =
                  data['userName']?.toString().toLowerCase() ?? '';
              final String serviceName =
                  data['title']?.toString().toLowerCase() ?? '';
              final String location =
                  data['location']?.toString().toLowerCase() ?? '';
              final String price =
                  data['price']?.toString().toLowerCase() ?? '';

              return userName.contains(searchQuery) ||
                  serviceName.contains(searchQuery) ||
                  location.contains(searchQuery) ||
                  price.contains(searchQuery);
            }).toList();

            if (filteredDocuments.isEmpty) {
              return Center(
                child: Text(
                  "No se han encontrado resultados",
                  style: TextStyle(color: colorBlack),
                ),
              );
            }
            return ListView.builder(
                itemCount: filteredDocuments.length,
                itemBuilder: (index, contrxt) {
                  final Map<String, dynamic> data =
                      filteredDocuments[contrxt].data() as Map<String, dynamic>;
                  return GestureDetector(
                    onTap: () {
                      if (data['uid'] == currentUserUid) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (builder) =>
                                  EditService(uuid: data['uuid'])),
                        );
                      } else {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (builder) => HiringService(
                                      serviceId: data['uuid'],
                                      currencyType: data['currency'],
                                      userEmail: data['userEmail'],
                                      userImage: data['userImage'],
                                      userName: data['userName'],
                                      category: data['category'],
                                      totalReviews:
                                          data['totalReviews'].toString(),
                                      uuid: data['uuid'],
                                      serviceDescription: data['description'],
                                      uid: data['uid'],
                                      totalRating: data['totalRate'].toString(),
                                      title: data['title'],
                                      price: data['price'].toString(),
                                      perHrPrice: data['pricePerHr'].toString(),
                                      photo: data['photo'],
                                      description: data['description'],
                                    )));
                      }
                    },
                    child: Card(
                      child: Column(
                        children: [
                          ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(data['userImage']),
                            ),
                            title: Text(
                              data['userName'],
                              style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold, fontSize: 16),
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
                                    "${getCurrencySymbol(data['currency'] ?? 'Euro')}${data['price'] ?? '0.0'}",
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
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
                                        color: yellow,
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
                                    data['ratingCount'].toString() + " Reviews",
                                    style: GoogleFonts.inter(
                                        color: Color(0xff9C9EA2),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 19),
                                  ),
                                ],
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                });
          }),
    );
  }
}
