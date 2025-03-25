import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SellerReceivedProvider with ChangeNotifier {
  List<Map<String, dynamic>> _receivedOffers = [];
  List<Map<String, dynamic>> _sentOffers = [];
  List<Map<String, dynamic>> _acceptedOffers = [];
  List<Map<String, dynamic>> _offers = [];
  List<Map<String, dynamic>> _declinedOffers = [];
  List<Map<String, dynamic>> _completedOffers = [];

  List<Map<String, dynamic>> get receivedOffers => _receivedOffers;
  List<Map<String, dynamic>> get sentOffers => _sentOffers;
  List<Map<String, dynamic>> get acceptedOffers => _acceptedOffers;
  List<Map<String, dynamic>> get offers => _offers;
  List<Map<String, dynamic>> get declinedOffers => _declinedOffers;
  List<Map<String, dynamic>> get completedOffers => _completedOffers;

  Future<void> fetchSentOffers() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection("offers")
        .where("serviceProviderId", isEqualTo: user.uid)
        .where("status", isEqualTo: "counterOffer")
        .get();

    _sentOffers =
        snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    notifyListeners();
  }

  Future<void> fetchAcceptedOffers() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection("offers")
        .where("serviceProviderId", isEqualTo: user.uid)
        .where("status", isEqualTo: "start")
        .get();

    _acceptedOffers =
        snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    notifyListeners();
  }

  Future<void> fetchOffers() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection("offers")
        .where("serviceProviderId", isEqualTo: user.uid)
        .where("status", isEqualTo: "send")
        .get();

    _offers =
        snapshot.docs.map((doc) => {"uuid": doc.id, ...doc.data()}).toList();
    notifyListeners();
  }

  Future<void> fetchDeclinedOffers() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection("offers")
        .where("serviceProviderId", isEqualTo: user.uid)
        .where("status", isEqualTo: "reject")
        .get();

    _declinedOffers =
        snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    notifyListeners();
  }

  Future<void> fetchCompleteOffers() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection("offers")
        .where("serviceProviderId", isEqualTo: user.uid)
        .where("status", isEqualTo: "complete")
        .get();

    _declinedOffers =
        snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    notifyListeners();
  }

  //rEMOVED oFFER
  void removeOffer(String uuid) {
    _offers.removeWhere((offer) => offer['uuid'] == uuid);
    notifyListeners();
  }
}
