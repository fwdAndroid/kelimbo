import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kelimbo/screens/hiring/hiring_service.dart';
import 'package:kelimbo/screens/main/pages/favourite_page.dart';
import 'package:kelimbo/utils/colors.dart';

class Vehiclescat extends StatefulWidget {
  const Vehiclescat({super.key});

  @override
  State<Vehiclescat> createState() => _VehiclescatState();
}

class _VehiclescatState extends State<Vehiclescat> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Vehículos"),
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("services")
              .where("uid",
                  isNotEqualTo: FirebaseAuth.instance.currentUser!.uid)
              .where("category", isEqualTo: "Vehículos")
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
                                          userEmail: data['userEmail'],
                                          userImage: data['userImage'],
                                          userName: data['userName'],
                                          category: data['category'],
                                          totalReviews:
                                              data['totalReviews'].toString(),
                                          uuid: data['uuid'],
                                          uid: data['uid'],
                                          currencyType: data['currency'],
                                          totalRating:
                                              data['totalRate'].toString(),
                                          title: data['title'],
                                          price: data['price'].toString(),
                                          perHrPrice:
                                              data['pricePerHr'].toString(),
                                          photo: data['photo'],
                                          serviceId: data['uuid'],
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
                  );
                });
          }),
    );
  }
}
