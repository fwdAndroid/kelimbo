import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kelimbo/screens/hiring/hiring_price.dart';
import 'package:kelimbo/screens/main/chat/messages.dart';
import 'package:kelimbo/screens/main/other/other_user_profile.dart';
import 'package:kelimbo/screens/main/other/second_user_profile.dart';
import 'package:kelimbo/screens/rating/rating_list.dart';
import 'package:kelimbo/widgets/save_button.dart';
import 'package:uuid/uuid.dart';

class HiringService extends StatefulWidget {
  final title;
  final currencyType;
  final description;
  final price;
  final serviceId;
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
      required this.serviceId,
      required this.title,
      required this.userEmail,
      required this.userImage,
      required this.userName,
      required this.category,
      required this.photo,
      required this.totalRating,
      required this.uid,
      required this.currencyType,
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
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (builder) => SecondUserProfile(
                                  uuid: widget.uuid,
                                  totalReviews: widget.totalReviews.toString(),
                                  userEmail: widget.userEmail,
                                  userName: widget.userName,
                                  userImage: widget.userImage,
                                  userId: widget.uid)));
                    },
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(widget.userImage),
                      radius: 50,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        widget.userName,
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold, fontSize: 28),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (builder) => RatingList(
                                    serviceId: widget.uuid,
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
                          widget.totalReviews.toString(),
                          style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              fontSize: 19,
                              color: Color(0xff9C9EA2)),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      widget.title,
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      widget.category,
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold, fontSize: 18),
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
                          "customerName": widget.title,
                          "customerId": widget.uid,
                          "customerPhoto": widget.photo,
                          "customerEmail": widget.userEmail,
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
                                      customerName: widget.title,
                                      customerPhoto: widget.photo,
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
                                  builder: (builder) => HiringPrice(
                                        serviceId: widget.serviceId,
                                        price: widget.price.toString(),
                                        currencyType: widget.currencyType,
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
                                        perHrPrice:
                                            widget.perHrPrice.toString(),
                                        photo: widget.photo ?? "",
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
