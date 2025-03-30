import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceModel {
  String uuid;
  int price;
  int pricePerHr;
  String photo;
  String description;
  String title;
  String category;
  String subcategory; // Add this field
  int numberOfJobs;
  String uid;
  List favorite;
  double totalRate;
  int totalReviews;
  Map<String, int> reviews;
  String userName;
  String userImage;
  String userEmail;
  String currency;
  String priceType;
  int ratingCount;
  List location;
  var finalreviews;
  DateTime dateTime;

  ServiceModel({
    required this.uid,
    required this.dateTime,
    required this.title,
    required this.price,
    required this.ratingCount,
    required this.pricePerHr,
    required this.description,
    required this.photo,
    required this.category,
    required this.subcategory, // Add to constructor
    required this.favorite,
    required this.reviews,
    required this.totalRate,
    required this.userName,
    required this.userImage,
    required this.numberOfJobs,
    required this.userEmail,
    required this.totalReviews,
    required this.currency,
    required this.priceType,
    required this.finalreviews,
    required this.location,
    required this.uuid,
  });

  Map<String, dynamic> toJson() => {
        'price': price,
        'uid': uid,
        'userName': userName,
        'userImage': userImage,
        'subcategory': subcategory, // Include in JSON
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
        'totalRate': totalRate,
        'totalReviews': totalReviews,
        'reviews': reviews,
        'location': location,
        'finalreviews': finalreviews,
        'numberOfJobs': numberOfJobs,
        "dateTime": dateTime,
      };

  static ServiceModel fromSnap(DocumentSnapshot snaps) {
    var snapshot = snaps.data() as Map<String, dynamic>;

    return ServiceModel(
      photo: snapshot['photo'],
      uid: snapshot['uid'],
      priceType: snapshot['priceType'],
      subcategory: snapshot['subcategory'] ?? '', // Handle potential null
      currency: snapshot['currency'],
      favorite: snapshot['favorite'],
      dateTime: snapshot['dateTime'],
      numberOfJobs: snapshot['numberOfJobs'],
      title: snapshot['title'],
      ratingCount: snapshot['ratingCount'],
      description: snapshot['description'],
      price: snapshot['price'],
      userName: snapshot['userName'],
      userImage: snapshot['userImage'],
      userEmail: snapshot['userEmail'],
      pricePerHr: snapshot['pricePerHr'],
      location: snapshot['location'],
      finalreviews: snapshot['finalreviews'],
      category: snapshot['category'],
      totalRate: snapshot['totalRate']?.toDouble() ?? 0.0, // Handle conversion
      totalReviews: snapshot['totalReviews'] ?? 0,
      reviews: Map<String, int>.from(snapshot['reviews'] ?? {}),
      uuid: snapshot['uuid'],
    );
  }
}
