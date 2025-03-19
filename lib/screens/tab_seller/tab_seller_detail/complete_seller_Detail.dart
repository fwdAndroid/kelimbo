import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kelimbo/screens/main/other/offers_profile.dart';
import 'package:kelimbo/screens/main/pages/favourite_page.dart';
import 'package:kelimbo/screens/rating/rating_list.dart';
import 'package:kelimbo/utils/colors.dart';

class CompleteSellerDetail extends StatefulWidget {
  String uuid;
  String description;
  int price;
  var currency;
  String status;
  String clientImage;
  String clientName;
  String clientId;
  String serviceId;
  CompleteSellerDetail(
      {super.key,
      required this.status,
      required this.uuid,
      required this.description,
      required this.clientName,
      required this.clientId,
      required this.serviceId,
      required this.clientImage,
      required this.currency,
      required this.price});

  @override
  State<CompleteSellerDetail> createState() => _CompleteSellerDetailState();
}

class _CompleteSellerDetailState extends State<CompleteSellerDetail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Column(
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
                  var userData =
                      snapshot.data!.docs.first.data() as Map<String, dynamic>;
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
              child: Expanded(
                child: Text(
                  widget.description,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Precio: ",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
          ],
        ));
  }
}
