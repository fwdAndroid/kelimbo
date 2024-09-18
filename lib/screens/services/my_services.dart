import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kelimbo/screens/services/service_description.dart';
import 'package:kelimbo/utils/colors.dart';

class MyServices extends StatefulWidget {
  const MyServices({super.key});

  @override
  State<MyServices> createState() => _MyServicesState();
}

class _MyServicesState extends State<MyServices> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("services")
              .where("uid", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
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
                  "No Service Available",
                  style: TextStyle(color: colorBlack),
                ),
              );
            }
            return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final List<DocumentSnapshot> documents = snapshot.data!.docs;
                  final Map<String, dynamic> data =
                      documents[index].data() as Map<String, dynamic>;
                  return Card(
                    child: Column(
                      children: [
                        ListTile(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (builder) => ServiceDescription(
                                          photo: data['photo'],
                                          perpriceHr:
                                              data['pricePerHr'].toString(),
                                          description: data['description'],
                                          price: data['price'].toString(),
                                          title: data['title'],
                                          uuid: data['uuid'],
                                          category: data['category'],
                                        )));
                          },
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(data['photo']),
                          ),
                          title: Text(
                            data['title'],
                            style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          subtitle: Text(
                            data['description'],
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
                                  "€" + data['pricePerHr'].toString(),
                                  style: GoogleFonts.inter(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20),
                                ),
                                Text(
                                  "Per Hours",
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
