import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kelimbo/screens/budget_screen/accepted_jobs_detail.dart';
import 'package:kelimbo/screens/main/pages/favourite_page.dart';
import 'package:kelimbo/utils/colors.dart';

class CurrentJob extends StatefulWidget {
  const CurrentJob({super.key});

  @override
  State<CurrentJob> createState() => _CurrentJobState();
}

class _CurrentJobState extends State<CurrentJob> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("offers")
            .where("clientId",
                isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .where("status", isEqualTo: "start")
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
                            builder: (context) => AcceptedJobsDetail(
                                  serviceId: data['serviceId'],
                                  currency: data['currencyType'],
                                  clientName: data['clientName'],
                                  clientEmail: data['clientEmail'],
                                  clientId: data['clientId'],
                                  clientImage: data['clientImage'],
                                  status: data['status'],
                                  totalRating: data['totalRating'].toString(),
                                  providerEmail: data['providerEmail'],
                                  providerImage: data['providerImage'],
                                  providerName: data['providerName'],
                                  priceprehr:
                                      data['pricePerHr'].toString().toString(),
                                  work: data['work'],
                                  serviceDescription:
                                      data['serviceDescription'],
                                  price: data['price'].toString(),
                                  serviceProviderId: data['serviceProviderId'],
                                  uuid: data['uuid'],
                                  serviceTitle: data['serviceTitle'],
                                )));
                  },
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
                            child: Text(
                                data['work'] ?? 'No description available')),
                        Text(
                          "Accepted",
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
