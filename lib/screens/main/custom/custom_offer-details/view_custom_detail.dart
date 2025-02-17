import 'package:flutter/material.dart';
import 'package:kelimbo/screens/main/pages/favourite_page.dart';

class ViewCustomDetail extends StatefulWidget {
  String uuid;
  String description;
  String price;
  var currency;
  String status;
  ViewCustomDetail(
      {super.key,
      required this.status,
      required this.uuid,
      required this.description,
      required this.currency,
      required this.price});

  @override
  State<ViewCustomDetail> createState() => _ViewCustomDetailState();
}

class _ViewCustomDetailState extends State<ViewCustomDetail> {
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
                  widget.price +
                      " " +
                      getCurrencySymbol(widget.currency ?? 'Euro'),
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  "Estado: ",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text("Pendiente ",
                    style: TextStyle(fontSize: 16, color: Colors.green)),
              ],
            )));
  }
}
