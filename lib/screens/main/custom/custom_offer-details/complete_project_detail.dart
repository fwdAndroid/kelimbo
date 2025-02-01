import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kelimbo/utils/colors.dart';
import 'package:kelimbo/utils/image_utils.dart';
import 'package:kelimbo/widgets/currecysymbal.dart';
import 'package:kelimbo/widgets/save_button.dart';
import 'dart:math';
import 'package:kelimbo/screens/main/main_dashboard.dart';

class CompleteProjectDetail extends StatefulWidget {
  final String serviceId;
  final String price;
  final String providerName;
  final String providerId;
  final String description;
  final String currency;
  final String currentOfferId;
  final String clientName;
  final String clientImage;

  CompleteProjectDetail({
    Key? key,
    required this.serviceId,
    required this.description,
    required this.price,
    required this.providerName,
    required this.currency,
    required this.providerId,
    required this.clientName,
    required this.currentOfferId,
    required this.clientImage,
  }) : super(key: key);

  @override
  State<CompleteProjectDetail> createState() => _CompleteProjectDetailState();
}

class _CompleteProjectDetailState extends State<CompleteProjectDetail> {
  double rating = 3;
  TextEditingController descriptionController = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Description:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 150,
                child: Text(
                  widget.description,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Price:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                widget.price.toString() +
                    " " +
                    getCurrencySymbol(widget.currency),
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              const Text(
                "Status:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              // Here we use a FutureBuilder to load the offer details
              FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('offers')
                    .doc(widget.currentOfferId)
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text("Error: ${snapshot.error}");
                  }
                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return const Text("Offer not found.");
                  }

                  final data = snapshot.data!.data() as Map<String, dynamic>;
                  final isRated = data['isRated'] as bool? ?? false;

                  if (isRated) {
                    // If the offer is already rated, show a message.
                    return const Text(
                      "Offer is rated.",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.green,
                      ),
                    );
                  } else {
                    // If the offer is not rated, show the rating bar.
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Please rate this offer:",
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 10),
                        RatingBar.builder(
                          initialRating: 0,
                          minRating: 1,
                          allowHalfRating: true,
                          direction: Axis.horizontal,
                          itemCount: 5,
                          itemPadding:
                              const EdgeInsets.symmetric(horizontal: 4.0),
                          itemBuilder: (context, _) => const Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                          onRatingUpdate: (newRating) async {
                            // Update the Firestore document to mark the offer as rated.
                            setState(() {
                              rating = newRating;
                            });
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            controller: descriptionController,
                            maxLines: 4,
                            decoration: InputDecoration(
                              filled: true,
                              enabledBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(22)),
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
                        isLoading
                            ? Center(child: CircularProgressIndicator())
                            : SaveButton(
                                title: "Enviar calificación",
                                onTap: () async {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  try {
                                    // Reference to the specific service document
                                    DocumentReference serviceDocRef =
                                        FirebaseFirestore.instance
                                            .collection("services")
                                            .doc(widget.serviceId);

                                    // Retrieve the current document data
                                    DocumentSnapshot docSnapshot =
                                        await serviceDocRef.get();

                                    if (docSnapshot.exists) {
                                      // Extract current ratings and reviews data
                                      double currentTotalRate =
                                          (docSnapshot['totalRate'] ?? 0)
                                              .toDouble();
                                      int ratingCount =
                                          docSnapshot['ratingCount'] ?? 0;
                                      List<dynamic> finalReviews = List.from(
                                          docSnapshot['finalreviews'] ?? []);

                                      // Calculate new rating stats
                                      double newTotalRate =
                                          currentTotalRate + rating;
                                      int newRatingCount = ratingCount + 1;
                                      double newAverageRating = min(
                                          newTotalRate / newRatingCount, 5.0);
                                      String formattedRating =
                                          newAverageRating.toStringAsFixed(2);

                                      // Create the new review object
                                      Map<String, dynamic> newReview = {
                                        "jobId": widget.currentOfferId,
                                        "providerId": widget.providerId,
                                        "clientName": widget.clientName,
                                        "clientThought":
                                            descriptionController.text,
                                        "totalRate":
                                            double.parse(formattedRating),
                                        "photo": widget
                                            .clientImage, // Optional: Add client image if needed
                                      };

                                      // Append the new review to the existing list
                                      finalReviews.add(newReview);

                                      // Update Firestore document with the updated data
                                      await serviceDocRef.update({
                                        "totalRate": newTotalRate,
                                        "ratingCount": newRatingCount,
                                        "totalReviews":
                                            double.parse(formattedRating),
                                        "finalreviews":
                                            finalReviews, // Update the finalreviews array
                                      });
                                      await FirebaseFirestore.instance
                                          .collection("users")
                                          .doc(widget.providerId)
                                          .update({
                                        "totalRate": newTotalRate,
                                        "ratingCount": newRatingCount,
                                        "finalreviews":
                                            finalReviews, // Update the finalreviews array
                                        "totalReviews":
                                            double.parse(formattedRating),
                                      });
                                      await FirebaseFirestore.instance
                                          .collection("offers")
                                          .doc(widget.currentOfferId)
                                          .update({
                                        "isRated": true,
                                        "totalRate": newTotalRate,
                                        "ratingCount": newRatingCount,
                                        "finalreviews":
                                            finalReviews, // Update the finalreviews array
                                        "totalReviews":
                                            double.parse(formattedRating),
                                      });
                                      setState(() {
                                        isLoading = false;
                                      });
                                      showMessageBar(
                                          "Revisión enviada", context);
                                      // Navigate to the main dashboard or show a success message
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (builder) =>
                                                  MainDashboard()));
                                    } else {
                                      print("Service document does not exist.");
                                    }
                                  } catch (e) {
                                    print("Error updating rating: $e");
                                  }
                                },
                              ),
                      ],
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
