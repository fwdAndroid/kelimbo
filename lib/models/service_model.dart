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
  String userName;
  String userImage;
  String userEmail;
  String currency;
  String priceType;
  int ratingCount;

  ServiceModel(
      {required this.uid,
      required this.title,
      required this.price,
      required this.ratingCount,
      required this.pricePerHr,
      required this.description,
      required this.photo,
      required this.category,
      required this.favorite,
      required this.reviews,
      required this.totalRate,
      required this.userName,
      required this.userImage,
      required this.userEmail,
      required this.totalReviews,
      required this.currency,
      required this.priceType,
      required this.uuid});

  Map<String, dynamic> toJson() => {
        'price': price,
        'uid': uid,
        'userName': userName,
        'userImage': userImage,
        'userEmail': userEmail,
        'pricePerHr': pricePerHr,
        'description': description,
        'photo': photo,
        'category': category,
        'title': title,
        'favorite': favorite,
        'currency': currency,
        'priceType': priceType,
        'ratingCount': ratingCount,
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
        priceType: snapshot['priceType'],
        currency: snapshot['currency'],
        favorite: snapshot['favorite'],
        title: snapshot['title'],
        ratingCount: snapshot['ratingCount'],
        description: snapshot['description'],
        price: snapshot['price'],
        userName: snapshot['userName'],
        userImage: snapshot['userImage'],
        userEmail: snapshot['userEmail'],
        pricePerHr: snapshot['pricePerHr'],
        category: snapshot['category'],
        totalRate: snapshot['totalRate'], // Fetch from snapshot
        totalReviews: snapshot['totalReviews'], // Fetch from snapshot
        reviews: Map<String, int>.from(
            snapshot['reviews']), // Fetch reviews map from snapshot
        uuid: snapshot['uuid']);
  }
}
