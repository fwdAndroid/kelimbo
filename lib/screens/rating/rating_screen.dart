import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:kelimbo/screens/main/main_dashboard.dart';
import 'package:kelimbo/utils/colors.dart';
import 'package:kelimbo/utils/image_utils.dart';
import 'package:kelimbo/widgets/save_button.dart';

class RatingScreen extends StatefulWidget {
  final providerId; // Client ID which service will be listed
  final providerName;
  final serviceId; //Service ID
  final jobid; // current JOb
  final clientId; // user id
  final clientName;
  final clientImage;
  final rating;

  RatingScreen(
      {super.key,
      required this.clientImage,
      required this.clientId,
      required this.providerId,
      required this.providerName,
      required this.jobid,
      required this.clientName,
      required this.rating,
      required this.serviceId});

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  TextEditingController descriptionController = TextEditingController();
  double rating = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Calificar servicio",
              style:
                  GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Por favor cuéntanos cómo fue tu experiencia con ${widget.providerName}",
              style: GoogleFonts.inter(color: Color(0xff240F51), fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: RatingBar.builder(
                initialRating: rating,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: false,
                itemCount: 5,
                itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                onRatingUpdate: (newRating) {
                  setState(() {
                    rating = newRating;
                  });
                }),
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
          SaveButton(
            title: "Enviar calificación",
            onTap: () async {
              try {
                // Reference to the specific service document
                DocumentReference serviceDocRef = FirebaseFirestore.instance
                    .collection("services")
                    .doc(widget.serviceId);

                // Retrieve the current document data
                DocumentSnapshot docSnapshot = await serviceDocRef.get();

                if (docSnapshot.exists) {
                  // Extract current ratings and reviews data
                  double currentTotalRate =
                      (docSnapshot['totalRate'] ?? 0).toDouble();
                  int ratingCount = docSnapshot['ratingCount'] ?? 0;
                  List<dynamic> finalReviews =
                      List.from(docSnapshot['finalreviews'] ?? []);

                  // Calculate new rating stats
                  double newTotalRate = currentTotalRate + rating;
                  int newRatingCount = ratingCount + 1;
                  double newAverageRating =
                      min(newTotalRate / newRatingCount, 5.0);
                  String formattedRating = newAverageRating.toStringAsFixed(2);

                  // Create the new review object
                  Map<String, dynamic> newReview = {
                    "jobId": widget.jobid,
                    "providerId": widget.providerId,
                    "clientName": widget.clientName,
                    "clientThought": descriptionController.text,
                    "totalRate": double.parse(formattedRating),
                    "photo": widget
                        .clientImage, // Optional: Add client image if needed
                  };

                  // Append the new review to the existing list
                  finalReviews.add(newReview);

                  // Update Firestore document with the updated data
                  await serviceDocRef.update({
                    "totalRate": newTotalRate,
                    "ratingCount": newRatingCount,
                    "totalReviews": double.parse(formattedRating),
                    "finalreviews":
                        finalReviews, // Update the finalreviews array
                  });
                  await FirebaseFirestore.instance
                      .collection("users")
                      .doc(widget.providerId)
                      .update({
                    "numberofjobs": FieldValue.increment(1),
                    "totalRate": newTotalRate,
                    "ratingCount": newRatingCount,
                    "finalreviews":
                        finalReviews, // Update the finalreviews array
                    "totalReviews": double.parse(formattedRating),
                  });
                  await FirebaseFirestore.instance
                      .collection("offers")
                      .doc(widget.jobid)
                      .update({
                    "isRated": true,
                    "totalRate": newTotalRate,
                    "ratingCount": newRatingCount,
                    "finalreviews":
                        finalReviews, // Update the finalreviews array
                    "totalReviews": double.parse(formattedRating),
                  });
                  showMessageBar("Valoración enviada", context);
                  // Navigate to the main dashboard or show a success message
                  Navigator.push(context,
                      MaterialPageRoute(builder: (builder) => MainDashboard()));
                } else {
                  print("Service document does not exist.");
                }
              } catch (e) {
                print("Error updating rating: $e");
              }
            },
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "o",
              style: TextStyle(
                color: Colors.black,
              ),
            ),
          ),
          TextButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection("users")
                    .doc(widget.providerId)
                    .update({
                  "numberofjobs": FieldValue.increment(1),
                });
                Navigator.push(context,
                    MaterialPageRoute(builder: (builder) => MainDashboard()));
              },
              child: Text("Más Tarde")),
        ],
      ),
    );
  }
}
