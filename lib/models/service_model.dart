import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceModel {
  String uuid;
  int price;
  int pricePerHr;
  String photo;
  String description;
  String title;
  String category;
  String uid;
  List favorite;
  double totalRate; // Stores the total rate
  int totalReviews; // Stores the total number of reviews
  Map<String, int> reviews; // Stores reviews with corresponding ratings

  ServiceModel(
      {required this.uid,
      required this.title,
      required this.price,
      required this.pricePerHr,
      required this.description,
      required this.photo,
      required this.category,
      required this.favorite,
      required this.reviews,
      required this.totalRate,
      required this.totalReviews,
      required this.uuid});

  Map<String, dynamic> toJson() => {
        'price': price,
        'uid': uid,
        'pricePerHr': pricePerHr,
        'description': description,
        'photo': photo,
        'category': category,
        'title': title,
        'favorite': favorite,
        'uuid': uuid,
        'totalRate': totalRate, // Include in toJson
        'totalReviews': totalReviews, // Include in toJson
        'reviews': reviews, // Include reviews as a list of strings
      };
  static ServiceModel fromSnap(DocumentSnapshot snaps) {
    var snapshot = snaps.data() as Map<String, dynamic>;

    return ServiceModel(
        photo: snapshot['photo'],
        uid: snapshot['uid'],
        favorite: snapshot['favorite'],
        title: snapshot['title'],
        description: snapshot['description'],
        price: snapshot['price'],
        pricePerHr: snapshot['pricePerHr'],
        category: snapshot['category'],
        totalRate: snapshot['totalRate'], // Fetch from snapshot
        totalReviews: snapshot['totalReviews'], // Fetch from snapshot
        reviews: Map<String, int>.from(
            snapshot['reviews']), // Fetch reviews map from snapshot
        uuid: snapshot['uuid']);
  }
}
