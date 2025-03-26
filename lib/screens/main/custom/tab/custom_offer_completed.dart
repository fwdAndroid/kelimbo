import 'package:flutter/material.dart';
import 'package:kelimbo/screens/main/custom/custom_offer-details/custom_offers_complete_detail.dart';
import 'package:kelimbo/screens/main/other/offers_profile.dart';
import 'package:kelimbo/screens/main/pages/favourite_page.dart';
import 'package:kelimbo/seller_provider/buyer_provider.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kelimbo/utils/colors.dart';

class CustomOfferCompleted extends StatefulWidget {
  const CustomOfferCompleted({super.key});

  @override
  State<CustomOfferCompleted> createState() => _CustomOfferCompletedState();
}

class _CustomOfferCompletedState extends State<CustomOfferCompleted> {
  @override
  void initState() {
    super.initState();
    Provider.of<BuyerProvider>(context, listen: false).fetchCounterOffers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<BuyerProvider>(
        builder: (context, provider, child) {
          if (provider.buyercounterOffers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 100,
                    color: Colors.grey,
                  ),
                  Text(
                    'No counter offers available.',
                    style: GoogleFonts.inter(fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: provider.buyercounterOffers.length,
            itemBuilder: (context, index) {
              final data = provider.buyercounterOffers[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CompleteCustomOfferDetail(
                        status: data['status'],
                        uuid: data['uuid'],
                        description: data['work'],
                        currency: data['currencyType'],
                        price: data['price'],
                      ),
                    ),
                  );
                },
                child: Card(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                                  serviceProviderId: data['serviceProviderId'],
                                ),
                              ),
                            );
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
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Descripciónes de puestos de trabajo",
                          style: TextStyle(
                            color: colorBlack,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(data['work'] ?? 'No description available'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
