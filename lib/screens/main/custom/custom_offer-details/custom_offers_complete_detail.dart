import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kelimbo/screens/main/pages/favourite_page.dart';
import 'package:kelimbo/utils/image_utils.dart';
import 'package:kelimbo/widgets/save_button.dart';

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
                  "Custom Offer",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  "Description: ",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(
                  height: 300,
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
                Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 150,
                      child: SaveButton(
                          title: "Aceptar",
                          onTap: () async {
                            // accept the offer
                            await FirebaseFirestore.instance
                                .collection("offers")
                                .doc(widget.uuid)
                                .update({"status": "start"});

                            showMessageBar("Presupuesto enviado", context);
                            Navigator.pop(context);
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

                            showMessageBar("La oferta es rechazada", context);
                            Navigator.pop(context);
                          }),
                    )
                  ],
                )
              ],
            )));
  }
}
