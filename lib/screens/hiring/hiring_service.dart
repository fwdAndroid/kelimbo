import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kelimbo/screens/hiring/hiring_service_comment.dart';
import 'package:kelimbo/screens/main/chat/messages.dart';
import 'package:kelimbo/widgets/save_button.dart';
import 'package:uuid/uuid.dart';

class HiringService extends StatefulWidget {
  final title;
  final description;
  final price;
  final perHrPrice;
  final totalReviews;
  final totalRating;
  final photo;
  final uuid;
  final category;
  final uid;
  final userEmail;
  final userName;
  final userImage;
  const HiringService(
      {super.key,
      required this.description,
      required this.perHrPrice,
      required this.price,
      required this.title,
      required this.userEmail,
      required this.userImage,
      required this.userName,
      required this.category,
      required this.photo,
      required this.totalRating,
      required this.uid,
      required this.uuid,
      required this.totalReviews});

  @override
  State<HiringService> createState() => _HiringServiceState();
}

class _HiringServiceState extends State<HiringService> {
  var chatId = Uuid().v4();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("users")
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .snapshots(),
          builder: (context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: Text(""));
            }
            if (!snapshot.hasData || snapshot.data == null) {
              return Center(child: Text('No hay datos disponibles'));
            }
            var snap = snapshot.data;
            return SingleChildScrollView(
              child: Column(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(widget.userImage),
                    radius: 50,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      widget.userName,
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold, fontSize: 28),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.star,
                        color: Colors.yellow,
                      ),
                      Text(
                        widget.totalRating.toString(),
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            fontSize: 19,
                            color: Color(0xff9C9EA2)),
                      )
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      widget.category,
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ),
                  Center(
                    child: SizedBox(
                      height: 150,
                      width: 390,
                      child: Text(
                        widget.description,
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.w500, fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  widget.photo == ""
                      ? Container()
                      : Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.network(
                            widget.photo,
                            height: 254,
                          ),
                        ),
                  SaveButton(
                      title: "Chatear ahora",
                      onTap: () async {
                        await FirebaseFirestore.instance
                            .collection("chats")
                            .doc(chatId)
                            .set({
                          "customerName": widget.userName,
                          "customerId": widget.uid,
                          "customerPhoto": widget.userImage,
                          "chatId": chatId,
                          "providerEmail": snap['email'],
                          "providerId": FirebaseAuth.instance.currentUser!.uid,
                          "providerName": snap['fullName'],
                          "providerPhoto": snap['image'],
                        });
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (builder) => Messages(
                                      providerEmail: snap['email'],
                                      customerEmail: widget.userEmail,
                                      chatId: chatId,
                                      customerName: widget.userName,
                                      customerPhoto: widget.userImage,
                                      providerId: FirebaseAuth
                                          .instance.currentUser!.uid,
                                      providerName: snap['fullName'],
                                      customerId: widget.uid,
                                      providerPhoto: snap['image'],
                                    )));
                      }),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SaveButton(
                        title: "Solicitar presupuesto",
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (builder) => HiringServiceComments(
                                        userEmail: widget.userEmail,
                                        userImage: widget.userImage,
                                        userName: widget.userName,
                                        category: widget.category,
                                        totalReviews:
                                            widget.totalReviews.toString(),
                                        uuid: widget.uuid,
                                        uid: widget.uid,
                                        totalRating:
                                            widget.totalRating.toString(),
                                        title: widget.title,
                                        price: widget.price.toString(),
                                        perHrPrice:
                                            widget.perHrPrice.toString(),
                                        photo: widget.photo,
                                        description: widget.description,
                                      )));
                        }),
                  )
                ],
              ),
            );
          }),
    );
  }
}
