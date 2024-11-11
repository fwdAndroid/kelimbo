import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kelimbo/screens/hiring/hiring_service.dart';
import 'package:kelimbo/utils/colors.dart';

class Mascotas extends StatefulWidget {
  const Mascotas({super.key});

  @override
  State<Mascotas> createState() => _MascotasState();
}

class _MascotasState extends State<Mascotas> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Mascotas"),
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("services")
              .where("uid",
                  isNotEqualTo: FirebaseAuth.instance.currentUser!.uid)
              .where("category", isEqualTo: "Mascotas")
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
            return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (index, contrxt) {
                  final List<DocumentSnapshot> documents = snapshot.data!.docs;
                  final Map<String, dynamic> data =
                      documents[contrxt].data() as Map<String, dynamic>;
                  return Card(
                    child: Column(
                      children: [
                        ListTile(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (builder) => HiringService(
                                          currencyType: data['currency'],
                                          userEmail: data['userEmail'],
                                          serviceId: data['uuid'],
                                          userImage: data['userImage'],
                                          userName: data['userName'],
                                          category: data['category'],
                                          totalReviews:
                                              data['totalReviews'].toString(),
                                          uuid: data['uuid'],
                                          uid: data['uid'],
                                          totalRating:
                                              data['totalRate'].toString(),
                                          title: data['title'],
                                          price: data['price'].toString(),
                                          perHrPrice:
                                              data['pricePerHr'].toString(),
                                          photo: data['photo'],
                                          description: data['description'],
                                        )));
                          },
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
                                      color: yellow,
                                    ),
                                    Text(
                                      data['totalRate'].toString(),
                                      style: GoogleFonts.inter(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20),
                                    ),
                                  ],
                                ),
                                Text(
                                  data['totalReviews'].toString() + " Reviews",
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
                  );
                });
          }),
    );
  }
}
