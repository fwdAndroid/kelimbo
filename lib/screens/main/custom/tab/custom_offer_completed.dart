import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kelimbo/screens/main/custom/custom_offer-details/custom_offers_complete_detail.dart';
import 'package:kelimbo/screens/main/pages/favourite_page.dart';
import 'package:kelimbo/utils/colors.dart';

class CustomOfferCompleted extends StatefulWidget {
  const CustomOfferCompleted({super.key});

  @override
  State<CustomOfferCompleted> createState() => _CustomOfferCompletedState();
}

class _CustomOfferCompletedState extends State<CustomOfferCompleted> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("customOffers")
            .where("userId", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .where("status", isEqualTo: "completed")
            .snapshots(),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No custom offers available.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final Map<String, dynamic> data =
                  snapshot.data!.docs[index].data() as Map<String, dynamic>;
              return GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CompleteCustomOfferDetail(
                                status: data['status'],
                                uuid: data['offerId'],
                                description: data['description'],
                                currency: data['currency'],
                                price: data['price'])));
                  },
                  child: Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          title: Text(
                            'ProviderName: ${data['serviceProviderName']}',
                            style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          subtitle: Text(
                            "${getCurrencySymbol(data['currency'] ?? 'Euro')}${data['price'] ?? '0.0'}",
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                        Text(
                          "Description",
                          style: TextStyle(
                              color: colorBlack,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                        Text(data['description'] ?? 'No description available'),
                        Text(
                          data['status'] ?? 'No description available',
                          style: TextStyle(color: Colors.green),
                        ),
                      ],
                    ),
                  ));
            },
          );
        },
      ),
    );
  }
}
