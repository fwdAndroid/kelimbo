import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class BuyerProvider with ChangeNotifier {
  List<Map<String, dynamic>> _buyerpendingOffers = [];
  List<Map<String, dynamic>> _buyerstartOffers = [];
  List<Map<String, dynamic>> _buyercounterOffers = [];
  List<Map<String, dynamic>> _buyerdeclineOffers = [];
  List<Map<String, dynamic>> _buyercompleteOffers = [];

  List<Map<String, dynamic>> get buyerpendingOffers => _buyerpendingOffers;
  List<Map<String, dynamic>> get buyercounterOffers => _buyercounterOffers;
  List<Map<String, dynamic>> get buyerstartOffers => _buyerstartOffers;
  List<Map<String, dynamic>> get buyerdeclineOffers => _buyerdeclineOffers;
  List<Map<String, dynamic>> get buyercompleteOffers => _buyercompleteOffers;

  Future<void> fetchPendingdOffers() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection("offers")
        .where("clientId", isEqualTo: user.uid)
        .where("status", isEqualTo: "send")
        .get();

    _buyerpendingOffers =
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

    _buyercounterOffers =
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

    _buyerstartOffers =
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

    _buyerdeclineOffers =
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

    _buyercompleteOffers =
        snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    notifyListeners();
  }
}
