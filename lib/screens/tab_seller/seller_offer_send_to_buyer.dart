import 'package:flutter/material.dart';
import 'package:kelimbo/screens/main/pages/favourite_page.dart';
import 'package:kelimbo/seller_provider/seller_provider.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kelimbo/screens/tab_seller/tab_seller_detail/seller_send_detail.dart';
import 'package:kelimbo/utils/colors.dart';

class SellerOfferSendToBuyer extends StatefulWidget {
  const SellerOfferSendToBuyer({super.key});

  @override
  State<SellerOfferSendToBuyer> createState() => _SellerOfferSendToBuyerState();
}

class _SellerOfferSendToBuyerState extends State<SellerOfferSendToBuyer> {
  @override
  void initState() {
    super.initState();
    // Fetch sent offers when the widget is initialized
    Provider.of<SellerReceivedProvider>(context, listen: false)
        .fetchSentOffers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<SellerReceivedProvider>(
        builder: (context, provider, child) {
          if (provider.sentOffers.isEmpty) {
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
            itemCount: provider.sentOffers.length,
            itemBuilder: (context, index) {
              final data = provider.sentOffers[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SellerSendDetail(
                        serviceId: data['serviceId'],
                        clientId: data['clientId'],
                        clientImage: data['clientImage'],
                        clientName: data['clientName'],
                        status: data['status'],
                        uuid: data['uuid'],
                        clientEmail: data['clientEmail'],
                        description: data['work'],
                        currency: data['currencyType'],
                        price: data['price'],
                      ),
                    ),
                  );
                },
                child: Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        leading: CircleAvatar(
                          backgroundImage:
                              NetworkImage(data['clientImage'] ?? ""),
                        ),
                        title: Text(
                          data['clientName'],
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
                          "Servicio Solicitado",
                          style: TextStyle(
                              color: colorBlack,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(data['work'] ?? 'No description available'),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SellerSendDetail(
                                    clientImage: data['clientImage'],
                                    clientName: data['clientName'],
                                    clientId: data['clientId'],
                                    serviceId: data['serviceId'],
                                    status: data['status'],
                                    clientEmail: data['clientEmail'],
                                    uuid: data['uuid'],
                                    description: data['work'],
                                    currency: data['currencyType'],
                                    price: data['price'],
                                  ),
                                ),
                              );
                            },
                            child: Text("Ver detalle")),
                      )
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
