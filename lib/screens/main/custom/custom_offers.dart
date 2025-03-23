import 'package:flutter/material.dart';
import 'package:kelimbo/screens/main/custom/tab/current_job.dart';
import 'package:kelimbo/screens/main/custom/tab/custom_offer_complete.dart';
import 'package:kelimbo/screens/main/custom/tab/custom_offer_completed.dart';
import 'package:kelimbo/screens/main/custom/tab/custom_offer_declined.dart';
import 'package:kelimbo/screens/main/custom/tab/pending_offer.dart';

class CustomOffers extends StatelessWidget {
  const CustomOffers({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          bottom: const TabBar(
            isScrollable: true,
            labelStyle: TextStyle(fontSize: 10),
            unselectedLabelStyle: TextStyle(fontSize: 10),
            tabs: [
              Tab(text: "Pendientes"), //Pending

              Tab(text: "Recibidas"), //Recived
              Tab(text: "Aceptadas"), // Accepted
              Tab(text: 'Rechazadas'), // Rejected
              Tab(text: "Completadas"), //Comm=
            ],
          ),
          title: Text('Ofertas Personalizadas'),
        ),
        body: TabBarView(
          children: [
            PendingOffer(),
            CustomOfferCompleted(), //Recived
            CurrentJob(), // Accepte
            CustomOfferDeclined(), // Declined
            CustomOfferComplete(), // Complete
          ],
        ),
      ),
    );
  }
}
