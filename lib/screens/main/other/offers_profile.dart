import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kelimbo/screens/hiring/hiring_service.dart';
import 'package:kelimbo/screens/main/pages/favourite_page.dart';
import 'package:kelimbo/screens/rating/rating_list.dart';
import 'package:kelimbo/utils/colors.dart';

// ignore: must_be_immutable
class OffersProfile extends StatefulWidget {
  String serviceProviderId;
  String serviceId;
  OffersProfile(
      {super.key, required this.serviceProviderId, required this.serviceId});

  @override
  State<OffersProfile> createState() => _OffersProfileState();
}

class _OffersProfileState extends State<OffersProfile> {
  final currentUserId = FirebaseAuth.instance.currentUser!.uid;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("users")
                  .where("uid", isEqualTo: widget.serviceProviderId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: Text(""),
                  );
                }
                var userData =
                    snapshot.data!.docs.first.data() as Map<String, dynamic>;

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(userData['image'] ?? ''),
                        radius: 60,
                      ),
                    ),
                    Text(
                      userData['fullName'] ?? 'No Name',
                      style: GoogleFonts.workSans(
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (builder) => RatingList(
                                      serviceId: widget.serviceId,
                                    )));
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.star,
                            color: Colors.yellow,
                          ),
                          Text(
                            userData['totalReviews'].toString(),
                            style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold,
                                fontSize: 19,
                                color: Color(0xff9C9EA2)),
                          )
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Número de trabajos: "),
                        Text(userData['numberofjobs'].toString()),
                      ],
                    ),
                  ],
                );
              }),
          StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("services")
                  .where("uid", isEqualTo: widget.serviceProviderId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: Text(""),
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
                return Expanded(
                  child: ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        final List<DocumentSnapshot> documents =
                            snapshot.data!.docs;
                        final Map<String, dynamic> data =
                            documents[index].data() as Map<String, dynamic>;
                        bool isFavorite = (data['favorite'] as List<dynamic>?)
                                ?.contains(currentUserId) ??
                            false;

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HiringService(
                                        serviceDescription: data['description'],
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
                                        serviceId: data['uuid'],
                                        perHrPrice:
                                            data['pricePerHr'].toString(),
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
                                  if (!snapshot.hasData ||
                                      snapshot.data == null) {
                                    return Center(
                                        child:
                                            Text('No hay datos disponibles'));
                                  }

                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (builder) =>
                                                  HiringService(
                                                    serviceDescription:
                                                        data['description'],
                                                    serviceId: data['uuid'],
                                                    currencyType:
                                                        data['currency'],
                                                    userEmail:
                                                        data['userEmail'],
                                                    userImage:
                                                        data['userImage'],
                                                    userName: data['userName'],
                                                    category: data['category'],
                                                    totalReviews:
                                                        data['totalReviews']
                                                            .toString(),
                                                    uuid: data['uuid'],
                                                    uid: data['uid'],
                                                    totalRating:
                                                        data['totalRate']
                                                            .toString(),
                                                    title: data['title'],
                                                    price: data['price']
                                                        .toString(),
                                                    perHrPrice:
                                                        data['pricePerHr']
                                                            .toString(),
                                                    photo: data['photo'],
                                                    description:
                                                        data['description'],
                                                  )));
                                    },
                                    child: Column(
                                      children: [
                                        ListTile(
                                          leading: GestureDetector(
                                            child: CircleAvatar(
                                              backgroundImage: NetworkImage(
                                                  data['photo'] ??
                                                      "assets/logo.png"),
                                            ),
                                          ),
                                          title: Text(
                                            data['title'] ?? "No Title",
                                            style: GoogleFonts.inter(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16),
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
                                              final docRef = FirebaseFirestore
                                                  .instance
                                                  .collection("services")
                                                  .doc(data['uuid']);
                                              if (isFavorite) {
                                                // Remove from favorites
                                                await docRef.update({
                                                  "favorite":
                                                      FieldValue.arrayRemove(
                                                          [currentUserId])
                                                });
                                              } else {
                                                // Add to favorites
                                                await docRef.update({
                                                  "favorite":
                                                      FieldValue.arrayUnion(
                                                          [currentUserId])
                                                });
                                              }
                                            },
                                            child: Container(
                                              child: Icon(
                                                isFavorite
                                                    ? Icons.favorite
                                                    : Icons.favorite_outline,
                                                color: red,
                                              ),
                                              height: 50,
                                              width: 50,
                                              decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: colorWhite),
                                            ),
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
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
                                                  "Precio",
                                                  style: GoogleFonts.inter(
                                                      color: Color(0xff9C9EA2),
                                                      fontWeight:
                                                          FontWeight.bold,
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
                                                      "${data['totalReviews'] ?? '0.0'}",
                                                      style: GoogleFonts.inter(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 20),
                                                    ),
                                                  ],
                                                ),
                                                Text(
                                                  "${data['ratingCount'] ?? '0'} Reviews",
                                                  style: GoogleFonts.inter(
                                                      color: Color(0xff9C9EA2),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 19),
                                                ),
                                              ],
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  );
                                }),
                          ),
                        );
                      }),
                );
              }),
        ],
      ),
    );
  }
}
