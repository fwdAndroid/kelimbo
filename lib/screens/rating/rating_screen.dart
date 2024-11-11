import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:kelimbo/screens/main/main_dashboard.dart';
import 'package:kelimbo/utils/colors.dart';
import 'package:kelimbo/widgets/save_button.dart';

class RatingScreen extends StatefulWidget {
  final providerId;
  final serviceId;
  final jobid;
  final clientId;
  final clientName;
  final clientImage;
  final rating;
  RatingScreen(
      {super.key,
      required this.clientImage,
      required this.clientId,
      required this.providerId,
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
              "Pro favor cuentanos como fue tu experiencia con nuestro proveedor",
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
                allowHalfRating: true,
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
              maxLength: 30,
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
            title: "Submit Rating",
            onTap: () async {
              try {
                // Reference to the specific service document
                DocumentReference serviceDocRef = FirebaseFirestore.instance
                    .collection("services")
                    .doc(widget.serviceId);

                // Retrieve the current rating data from the document
                DocumentSnapshot docSnapshot = await serviceDocRef.get();
                if (docSnapshot.exists) {
                  int currentTotalRate = docSnapshot['totalRate'] ?? 0;
                  int ratingCount = docSnapshot['ratingCount'] ?? 0;

                  // Convert the rating to an integer, if necessary
                  int intRating = rating.toInt();

                  // Add new rating to the total rate and increment the rating count
                  int newTotalRate = currentTotalRate + intRating;
                  int newRatingCount = ratingCount + 1;

                  // Calculate the new average rating (as a double for precision)
                  double newAverageRating = newTotalRate / newRatingCount;

                  // Update Firestore with new total rate, rating count, and average rating
                  await serviceDocRef.update({
                    "totalRate": newTotalRate,
                    "ratingCount": newRatingCount,
                    "totalReviews":
                        newAverageRating, // store as double for precision
                  });

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
        ],
      ),
    );
  }
}
