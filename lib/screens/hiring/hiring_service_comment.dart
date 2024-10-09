import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kelimbo/screens/main/main_dashboard.dart';
import 'package:kelimbo/utils/colors.dart';
import 'package:kelimbo/utils/image_utils.dart';
import 'package:kelimbo/widgets/save_button.dart';
import 'package:uuid/uuid.dart';

class HiringServiceComments extends StatefulWidget {
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
  const HiringServiceComments(
      {super.key,
      required this.category,
      required this.description,
      required this.perHrPrice,
      required this.photo,
      required this.price,
      required this.title,
      required this.totalRating,
      required this.totalReviews,
      required this.uid,
      required this.userEmail,
      required this.userImage,
      required this.userName,
      required this.uuid});

  @override
  State<HiringServiceComments> createState() => _HiringServiceCommentsState();
}

class _HiringServiceCommentsState extends State<HiringServiceComments> {
  TextEditingController descriptionController = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  var uuid = Uuid().v4();
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
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
          return Scaffold(
              body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Qué necesitas",
                    style: GoogleFonts.inter(
                      color: colorBlack,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: descriptionController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      filled: true,
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(28)),
                          borderSide: BorderSide(
                            color: textColor,
                          )),
                      contentPadding: EdgeInsets.all(8),
                      fillColor: Color(0xffF5F4F8),
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
                                    "providerName": widget.userName,
                                    "providerEmail": widget.userEmail,
                                    "providerImage": widget.userImage,
                                    "price": int.parse(widget.price),
                                    "priceprehr": int.parse(widget.perHrPrice),
                                    "serviceDescription": widget.description,
                                    "serviceTitle": widget.title,
                                    "rating": widget.totalRating,
                                    "uuid": uuid,
                                    "clientEmail": snap['email'],
                                    "clientName": snap['fullName'],
                                    "clientImage": snap['image'],
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
            ),
          ));
        });
  }
}
