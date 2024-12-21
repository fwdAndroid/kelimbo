import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kelimbo/screens/main/main_dashboard.dart';
import 'package:kelimbo/screens/main/pages/favourite_page.dart';

class CurrentJobDetail extends StatefulWidget {
  String uuid;
  String description;
  String price;
  var currency;
  String status;
  CurrentJobDetail(
      {super.key,
      required this.status,
      required this.uuid,
      required this.description,
      required this.currency,
      required this.price});

  @override
  State<CurrentJobDetail> createState() => _CurrentJobDetailState();
}

class _CurrentJobDetailState extends State<CurrentJobDetail> {
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
                TextButton(
                    onPressed: () async {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("Confirm"),
                              content: Text(
                                  "Are you sure you want to mark this job as completed?"),
                              actions: [
                                TextButton(
                                  child: Text("Cancel"),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                  child: Text("Yes"),
                                  onPressed: () async {
                                    await FirebaseFirestore.instance
                                        .collection('customOffers')
                                        .doc(widget.uuid)
                                        .update({
                                      'status': 'completed',
                                    });
                                    Navigator.of(context).pop();
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                MainDashboard()));
                                  },
                                ),
                              ],
                            );
                          });
                    },
                    child: Text(
                      "Mark as completed",
                      style: TextStyle(color: Colors.green),
                    ))
              ],
            )));
  }
}
