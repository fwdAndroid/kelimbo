import 'package:flutter/material.dart';
import 'package:kelimbo/screens/main/pages/favourite_page.dart';

class CompletedProviderJobsDetails extends StatefulWidget {
  String uuid;
  String description;
  String price;
  var currency;
  String status;
  CompletedProviderJobsDetails(
      {super.key,
      required this.status,
      required this.uuid,
      required this.description,
      required this.currency,
      required this.price});

  @override
  State<CompletedProviderJobsDetails> createState() =>
      _CompletedProviderJobsDetailsState();
}

class _CompletedProviderJobsDetailsState
    extends State<CompletedProviderJobsDetails> {
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
                  widget.price +
                      " " +
                      getCurrencySymbol(widget.currency ?? 'Euro'),
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  "Status: ",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text("Completed ",
                    style: TextStyle(fontSize: 16, color: Colors.green)),
              ],
            )));
  }
}
