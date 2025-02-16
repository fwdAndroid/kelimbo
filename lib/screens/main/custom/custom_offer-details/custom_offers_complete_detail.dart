import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kelimbo/screens/main/pages/favourite_page.dart';
import 'package:kelimbo/utils/colors.dart';
import 'package:kelimbo/utils/image_utils.dart';
import 'package:kelimbo/widgets/save_button.dart';
import 'package:google_fonts/google_fonts.dart';

class CompleteCustomOfferDetail extends StatefulWidget {
  String uuid;
  String description;
  int price;
  var currency;
  String status;
  CompleteCustomOfferDetail(
      {super.key,
      required this.status,
      required this.uuid,
      required this.description,
      required this.currency,
      required this.price});

  @override
  State<CompleteCustomOfferDetail> createState() =>
      _CompleteCustomOfferDetailState();
}

class _CompleteCustomOfferDetailState extends State<CompleteCustomOfferDetail> {
  TextEditingController descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Description: ",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(
                  height: 250,
                  child: Text(
                    widget.description,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                Text(
                  "Price: ",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  widget.price.toString() +
                      " " +
                      getCurrencySymbol(widget.currency ?? 'Euro'),
                  style: TextStyle(fontSize: 16),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 150,
                      child: SaveButton(
                          title: "Aceptar",
                          onTap: () async {
                            if (descriptionController.text.isEmpty) {
                              showMessageBar(
                                  "Por favor, ingrese una descripción",
                                  context);
                              return;
                            } else {
                              // accept the offer
                              await FirebaseFirestore.instance
                                  .collection("offers")
                                  .doc(widget.uuid)
                                  .update({
                                "status": "start",
                                "serviceDescription": descriptionController.text
                              });

                              showMessageBar("Oferta aceptada", context);
                              Navigator.pop(context);
                            }
                          }),
                    ),
                    SizedBox(
                      width: 150,
                      child: SaveButton(
                          title: "Rechazar",
                          onTap: () async {
                            // accept the offer
                            await FirebaseFirestore.instance
                                .collection("offers")
                                .doc(widget.uuid)
                                .update({"status": "reject"});

                            showMessageBar("Oferta rechazada", context);
                            Navigator.pop(context);
                          }),
                    )
                  ],
                )
              ],
            )));
  }
}
