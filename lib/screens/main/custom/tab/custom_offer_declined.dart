import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kelimbo/screens/main/custom/custom_offer-details/custom_delined_offer_detail.dart';
import 'package:kelimbo/screens/main/pages/favourite_page.dart';
import 'package:kelimbo/utils/colors.dart';

class CustomOfferDeclined extends StatefulWidget {
  const CustomOfferDeclined({super.key});

  @override
  State<CustomOfferDeclined> createState() => _CustomOfferDeclinedState();
}

class _CustomOfferDeclinedState extends State<CustomOfferDeclined> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("offers")
            .where("clientId",
                isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .where("status", isEqualTo: "reject")
            .snapshots(),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No hay trabajo disponible.'));
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
                            builder: (context) => CustomDeclinedOfferDetail(
                                status: data['status'],
                                uuid: data['uuid'],
                                description: data['serviceDescription'],
                                currency: data['currency'],
                                price: data['price'])));
                  },
                  child: Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          leading: CircleAvatar(
                            backgroundImage:
                                NetworkImage(data['providerImage'] ?? ""),
                          ),
                          title: Text(
                            data['providerName'],
                            style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          trailing: Text(
                            "${getCurrencySymbol(data['currency'] ?? 'Euro')}${data['price'] ?? '0.0'}",
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Descripciónes de puestos de trabajo",
                            style: TextStyle(
                                color: colorBlack,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                              data['work'] ?? 'No hay descripción disponible'),
                        )
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
