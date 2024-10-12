import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class PremiumFeature extends StatefulWidget {
  @override
  _PremiumFeatureState createState() => _PremiumFeatureState();
}

class _PremiumFeatureState extends State<PremiumFeature> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String userId = FirebaseAuth.instance.currentUser!.uid;
  String subscription = "basic";
  DateTime? subscriptionExpiry;
  int shareCount = 0;

  @override
  void initState() {
    super.initState();
    fetchSubscriptionData();
  }

  // Fetch user subscription data from Firestore
  Future<void> fetchSubscriptionData() async {
    var userDoc = await _firestore.collection('users').doc(userId).get();
    var data = userDoc.data();
    setState(() {
      subscription = data?['subscription'] ?? "basic";
      subscriptionExpiry = data?['subscriptionExpiry'] != null
          ? DateTime.parse(data?['subscriptionExpiry'])
          : null;
      shareCount = data?['shareCount'] ?? 0;
    });

    checkSubscriptionExpiration();
  }

  // Check if subscription has expired
  void checkSubscriptionExpiration() async {
    if (subscriptionExpiry != null &&
        DateTime.now().isAfter(subscriptionExpiry!)) {
      // Downgrade to basic if subscription has expired
      await _firestore.collection('users').doc(userId).update({
        'subscription': 'basic',
      });
      setState(() {
        subscription = 'basic';
      });
    }
  }

  // Share message on WhatsApp to unlock PRO
  Future<void> shareOnWhatsApp() async {
    String message = "I am using a new app, it is called Kelimbo. "
        "Download it here (app download link) or visit (landing page link).";
    String whatsappUrl = "whatsapp://send?text=${Uri.encodeComponent(message)}";

    if (await canLaunch(whatsappUrl)) {
      await launch(whatsappUrl);
      // After sharing on WhatsApp, update share count
      updateShareCount();
    } else {
      // Redirect to Play Store or App Store if WhatsApp is not installed
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                "WhatsApp is not installed on this device. Redirecting to install.")),
      );

      String playStoreUrl =
          "https://play.google.com/store/apps/details?id=com.whatsapp";
      if (await canLaunch(playStoreUrl)) {
        await launch(playStoreUrl);
      }
    }
  }

  // Update share count in Firestore
  Future<void> updateShareCount() async {
    setState(() {
      shareCount += 5; // WhatsApp limits to 5 shares per action
    });

    await _firestore.collection('users').doc(userId).update({
      'shareCount': shareCount,
    });

    // Check if 20 shares (4 rounds) are completed for PRO unlock
    if (shareCount >= 20) {
      unlockProSubscription();
    }
  }

  // Unlock PRO subscription for 2 months
  Future<void> unlockProSubscription() async {
    DateTime expiryDate = DateTime.now().add(Duration(days: 60)); // 2 months
    await _firestore.collection('users').doc(userId).update({
      'subscription': 'pro',
      'subscriptionExpiry': expiryDate.toIso8601String(),
    });

    setState(() {
      subscription = 'pro';
      subscriptionExpiry = expiryDate;
    });
  }

  // Show upgrade message when user attempts to access premium feature
  void showUpgradeMessage() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Upgrade to Premium"),
          content: Text(
              "This feature requires a premium subscription. Share the app to unlock the PRO level."),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                shareOnWhatsApp();
              },
              child: Text("Share on WhatsApp"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  // Build UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Kelimbo Subscription"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset("assets/logo.png"),
            Text("Subscription: $subscription"),
            if (subscriptionExpiry != null)
              Text("Expires on: ${subscriptionExpiry!.toLocal()}"),
            SizedBox(height: 20),
            buildSubscriptionBenefits(),
            ElevatedButton(
              onPressed: subscription == "basic" ? showUpgradeMessage : null,
              child: Text("Use Premium Feature"),
            ),
            if (shareCount >= 20)
              Text("You have unlocked the PRO level! Enjoy premium features."),
          ],
        ),
      ),
    );
  }

  Widget buildSubscriptionBenefits() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Subscription Benefits",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Text(
          "BASIC (Free):",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text("- Publish up to 1 listing per year."),
        Text("- Ads will be visible."),
        Text("- Cannot view received messages."),
        Text("- Cannot view ratings and comments."),
        Text("- 'Work Completed' button is inactive."),
        Text("- Receive requests but cannot send quotes."),
        SizedBox(height: 10),
        Text(
          "PREMIUM (Paid):",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text("- Publish unlimited listings per year."),
        Text("- Ad-free experience."),
        Text("- View and respond to received messages."),
        Text("- View ratings and comments from users."),
        Text("- 'Work Completed' button is fully enabled."),
        Text("- Provide and send quotes for requests."),
      ],
    );
  }
}
