import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kelimbo/screens/main/chat/messages.dart';
import 'package:kelimbo/screens/main/other/offers_profile.dart';
import 'package:kelimbo/screens/main/pages/favourite_page.dart';
import 'package:kelimbo/screens/rating/rating_list.dart';
import 'package:kelimbo/screens/rating/rating_screen.dart';
import 'package:kelimbo/utils/image_utils.dart';
import 'package:kelimbo/widgets/save_button.dart';

class AcceptedJobsDetail extends StatefulWidget {
  final providerEmail,
      providerImage,
      providerName,
      serviceDescription,
      serviceProviderId,
      serviceTitle,
      status,
      uuid,
      work;
  final price;
  final priceprehr;
  final totalRating;
  final currency;
  final serviceId;
  final clientEmail, clientId, clientImage, clientName;
  AcceptedJobsDetail(
      {super.key,
      required this.status,
      required this.uuid,
      required this.clientEmail,
      required this.clientId,
      required this.clientImage,
      required this.clientName,
      required this.serviceId,
      required this.currency,
      required this.priceprehr,
      required this.providerImage,
      required this.providerEmail,
      required this.providerName,
      required this.work,
      required this.serviceProviderId,
      required this.serviceTitle,
      required this.serviceDescription,
      required this.totalRating,
      required this.price});

  @override
  State<AcceptedJobsDetail> createState() => _AcceptedJobsDetailState();
}

class _AcceptedJobsDetailState extends State<AcceptedJobsDetail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: StreamBuilder<DocumentSnapshot>(
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
                              serviceProviderId: widget.serviceProviderId,
                            ),
                          ),
                        );
                      },
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage: NetworkImage(widget.providerImage),
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
                        .where("uid", isEqualTo: widget.serviceProviderId)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
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
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.star, color: Colors.yellow),
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
                              Text(clientData['numberofjobs'].toString()),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Descripción: ",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      widget.serviceDescription,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Precio: ",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                  Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SaveButton(
                      title: "Chatear ahora",
                      onTap: () async {
                        await FirebaseFirestore.instance
                            .collection("chats")
                            .doc(widget.serviceId)
                            .set({
                          "serviceDescription": widget.serviceDescription,
                          "customerName": widget.providerName,
                          "customerId": widget.serviceProviderId,
                          "customerPhoto": widget.providerImage,
                          "customerEmail": widget.providerEmail,
                          "chatId": widget.serviceId,
                          "providerEmail": userData['email'],
                          "providerId": FirebaseAuth.instance.currentUser!.uid,
                          "providerName": userData['fullName'],
                          "providerPhoto": userData['image'],
                        });

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Messages(
                              description: widget.serviceDescription,
                              providerEmail: userData['email'],
                              customerEmail: widget.providerEmail,
                              chatId: widget.serviceId,
                              customerName: widget.providerName,
                              customerPhoto: widget.providerImage,
                              providerId:
                                  FirebaseAuth.instance.currentUser!.uid,
                              providerName: userData['fullName'],
                              customerId: widget.serviceProviderId,
                              providerPhoto: userData['image'],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: SaveButton(
                          title: "Marcar como completa",
                          onTap: () async {
                            await FirebaseFirestore.instance
                                .collection("offers")
                                .doc(widget.uuid)
                                .update({"status": "complete"});
                            showMessageBar(
                                "El trabajo está marcado como completado",
                                context);
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (builder) => RatingScreen(
                                          providerName: widget.providerName,
                                          providerId: widget.serviceProviderId,
                                          jobid: widget.uuid,
                                          clientId: widget.clientId,
                                          clientImage: widget.clientImage,
                                          clientName: widget.clientName,
                                          rating: widget.totalRating,
                                          serviceId: widget.serviceId,
                                        )));
                          }),
                    ),
                  )
                ],
              ));
        },
      ),
    );
  }
}
