import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kelimbo/screens/main/pages/favourite_page.dart';
import 'package:kelimbo/screens/rating/rating_screen.dart';
import 'package:kelimbo/utils/image_utils.dart';
import 'package:kelimbo/widgets/save_button.dart';

class AcceptedJobsDetail extends StatefulWidget {
  final providerEmail,
      providerImage,
      providerName,
      serviceDescription,
      serviceProviderId,
      serviceTitle,
      status,
      uuid,
      work;
  final price;
  final priceprehr;
  final totalRating;
  final currency;
  final serviceId;
  final clientEmail, clientId, clientImage, clientName;
  AcceptedJobsDetail(
      {super.key,
      required this.status,
      required this.uuid,
      required this.clientEmail,
      required this.clientId,
      required this.clientImage,
      required this.clientName,
      required this.serviceId,
      required this.currency,
      required this.priceprehr,
      required this.providerImage,
      required this.providerEmail,
      required this.providerName,
      required this.work,
      required this.serviceProviderId,
      required this.serviceTitle,
      required this.serviceDescription,
      required this.totalRating,
      required this.price});

  @override
  State<AcceptedJobsDetail> createState() => _AcceptedJobsDetailState();
}

class _AcceptedJobsDetailState extends State<AcceptedJobsDetail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Descripción: ",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    widget.serviceDescription,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Precio: ",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    widget.price.toString() +
                        " " +
                        getCurrencySymbol(widget.currency ?? 'Euro'),
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                Spacer(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: SaveButton(
                        title: "Marcar como completa",
                        onTap: () async {
                          await FirebaseFirestore.instance
                              .collection("offers")
                              .doc(widget.uuid)
                              .update({"status": "complete"});
                          showMessageBar(
                              "El trabajo está marcado como completado",
                              context);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (builder) => RatingScreen(
                                        providerName: widget.providerName,
                                        providerId: widget.serviceProviderId,
                                        jobid: widget.uuid,
                                        clientId: widget.clientId,
                                        clientImage: widget.clientImage,
                                        clientName: widget.clientName,
                                        rating: widget.totalRating,
                                        serviceId: widget.serviceId,
                                      )));
                        }),
                  ),
                )
              ],
            )));
  }
}
