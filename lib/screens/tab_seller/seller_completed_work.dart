import 'package:flutter/material.dart';
import 'package:kelimbo/screens/main/pages/favourite_page.dart';
import 'package:kelimbo/screens/tab_seller/tab_seller_detail/complete_seller_Detail.dart';
import 'package:kelimbo/seller_provider/seller_provider.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kelimbo/utils/colors.dart';

class SellerCompletedWork extends StatefulWidget {
  const SellerCompletedWork({super.key});

  @override
  State<SellerCompletedWork> createState() => _SellerCompletedWorkState();
}

class _SellerCompletedWorkState extends State<SellerCompletedWork> {
  @override
  void initState() {
    super.initState();
    // Fetch declined offers when the widget is initialized
    Provider.of<SellerReceivedProvider>(context, listen: false)
        .fetchCompleteOffers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<SellerReceivedProvider>(
        builder: (context, provider, child) {
          if (provider.completedOffers.isEmpty) {
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
            itemCount: provider.declinedOffers.length,
            itemBuilder: (context, index) {
              final data = provider.declinedOffers[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CompleteSellerDetail(
                              clientImage: data['clientImage'],
                              clientName: data['clientName'],
                              clientId: data['clientId'],
                              serviceId: data['serviceId'],
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
