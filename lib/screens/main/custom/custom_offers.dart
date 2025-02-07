import 'package:flutter/material.dart';
import 'package:kelimbo/screens/main/custom/tab/current_job.dart';
import 'package:kelimbo/screens/main/custom/tab/custom_offer_complete.dart';
import 'package:kelimbo/screens/main/custom/tab/custom_offer_completed.dart';
import 'package:kelimbo/screens/main/custom/tab/custom_offer_declined.dart';

class CustomOffers extends StatelessWidget {
  const CustomOffers({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        // floatingActionButton: FloatingActionButton(
        //   onPressed: () {
        //     Navigator.push(
        //         context,
        //         MaterialPageRoute(
        //             builder: (builder) => const SendCustomOffers()));
        //   },
        //   child: Icon(
        //     Icons.add,
        //     color: colorWhite,
        //   ),
        //   backgroundColor: mainColor,
        // ),
        appBar: AppBar(
          bottom: const TabBar(
            labelStyle: TextStyle(fontSize: 10),
            unselectedLabelStyle: TextStyle(fontSize: 10),
            tabs: [
              Tab(text: "Pendiente"), //Recived

              //    Tab(text: "Recibidas"), //Recived
              Tab(text: "Aceptadas"), // Accepted
              Tab(text: 'Rechazadas'), // Rejected
              Tab(text: "Completadas"), //Comm=
            ],
          ),
          title: Text('Oferta Personalizada'),
        ),
        body: TabBarView(
          children: [
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
