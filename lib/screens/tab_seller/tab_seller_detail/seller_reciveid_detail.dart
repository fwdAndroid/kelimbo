import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kelimbo/screens/main/pages/favourite_page.dart';
import 'package:kelimbo/utils/colors.dart';
import 'package:kelimbo/utils/image_utils.dart';
import 'package:kelimbo/widgets/save_button.dart';

class SellerReceivedDetail extends StatefulWidget {
  String uuid;
  String description;
  int price;
  var currency;
  String status;
  SellerReceivedDetail(
      {super.key,
      required this.status,
      required this.uuid,
      required this.description,
      required this.currency,
      required this.price});

  @override
  State<SellerReceivedDetail> createState() => _SellerReceivedDetailState();
}

class _SellerReceivedDetailState extends State<SellerReceivedDetail> {
  TextEditingController providerPassController = TextEditingController();
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
                  height: 150,
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
                    padding: const EdgeInsets.only(
                      left: 8.0,
                      right: 8,
                      bottom: 8,
                      top: 8,
                    ),
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(8),
                        fillColor: textColor,
                        filled: true,
                        hintStyle: GoogleFonts.nunitoSans(fontSize: 16),
                        hintText: "Precio",
                      ),
                      controller: providerPassController,
                    )),
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
                Center(
                  child: SaveButton(
                      title: "Aceptado",
                      onTap: () async {
                        if (providerPassController.text.isEmpty) {
                          showMessageBar("Se requiere precio", context);
                        } else {
                          await FirebaseFirestore.instance
                              .collection("offers")
                              .doc(widget.uuid)
                              .update({
                            "status": "counterOffer",
                            "price": int.parse(providerPassController.text),
                            "serviceDescription":
                                descriptionController.text ?? widget.description
                          });
                          showMessageBar("Se acepta la oferta", context);
                          Navigator.pop(context);
                        }
                        // accept the offer
                      }),
                ),
              ],
            )));
  }
}
