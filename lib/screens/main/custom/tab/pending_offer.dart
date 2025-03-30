import 'package:flutter/material.dart';
import 'package:kelimbo/screens/main/custom/custom_offer-details/pending_oferta_detaills.dart';
import 'package:kelimbo/screens/main/other/offers_profile.dart';
import 'package:kelimbo/screens/main/pages/favourite_page.dart';
import 'package:kelimbo/seller_provider/buyer_provider.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kelimbo/utils/colors.dart';

class PendingOffer extends StatefulWidget {
  const PendingOffer({super.key});

  @override
  State<PendingOffer> createState() => _PendingOfferState();
}

class _PendingOfferState extends State<PendingOffer> {
  @override
  void initState() {
    super.initState();
    // Fetch offers when the widget is initialized
    Provider.of<BuyerProvider>(context, listen: false).fetchPendingdOffers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<BuyerProvider>(
        builder: (context, provider, child) {
          if (provider.buyerpendingOffers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 100,
                    color: Colors.grey,
                  ),
                  Text('No hay trabajo disponible.'),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: provider.buyerpendingOffers.length,
            itemBuilder: (context, index) {
              final data = provider.buyerpendingOffers[index];
              return GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PendingOfferDetailOferta(
                                providerName: data['providerName'],
                                serviceProviderId: data['serviceProviderId'],
                                providerImage: data['providerImage'],
                                serviceId: data['serviceId'],
                                providerEmail: data['providerEmail'],
                                status: data['status'],
                                uuid: data['uuid'],
                                description: data['work'],
                                currency: data['currencyType'],
                                price: data['price'])));
                  },
                  child: Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          leading: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (builder) => OffersProfile(
                                          serviceId: data['serviceId'],
                                          serviceProviderId:
                                              data['serviceProviderId'])));
                            },
                            child: CircleAvatar(
                              backgroundImage:
                                  NetworkImage(data['providerImage'] ?? ""),
                            ),
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
                            "Trabajo solicitado",
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
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            PendingOfferDetailOferta(
                                                serviceId: data['serviceId'],
                                                providerName:
                                                    data['providerName'],
                                                serviceProviderId:
                                                    data['serviceProviderId'],
                                                providerImage:
                                                    data['providerImage'],
                                                providerEmail:
                                                    data['providerEmail'],
                                                status: data['status'],
                                                uuid: data['uuid'],
                                                description: data['work'],
                                                currency: data['currencyType'],
                                                price: data['price'])));
                              },
                              child: Text("Ver detalles")),
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
