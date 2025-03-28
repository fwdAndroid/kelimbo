import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kelimbo/screens/main/chat/messages.dart';
import 'package:kelimbo/screens/main/other/offers_profile.dart';
import 'package:kelimbo/screens/main/pages/favourite_page.dart';
import 'package:kelimbo/screens/rating/rating_list.dart';
import 'package:kelimbo/widgets/save_button.dart';

class PendingOfferDetailOferta extends StatefulWidget {
  String uuid;
  String description;
  int price;
  var currency;
  String status;
  String providerImage;
  String providerName;
  String serviceId;
  String providerEmail;
  String serviceProviderId;
  PendingOfferDetailOferta(
      {super.key,
      required this.currency,
      required this.description,
      required this.price,
      required this.status,
      required this.providerImage,
      required this.providerEmail,
      required this.serviceId,
      required this.providerName,
      required this.serviceProviderId,
      required this.uuid});

  @override
  State<PendingOfferDetailOferta> createState() =>
      _PendingOfferDetailOfertaState();
}

class _PendingOfferDetailOfertaState extends State<PendingOfferDetailOferta> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus(); // Hide keyboard on button
            },
            child: StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("users")
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  var userData = snapshot.data!.data() as Map<String, dynamic>;

                  return Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => OffersProfile(
                                      serviceId: widget.serviceId,
                                      serviceProviderId:
                                          widget.serviceProviderId,
                                    ),
                                  ),
                                );
                              },
                              child: CircleAvatar(
                                radius: 60,
                                backgroundImage:
                                    NetworkImage(widget.providerImage),
                              ),
                            ),
                          ),
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                widget.providerName,
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection("users")
                                .where("uid",
                                    isEqualTo: widget.serviceProviderId)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData ||
                                  snapshot.data!.docs.isEmpty) {
                                return const SizedBox();
                              }
                              var clientData = snapshot.data!.docs.first.data()
                                  as Map<String, dynamic>;

                              return Column(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => RatingList(
                                            serviceId: widget.serviceId,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.star,
                                            color: Colors.yellow),
                                        Text(
                                          clientData['totalReviews'].toString(),
                                          style: GoogleFonts.inter(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 19,
                                            color: const Color(0xff9C9EA2),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text("Número de trabajos: "),
                                      Text(clientData['numberofjobs']
                                          .toString()),
                                    ],
                                  ),
                                ],
                              );
                            },
                          ),
                          Text(
                            "Descripción: ",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            widget.description,
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            "Precio: ",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            widget.price.toString() +
                                " " +
                                getCurrencySymbol(widget.currency ?? 'Euro'),
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            "Estado: ",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            "Pendiente",
                            style: TextStyle(fontSize: 16),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SaveButton(
                              title: "Chatear ahora",
                              onTap: () async {
                                await FirebaseFirestore.instance
                                    .collection("chats")
                                    .doc(widget.serviceId)
                                    .set({
                                  "serviceDescription": widget.description,
                                  "customerName": widget.providerName,
                                  "customerId": widget.serviceProviderId,
                                  "customerPhoto": widget.providerImage,
                                  "customerEmail": widget.providerEmail,
                                  "chatId": widget.serviceId,
                                  "providerEmail": userData['email'],
                                  "providerId":
                                      FirebaseAuth.instance.currentUser!.uid,
                                  "providerName": userData['fullName'],
                                  "providerPhoto": userData['image'],
                                });

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Messages(
                                      description: widget.description,
                                      providerEmail: userData['email'],
                                      customerEmail: widget.providerEmail,
                                      chatId: widget.serviceId,
                                      customerName: widget.providerName,
                                      customerPhoto: widget.providerImage,
                                      providerId: FirebaseAuth
                                          .instance.currentUser!.uid,
                                      providerName: userData['fullName'],
                                      customerId: widget.serviceProviderId,
                                      providerPhoto: userData['image'],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ));
                })));
  }
}
