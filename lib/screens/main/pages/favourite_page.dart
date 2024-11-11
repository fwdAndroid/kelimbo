import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kelimbo/screens/hiring/hiring_service.dart';
import 'package:kelimbo/screens/main/other/other_user_profile.dart';
import 'package:kelimbo/utils/colors.dart';

class FavouritePage extends StatefulWidget {
  const FavouritePage({super.key});

  @override
  State<FavouritePage> createState() => _FavouritePageState();
}

class _FavouritePageState extends State<FavouritePage> {
  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("services")
            .where("favorite", arrayContains: currentUserId)
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
                "No hay favoritos disponibles",
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

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => HiringService(
                              userEmail: data['userEmail'],
                              userImage: data['userImage'],
                              userName: data['userName'],
                              category: data['category'],
                              totalReviews: data['totalReviews'].toString(),
                              uuid: data['uuid'],
                              uid: data['uid'],
                              currencyType: data['currency'],
                              totalRating: data['totalRate'].toString(),
                              title: data['title'],
                              price: data['price'].toString(),
                              serviceId: data['uuid'],
                              perHrPrice: data['pricePerHr'].toString(),
                              photo: data['photo'],
                              description: data['description'],
                            )),
                  );
                },
                child: Card(
                  child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection("users")
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Text("");
                        }
                        if (!snapshot.hasData || snapshot.data == null) {
                          return Center(child: Text('No data available'));
                        }
                        var snap = snapshot.data;
                        return Column(
                          children: [
                            ListTile(
                              leading: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (builder) =>
                                              OtherUserProfile(
                                                  customerEmail:
                                                      data['userEmail'],
                                                  customerName:
                                                      data['userName'],
                                                  customerPhoto:
                                                      data['userImage'],
                                                  userEmail: snap?['email'],
                                                  userName: snap?['fullName'],
                                                  userImage: snap?['image'],
                                                  uid: data['uid'])));
                                },
                                child: CircleAvatar(
                                  backgroundImage: NetworkImage(
                                      data['photo'] ?? "assets/logo.png"),
                                ),
                              ),
                              title: Text(
                                data['title'] ?? "No Title",
                                style: GoogleFonts.inter(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              subtitle: Text(
                                data['category'] ?? "No Subtitle",
                                style: GoogleFonts.inter(
                                    color: Color(0xff9C9EA2),
                                    fontWeight: FontWeight.w300,
                                    fontSize: 15),
                              ),
                              trailing: GestureDetector(
                                onTap: () async {
                                  final docRef = FirebaseFirestore.instance
                                      .collection("services")
                                      .doc(data['uuid']);
                                  await docRef.update({
                                    "favorite":
                                        FieldValue.arrayRemove([currentUserId])
                                  });
                                },
                                child: Icon(
                                  Icons.favorite,
                                  color: red,
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      "€${data['price'] ?? '0.0'}",
                                      style: GoogleFonts.inter(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20),
                                    ),
                                    Text(
                                      "Price",
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
                                          "${data['totalRate'] ?? '0.0'}",
                                          style: GoogleFonts.inter(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      "${data['reviewCount'] ?? '0'} Reviews",
                                      style: GoogleFonts.inter(
                                          color: Color(0xff9C9EA2),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 19),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          ],
                        );
                      }),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
