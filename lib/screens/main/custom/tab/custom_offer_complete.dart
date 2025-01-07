import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:kelimbo/screens/main/pages/favourite_page.dart';
import 'package:kelimbo/utils/colors.dart';

class CustomOfferComplete extends StatefulWidget {
  const CustomOfferComplete({super.key});

  @override
  State<CustomOfferComplete> createState() => _CustomOfferCompleteState();
}

class _CustomOfferCompleteState extends State<CustomOfferComplete> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("offers")
            .where("clientId",
                isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .where("status", isEqualTo: "complete")
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
                  child: Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      title: Text(
                        'ProviderName: ${data['providerName']}',
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
                    SizedBox(
                        height: 140,
                        child:
                            Text(data['work'] ?? 'No description available')),
                    Text(
                      data['status'],
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
