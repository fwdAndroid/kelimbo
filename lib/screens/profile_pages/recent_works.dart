import 'package:flutter/material.dart';
import 'package:kelimbo/screens/tab_seller/seller_completed_work.dart';
import 'package:kelimbo/screens/tab_seller/seller_offer_accepted.dart';
import 'package:kelimbo/screens/tab_seller/seller_offer_declined.dart';
import 'package:kelimbo/screens/tab_seller/seller_offer_send_to_buyer.dart';
import 'package:kelimbo/screens/tab_seller/seller_recived_by_buyer.dart';

class RecentWorks extends StatefulWidget {
  const RecentWorks({super.key});

  @override
  State<RecentWorks> createState() => _RecentWorksState();
}

class _RecentWorksState extends State<RecentWorks> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          bottom: const TabBar(
            isScrollable: true,
            automaticIndicatorColorAdjustment: true,
            labelStyle: TextStyle(fontSize: 12),
            unselectedLabelStyle: TextStyle(fontSize: 12),
            tabs: [
              Tab(text: "Pendientes"),
              Tab(text: "Enviados"),
              Tab(text: 'Aceptados'),
              Tab(text: "Rechazados"),
              Tab(
                text: "Completados",
              )
            ],
          ),
          title: Text('Presupuestos'),
        ),
        body: TabBarView(
          children: [
            SellerReceivedByBuyer(), // Seller Recived Offers
            SellerOfferSendToBuyer(), // Seller  Sent
            SellerOfferAccepted(), //Seller Offer Accepted
            SellerOfferDeclined(), // Seller Rejected
            SellerCompletedWork(), // Seller Completed
          ],
        ),
      ),
    );
  }
}
