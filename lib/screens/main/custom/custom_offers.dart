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
            labelStyle: TextStyle(fontSize: 12),
            unselectedLabelStyle: TextStyle(fontSize: 12),
            tabs: [
              Tab(text: "Accepted"),
              Tab(text: "Completed"),
              Tab(text: 'Received'),
              Tab(text: "Declined"),
            ],
          ),
          title: Text('Offers Personalizada'),
        ),
        body: TabBarView(
          children: [
            CurrentJob(), // Accepte
            CustomOfferComplete(), // Complete
            CustomOfferCompleted(), //Recived
            CustomOfferDeclined(), // Declined
          ],
        ),
      ),
    );
  }
}
