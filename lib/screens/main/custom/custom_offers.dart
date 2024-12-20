import 'package:flutter/material.dart';
import 'package:kelimbo/screens/main/custom/send_custom_offers.dart';
import 'package:kelimbo/screens/main/custom/tab/current_job.dart';
import 'package:kelimbo/screens/main/custom/tab/custom_offer.dart';
import 'package:kelimbo/utils/colors.dart';

class CustomOffers extends StatelessWidget {
  const CustomOffers({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (builder) => const SendCustomOffers()));
          },
          child: Icon(
            Icons.add,
            color: colorWhite,
          ),
          backgroundColor: mainColor,
        ),
        appBar: AppBar(
          bottom: TabBar(
            tabs: [
              Tab(text: "Current Job"),
              Tab(text: "Send Custom Offer"),
            ],
          ),
          title: Text('Offers Personalizada'),
        ),
        body: TabBarView(
          children: [
            CurrentJob(),
            CustomOffer(),
          ],
        ),
      ),
    );
  }
}
