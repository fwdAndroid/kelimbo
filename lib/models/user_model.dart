import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String uid;
  String email;
  String image;
  String confrimPassword;
  String password;
  String fullName;
  String category;
  String subCategory;
  String location;
  String phone;
  int ratingCount;
  int numberofjobs;
  double totalRate; // Stores the total rate
  int totalReviews; // Stores the total number of reviews
  Map<String, int> reviews; // Stores reviews with corresponding ratings
  var finalreviews;
  UserModel(
      {required this.uid,
      required this.email,
      required this.ratingCount,
      required this.password,
      required this.confrimPassword,
      required this.image,
      required this.fullName,
      required this.category,
      required this.subCategory,
      required this.reviews,
      required this.totalRate,
      required this.totalReviews,
      required this.finalreviews,
      required this.location,
      required this.phone,
      required this.numberofjobs});

  ///Converting Object into Json Object
  Map<String, dynamic> toJson() => {
        'image': image,
        'uid': uid,
        'password': password,
        'email': email,
        'fullName': fullName,
        'confrimPassword': confrimPassword,
        'location': location,
        'category': category,
        'subCategory': subCategory,
        'phone': phone,
        'numberofjobs': numberofjobs,
        'finalreviews': finalreviews,
        'totalRate': totalRate,
        'ratingCount': ratingCount,
        'totalReviews': totalReviews, // Include in toJs
        'reviews': reviews, // Include reviews as a list of strings
      };

  ///
  static UserModel fromSnap(DocumentSnapshot snaps) {
    var snapshot = snaps.data() as Map<String, dynamic>;

    return UserModel(
      image: snapshot['image'],
      uid: snapshot['uid'],
      password: snapshot['password'],
      fullName: snapshot['fullName'],
      email: snapshot['email'],
      confrimPassword: snapshot['confrimPassword'],
      location: snapshot['location'],
      category: snapshot['category'],
      subCategory: snapshot['subCategory'],
      phone: snapshot['phone'],
      numberofjobs: snapshot['numberofjobs'],
      finalreviews: snapshot['finalreviews'],
      totalRate: snapshot['totalRate'], // Fetch from snapshot
      totalReviews: snapshot['totalReviews'], // Fetch from snapshot
      reviews: Map<String, int>.from(
          snapshot['reviews']), // Fetch reviews map from snapshot,
      ratingCount: snapshot['ratingCount'],
    );
  }
}
