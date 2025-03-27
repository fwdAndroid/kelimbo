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
  Map<String, dynamic>? existingRatingData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus(); // Hide keyboard on button
        },
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Descripción:",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.description,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Precio:",
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
                  "Estado:",
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
                      // If the offer is already rated, show the rating details
                      return FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('services')
                            .doc(widget.serviceId)
                            .get(),
                        builder: (context, serviceSnapshot) {
                          if (serviceSnapshot.hasError) {
                            return Text(
                                "Error loading rating: ${serviceSnapshot.error}");
                          }
                          if (!serviceSnapshot.hasData ||
                              !serviceSnapshot.data!.exists) {
                            return const Text("Service data not found");
                          }

                          final serviceData = serviceSnapshot.data!.data()
                              as Map<String, dynamic>;
                          final reviews =
                              serviceData['finalreviews'] as List<dynamic>? ??
                                  [];

                          // Find the review for this specific job
                          Map<String, dynamic>? jobReview;
                          for (var review in reviews) {
                            if (review['jobId'] == widget.currentOfferId) {
                              jobReview = review;
                              break;
                            }
                          }

                          if (jobReview == null) {
                            return const Text("No rating details found");
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Valoración:",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const Text(
                                "La oferta está valorada..",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.green,
                                ),
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  RatingBar.builder(
                                    initialRating:
                                        jobReview['totalRate']?.toDouble() ?? 0,
                                    minRating: 0,
                                    maxRating: 5,
                                    ignoreGestures:
                                        true, // Make it non-interactive
                                    itemSize: 30,
                                    itemBuilder: (context, _) => Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                    ),
                                    onRatingUpdate: (rating) {},
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    "${jobReview['totalRate']?.toStringAsFixed(1) ?? '0.0'}/5",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12),
                              if (jobReview['clientThought'] != null &&
                                  jobReview['clientThought']
                                      .toString()
                                      .isNotEmpty)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Comentario:",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      jobReview['clientThought'],
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                            ],
                          );
                        },
                      );
                    } else {
                      // If the offer is not rated, show the rating bar.
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Por favor, valora este trabajo:",
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
                                  title: "Enviar Valoración",
                                  onTap: () async {
                                    setState(() {
                                      isLoading = true;
                                    });
                                    FocusScope.of(context)
                                        .unfocus(); // Hide keyboard on button
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
                                          "photo": widget.clientImage,
                                        };

                                        // Append the new review to the existing list
                                        finalReviews.add(newReview);

                                        // Update Firestore document with the updated data
                                        await serviceDocRef.update({
                                          "totalRate": newTotalRate,
                                          "ratingCount": newRatingCount,
                                          "totalReviews":
                                              double.parse(formattedRating),
                                          "finalreviews": finalReviews,
                                          "numberOfJobs":
                                              FieldValue.increment(1)
                                        });
                                        await FirebaseFirestore.instance
                                            .collection("users")
                                            .doc(widget.providerId)
                                            .update({
                                          "totalRate": newTotalRate,
                                          "ratingCount": newRatingCount,
                                          "finalreviews": finalReviews,
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
                                          "finalreviews": finalReviews,
                                          "totalReviews":
                                              double.parse(formattedRating),
                                        });
                                        setState(() {
                                          isLoading = false;
                                        });
                                        showMessageBar(
                                            "Valoración enviada", context);
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (builder) =>
                                                    MainDashboard()));
                                      } else {
                                        print(
                                            "Service document does not exist.");
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
      ),
    );
  }

  void showMessageBar(String message, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
