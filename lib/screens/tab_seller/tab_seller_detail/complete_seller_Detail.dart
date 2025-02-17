import 'package:flutter/material.dart';
import 'package:kelimbo/screens/main/pages/favourite_page.dart';

class CompleteSellerDetail extends StatefulWidget {
  String uuid;
  String description;
  int price;
  var currency;
  String status;
  CompleteSellerDetail(
      {super.key,
      required this.status,
      required this.uuid,
      required this.description,
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
              ],
            )));
  }
}
