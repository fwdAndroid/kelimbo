import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kelimbo/screens/main/chat/messages.dart';
import 'package:kelimbo/screens/main/other/offers_profile.dart';
import 'package:kelimbo/screens/rating/rating_list.dart';
import 'package:kelimbo/seller_provider/seller_provider.dart';
import 'package:kelimbo/widgets/save_button.dart';
import 'package:provider/provider.dart';

class SellerReceivedDetail extends StatefulWidget {
  final String uuid;
  final String description;
  final int price;
  final String currency;
  final String status;
  final String clientImage;
  final String clientName;
  final String clientEmail;
  final String clientId;
  final String serviceId;

  const SellerReceivedDetail({
    super.key,
    required this.status,
    required this.uuid,
    required this.clientImage,
    required this.clientName,
    required this.clientEmail,
    required this.clientId,
    required this.serviceId,
    required this.description,
    required this.currency,
    required this.price,
  });

  @override
  State<SellerReceivedDetail> createState() => _SellerReceivedDetailState();
}

class _SellerReceivedDetailState extends State<SellerReceivedDetail> {
  final TextEditingController providerPassController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context)
            .unfocus(); // Dismiss keyboard when tapping outside
      },
      child: Scaffold(
        appBar: AppBar(),
        body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection("users")
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .snapshots(),
          builder: (context, snapshot) {
            var userData = snapshot.data!.data() as Map<String, dynamic>;

            return Padding(
              padding: const EdgeInsets.all(8.0),
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
                              serviceProviderId: widget.clientId,
                            ),
                          ),
                        );
                      },
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage: NetworkImage(widget.clientImage),
                      ),
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        widget.clientName,
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
                        .where("uid", isEqualTo: widget.clientId)
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
                  const SizedBox(height: 10),
                  Text("Servicio solicitado",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      )),
                  Text(widget.description,
                      style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 10),
                  Text("Precio:",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      )),
                  Text(
                    "${widget.price} ${widget.currency}",
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    controller: providerPassController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.all(8),
                      fillColor: Colors.grey.shade200,
                      filled: true,
                      hintText: "Precio",
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: descriptionController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.all(8),
                      fillColor: const Color(0xffF6F7F9),
                      hintText: "Observaciones",
                    ),
                  ),
                  const SizedBox(height: 10),
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
                          "providerEmail": userData['email'],
                          "providerId": FirebaseAuth.instance.currentUser!.uid,
                          "providerName": userData['fullName'],
                          "providerPhoto": userData['image'],
                        });

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Messages(
                              description: widget.description,
                              providerEmail: userData['email'],
                              customerEmail: widget.clientEmail,
                              chatId: widget.serviceId,
                              customerName: widget.clientName,
                              customerPhoto: widget.clientImage,
                              providerId:
                                  FirebaseAuth.instance.currentUser!.uid,
                              providerName: userData['fullName'],
                              customerId: widget.clientId,
                              providerPhoto: userData['image'],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: SaveButton(
                      title: "Enviar presupuestos",
                      onTap: () async {
                        FocusScope.of(context).unfocus(); // Hide keyboard

                        if (providerPassController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Se requiere precio")),
                          );
                        } else {
                          await FirebaseFirestore.instance
                              .collection("offers")
                              .doc(widget.uuid)
                              .update({
                            "status": "counterOffer",
                            "price": int.parse(providerPassController.text),
                            "serviceDescription":
                                descriptionController.text.isNotEmpty
                                    ? descriptionController.text
                                    : widget.description,
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Presupuesto enviado")),
                          );
                          if (mounted) {
                            Provider.of<SellerReceivedProvider>(context,
                                    listen: false)
                                .removeOffer(widget.uuid);
                          }
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
