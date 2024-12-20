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

  UserModel({
    required this.uid,
    required this.email,
    required this.password,
    required this.confrimPassword,
    required this.image,
    required this.fullName,
    required this.category,
    required this.subCategory,
    required this.location,
  });

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
    );
  }
}
