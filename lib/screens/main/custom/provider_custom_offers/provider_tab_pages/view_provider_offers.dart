import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kelimbo/screens/main/custom/provider_custom_offers/provider_details/view_provider_detail.dart';
import 'package:kelimbo/screens/main/pages/favourite_page.dart';
import 'package:kelimbo/utils/colors.dart';

class ViewProviderOffers extends StatefulWidget {
  const ViewProviderOffers({super.key});

  @override
  State<ViewProviderOffers> createState() => _ViewProviderOffersState();
}

class _ViewProviderOffersState extends State<ViewProviderOffers> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("customOffers")
            .where("serviceProviderId",
                isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .where("status", isEqualTo: "pending")
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
              return Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      title: Text(
                        'User Name: ${data['userName']}',
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
                    // Text(
                    //   data['status'] ?? 'No description available',
                    //   style: TextStyle(color: Colors.green),
                    // ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                            onPressed: () async {
                              await FirebaseFirestore.instance
                                  .collection("customOffers")
                                  .doc(data['offerId'])
                                  .update({"status": "accepted"});
                            },
                            child: Text(
                              "Accept",
                              style: TextStyle(color: Colors.green),
                            )),
                        TextButton(
                            onPressed: () async {
                              await FirebaseFirestore.instance
                                  .collection("customOffers")
                                  .doc(data['offerId'])
                                  .update({"status": "declined"});
                            },
                            child: Text(
                              "Declined",
                              style: TextStyle(color: Colors.green),
                            )),
                        TextButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ViewProviderDetail(
                                          status: data['status'] ?? "NA",
                                          uuid: data['offerId'] ?? "NA",
                                          description:
                                              data['description'] ?? "NA",
                                          currency: data['currency'] ?? "NA",
                                          price: data['price'] ?? "NA")));
                            },
                            child: Text("View Details"))
                      ],
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
