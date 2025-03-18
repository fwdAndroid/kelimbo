import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class BuyerProvider with ChangeNotifier {
  List<Map<String, dynamic>> _pendingOffers = [];
  List<Map<String, dynamic>> _startOffers = [];
  List<Map<String, dynamic>> _counterOffers = [];
  List<Map<String, dynamic>> _declineOffers = [];
  List<Map<String, dynamic>> _completeOffers = [];

  List<Map<String, dynamic>> get pendingOffers => _pendingOffers;
  List<Map<String, dynamic>> get counterOffers => _counterOffers;
  List<Map<String, dynamic>> get startOffers => _startOffers;
  List<Map<String, dynamic>> get declineOffers => _declineOffers;
  List<Map<String, dynamic>> get completeOffers => _completeOffers;

  Future<void> fetchPendingdOffers() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection("offers")
        .where("clientId", isEqualTo: user.uid)
        .where("status", isEqualTo: "send")
        .get();

    _pendingOffers =
        snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    notifyListeners();
  }

  Future<void> fetchCounterOffers() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection("offers")
        .where("clientId", isEqualTo: user.uid)
        .where("status", isEqualTo: "counterOffer")
        .get();

    _counterOffers =
        snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    notifyListeners();
  }

  Future<void> fetchStartOffers() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection("offers")
        .where("clientId", isEqualTo: user.uid)
        .where("status", isEqualTo: "start")
        .get();

    _counterOffers =
        snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    notifyListeners();
  }

  Future<void> fetchDeclinedOffers() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection("offers")
        .where("clientId", isEqualTo: user.uid)
        .where("status", isEqualTo: "reject")
        .get();

    _counterOffers =
        snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    notifyListeners();
  }

  Future<void> fetchCompleteOffers() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection("offers")
        .where("clientId", isEqualTo: user.uid)
        .where("status", isEqualTo: "complete")
        .get();

    _counterOffers =
        snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    notifyListeners();
  }
}
