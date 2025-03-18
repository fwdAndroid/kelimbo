import 'package:flutter/material.dart';
import 'package:kelimbo/screens/budget_screen/accepted_jobs_detail.dart';
import 'package:kelimbo/screens/main/custom/custom_offer-details/custom_delined_offer_detail.dart';
import 'package:kelimbo/screens/main/other/offers_profile.dart';
import 'package:kelimbo/screens/main/pages/favourite_page.dart';
import 'package:kelimbo/seller_provider/buyer_provider.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kelimbo/utils/colors.dart';

class CustomOfferDeclined extends StatefulWidget {
  const CustomOfferDeclined({super.key});

  @override
  State<CustomOfferDeclined> createState() => _CustomOfferDeclinedState();
}

class _CustomOfferDeclinedState extends State<CustomOfferDeclined> {
  @override
  void initState() {
    super.initState();
    // Fetch offers when the widget is initialized
    Provider.of<BuyerProvider>(context, listen: false).fetchDeclinedOffers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<BuyerProvider>(
        builder: (context, provider, child) {
          if (provider.declineOffers.isEmpty) {
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
            itemCount: provider.declineOffers.length,
            itemBuilder: (context, index) {
              final data = provider.declineOffers[index];
              return GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CustomDeclinedOfferDetail(
                                clientId: data['clientId'],
                                clientImage: data['clientImage'],
                                clientName: data['clientName'],
                                serviceId: data['serviceId'],
                                status: data['status'],
                                uuid: data['uuid'],
                                description: data['serviceDescription'],
                                observation: data['observation'],
                                currency: data['currency'],
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
