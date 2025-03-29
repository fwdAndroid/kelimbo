import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kelimbo/screens/main/chat/messages.dart';
import 'package:kelimbo/screens/main/other/offers_profile.dart';
import 'package:kelimbo/screens/main/pages/favourite_page.dart';
import 'package:kelimbo/screens/rating/rating_list.dart';
import 'package:kelimbo/utils/colors.dart';
import 'package:kelimbo/widgets/save_button.dart';

// ignore: must_be_immutable
class AcceptSellerDetail extends StatefulWidget {
  String uuid;
  String description;
  int price;
  var currency;
  String status;
  String clientImage;
  String clientName;
  String clientEmail;
  String clientId;
  String serviceId;
  AcceptSellerDetail(
      {super.key,
      required this.status,
      required this.uuid,
      required this.clientImage,
      required this.clientName,
      required this.clientEmail,
      required this.clientId,
      required this.serviceId,
      required this.description,
      required this.currency,
      required this.price});

  @override
  State<AcceptSellerDetail> createState() => _AcceptSellerDetailState();
}

class _AcceptSellerDetailState extends State<AcceptSellerDetail> {
  TextEditingController providerPassController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: GestureDetector(
            onTap: () {
              FocusScope.of(context)
                  .unfocus(); // Dismiss keyboard when tapping outside
            },
            child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("users")
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .snapshots(),
                builder: (context, AsyncSnapshot snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: Text('Loading...'));
                  }
                  if (!snapshot.hasData || snapshot.data == null) {
                    return Center(child: Text('Loading...'));
                  }
                  var snap = snapshot.data;
                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (builder) => OffersProfile(
                                          serviceId: widget.serviceId,
                                          serviceProviderId: widget.clientId)));
                            },
                            child: CircleAvatar(
                              radius: 60,
                              backgroundImage: NetworkImage(
                                widget.clientImage,
                              ),
                            ),
                          ),
                        ),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              widget.clientName,
                              style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                        ),
                        StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection("users")
                                .where("uid", isEqualTo: widget.clientId)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const Center(
                                  child: Text(""),
                                );
                              }
                              var userData = snapshot.data!.docs.first.data()
                                  as Map<String, dynamic>;
                              return Column(
                                children: [
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Servicio solicitado",
                            style: TextStyle(
                                color: colorBlack,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            widget.description,
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Precio: ",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            widget.price.toString() +
                                " " +
                                getCurrencySymbol(widget.currency ?? 'Euro'),
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        Center(
                          child: SaveButton(
                              title: "Chatear ahora",
                              onTap: () async {
                                await FirebaseFirestore.instance
                                    .collection("chats")
                                    .doc(widget.serviceId)
                                    .set({
                                  "serviceDescription": widget.description,
                                  "customerName": widget.clientName,
                                  "customerId": widget.clientId,
                                  "customerPhoto": widget.clientImage,
                                  "customerEmail": widget.clientEmail,
                                  "chatId": widget.serviceId,
                                  "providerEmail": snap['email'],
                                  "providerId":
                                      FirebaseAuth.instance.currentUser!.uid,
                                  "providerName": snap['fullName'],
                                  "providerPhoto": snap['image'],
                                });
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (builder) => Messages(
                                              description: widget.description,
                                              providerEmail: snap['email'],
                                              customerEmail: widget.clientEmail,
                                              chatId: widget.serviceId,
                                              customerName: widget.clientName,
                                              customerPhoto: widget.clientImage,
                                              providerId: FirebaseAuth
                                                  .instance.currentUser!.uid,
                                              providerName: snap['fullName'],
                                              customerId: widget.clientId,
                                              providerPhoto: snap['image'],
                                            )));
                              }),
                        ),
                      ],
                    ),
                  );
                })));
  }
}
