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
  bool favorite;

  ServiceModel(
      {required this.uid,
      required this.title,
      required this.price,
      required this.pricePerHr,
      required this.description,
      required this.photo,
      required this.category,
      required this.favorite,
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
        uuid: snapshot['uuid']);
  }
}
