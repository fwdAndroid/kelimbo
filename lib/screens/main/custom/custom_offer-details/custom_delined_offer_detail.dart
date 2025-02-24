import 'package:flutter/material.dart';
import 'package:kelimbo/screens/main/pages/favourite_page.dart';

class CustomDeclinedOfferDetail extends StatefulWidget {
  String uuid;
  String description;
  int price;
  var currency;
  String observation;
  String status;
  CustomDeclinedOfferDetail(
      {super.key,
      required this.status,
      required this.uuid,
      required this.description,
      required this.currency,
      required this.observation,
      required this.price});

  @override
  State<CustomDeclinedOfferDetail> createState() =>
      _CustomDeclinedOfferDetailState();
}

class _CustomDeclinedOfferDetailState extends State<CustomDeclinedOfferDetail> {
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
                  "Descripción: ",
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
                  "Precio: ",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  widget.price.toString() +
                      " " +
                      getCurrencySymbol(widget.currency ?? 'Euro'),
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  "Estado: ",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text("Rechazado ",
                    style: TextStyle(fontSize: 16, color: Colors.red)),
                Text(
                  "observaciones : ",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  widget.observation.toString(),
                  style: TextStyle(fontSize: 16),
                ),
              ],
            )));
  }
}
