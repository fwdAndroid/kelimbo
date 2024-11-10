import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kelimbo/screens/main/main_dashboard.dart';
import 'package:kelimbo/utils/colors.dart';
import 'package:kelimbo/utils/image_utils.dart';
import 'package:kelimbo/widgets/save_button.dart';
import 'package:uuid/uuid.dart';

class HiringPrice extends StatefulWidget {
  final title;
  final description;
  final perHrPrice;
  final totalReviews;
  final totalRating;
  final photo;
  final uuid;
  final category;
  final uid;
  final price;
  final userEmail;
  final userName;
  final userImage;
  final currencyType;
  HiringPrice(
      {super.key,
      required this.description,
      required this.perHrPrice,
      required this.title,
      required this.userEmail,
      required this.price,
      required this.userImage,
      required this.userName,
      required this.currencyType,
      required this.category,
      required this.photo,
      required this.totalRating,
      required this.uid,
      required this.uuid,
      required this.totalReviews});

  @override
  State<HiringPrice> createState() => _HiringPriceState();
}

class _HiringPriceState extends State<HiringPrice> {
  TextEditingController descriptionController = TextEditingController();
  bool isLoading = false;
  var uuid = Uuid().v4();
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
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("Solicitar a: ${widget.userName}"),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    maxLength: 30,
                    controller: descriptionController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      filled: true,
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(22)),
                          borderSide: BorderSide(
                            color: textColor,
                          )),
                      contentPadding: EdgeInsets.all(8),
                      fillColor: Color(0xffF6F7F9),
                      hintText: "Descripción",
                      hintStyle: GoogleFonts.nunitoSans(fontSize: 16),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                Spacer(),
                isLoading
                    ? Center(child: CircularProgressIndicator())
                    : Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SaveButton(
                              title: "Finalizar",
                              onTap: () async {
                                if (descriptionController.text.isEmpty) {
                                  showMessageBar(
                                      "Descripción Se requiere oferta",
                                      context);
                                } else {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  await FirebaseFirestore.instance
                                      .collection("offers")
                                      .doc(uuid)
                                      .set({
                                    "work": descriptionController.text,
                                    "clientId":
                                        FirebaseAuth.instance.currentUser!.uid,
                                    "serviceProviderId": widget.uid,
                                    "status": "send",
                                    "price": int.parse(widget.price),
                                    "providerName": widget.userName,
                                    "providerEmail": widget.userEmail,
                                    "priceprehr": int.parse(widget.perHrPrice),
                                    "serviceDescription": widget.description,
                                    "serviceTitle": widget.title,
                                    "rating": widget.totalRating,
                                    "uuid": uuid,
                                    "clientEmail": snap['email'],
                                    "clientName": snap['fullName'],
                                    "clientImage": snap['image'],
                                    "currencyType": widget.currencyType
                                  });
                                  setState(() {
                                    isLoading = false;
                                  });
                                  showMessageBar(
                                      "Envío de oferta al proveedor", context);
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (builder) =>
                                              MainDashboard()));
                                }
                              }),
                        ),
                      )
              ],
            );
          }),
    );
  }
}
