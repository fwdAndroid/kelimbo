import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kelimbo/screens/detail/offer_detail_client.dart';
import 'package:kelimbo/utils/colors.dart';

class ClientQuote extends StatefulWidget {
  const ClientQuote({super.key});

  @override
  State<ClientQuote> createState() => _ClientQuoteState();
}

class _ClientQuoteState extends State<ClientQuote> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("users")
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .snapshots(),
                builder: (context, AsyncSnapshot snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data == null) {
                    return Center(child: Text('No data available'));
                  }
                  var snap = snapshot.data;

                  return Column(
                    children: [
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child:
                              snap['image'] != null && snap['image'].isNotEmpty
                                  ? CircleAvatar(
                                      backgroundImage: NetworkImage(
                                        snap['image'],
                                      ),
                                      radius: 60,
                                    )
                                  : CircleAvatar(
                                      radius: 60,
                                      child: Icon(Icons.person, size: 60),
                                    ),
                        ),
                      ),
                      Text(
                        snap['fullName'],
                        style: GoogleFonts.workSans(
                            fontWeight: FontWeight.w900, fontSize: 22),
                      ),
                    ],
                  );
                }),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8, top: 8),
              child: Text(
                "Ver cotización del cliente",
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700, fontSize: 15),
              ),
            ),
            SizedBox(
              height: 500,
              child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("offers")
                      .where("clientId",
                          isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                      .where("status", isEqualTo: "newQuote")
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    if (snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Text(
                          "No hay ofertas disponibles",
                          style: TextStyle(color: colorBlack),
                        ),
                      );
                    }
                    return ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          final List<DocumentSnapshot> documents =
                              snapshot.data!.docs;
                          final Map<String, dynamic> data =
                              documents[index].data() as Map<String, dynamic>;
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (builder) => OfferDetailClient(
                                            clientName: data['clientName'],
                                            clientEmail: data['clientEmail'],
                                            clientId: data['clientId'],
                                            serviceId: data['serviceId'],
                                            clientImage: data['clientImage'],
                                            status: data['status'],
                                            totalRating:
                                                data['totalRating'].toString(),
                                            providerEmail:
                                                data['providerEmail'],
                                            providerImage:
                                                data['providerImage'],
                                            providerName: data['providerName'],
                                            priceprehr: data['pricePerHr']
                                                .toString()
                                                .toString(),
                                            work: data['work'],
                                            serviceDescription:
                                                data['serviceDescription'],
                                            price: data['price'].toString(),
                                            serviceProviderId:
                                                data['serviceProviderId'],
                                            uuid: data['uuid'],
                                            serviceTitle: data['serviceTitle'],
                                          )));
                            },
                            child: Card(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ListTile(
                                    trailing: Text(
                                      "€" + data['price'].toString(),
                                      style: GoogleFonts.inter(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20),
                                    ),
                                    leading: CircleAvatar(
                                      backgroundImage:
                                          NetworkImage(data['clientImage']),
                                    ),
                                    title: Text(
                                      data['clientName'],
                                      style: GoogleFonts.inter(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      "Descripciones de puestos de trabajo",
                                      style: GoogleFonts.inter(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      data['work'],
                                      style: GoogleFonts.inter(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 13),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        });
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
