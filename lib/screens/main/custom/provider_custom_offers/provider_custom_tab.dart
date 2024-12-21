import 'package:flutter/material.dart';
import 'package:kelimbo/screens/main/custom/provider_custom_offers/provider_tab_pages/accpt_provider_offers.dart';
import 'package:kelimbo/screens/main/custom/provider_custom_offers/provider_tab_pages/provider_completed_jobs.dart';
import 'package:kelimbo/screens/main/custom/provider_custom_offers/provider_tab_pages/view_provider_offers.dart';

class ProviderCustomTab extends StatefulWidget {
  const ProviderCustomTab({super.key});

  @override
  State<ProviderCustomTab> createState() => _ProviderCustomTabState();
}

class _ProviderCustomTabState extends State<ProviderCustomTab> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            isScrollable: true, // Allows tabs to scroll and show complete text

            tabs: [
              Tab(text: "Jobs Offers"),
              Tab(text: "Accepted Jobs"),
              Tab(text: "Completed Jobs"),
            ],
          ),
          title: Text('Offers Personalizada'),
        ),
        body: TabBarView(
          children: [
            ViewProviderOffers(),
            AccptProviderOffers(),
            CompletedProviderJobs(),
          ],
        ),
      ),
    );
  }
}
