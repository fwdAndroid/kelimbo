import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kelimbo/screens/hiring/hiring_service.dart';
import 'package:kelimbo/utils/colors.dart';
import 'package:kelimbo/widgets/currecysymbal.dart';

class PopularServiceWidget extends StatelessWidget {
  const PopularServiceWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        height: 250,
        width: MediaQuery.of(context).size.width,
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("services")
              .where("uid", isNotEqualTo: currentUserId)
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
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                final data =
                    snapshot.data!.docs[index].data() as Map<String, dynamic>;

                bool isFavorite = (data['favorite'] as List<dynamic>?)
                        ?.contains(currentUserId) ??
                    false;

                return GestureDetector(
                  onTap: () {
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
                                  totalReviews: data['totalReviews'].toString(),
                                  uuid: data['uuid'],
                                  uid: data['uid'],
                                  totalRating: data['totalRate'].toString(),
                                  title: data['title'],
                                  price: data['price'].toString(),
                                  perHrPrice: data['pricePerHr'].toString(),
                                  photo: data['photo'],
                                  description: data['description'],
                                )));
                  },
                  child: SizedBox(
                    height: 300,
                    width: 300,
                    child: Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Stack(
                              children: [
                                data['photo'] == ""
                                    ? Container()
                                    : ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: Image.network(
                                          fit: BoxFit.cover,
                                          data['photo'],
                                          height: 150,
                                          width: 300,
                                        ),
                                      ),
                                GestureDetector(
                                  onTap: () async {
                                    final docRef = FirebaseFirestore.instance
                                        .collection("services")
                                        .doc(data['uuid']);
                                    if (isFavorite) {
                                      // Remove from favorites
                                      await docRef.update({
                                        "favorite": FieldValue.arrayRemove(
                                            [currentUserId])
                                      });
                                    } else {
                                      // Add to favorites
                                      await docRef.update({
                                        "favorite": FieldValue.arrayUnion(
                                            [currentUserId])
                                      });
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Align(
                                      alignment: AlignmentDirectional.topEnd,
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
                                )
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              data['title'],
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                          fontSize: 13),
                                    ),
                                  ],
                                ),
                                Text(
                                  "${getCurrencySymbol(data['currency'] ?? 'Euro')}${data['price'] ?? '0.0'}",
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
