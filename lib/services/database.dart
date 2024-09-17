import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kelimbo/models/service_model.dart';
import 'package:kelimbo/services/storage_methods.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:uuid/uuid.dart';

class Database {
  // Function to compress image before uploading to Firestore
  Future<Uint8List> compressImage(Uint8List image) async {
    final compressedImage = await FlutterImageCompress.compressWithList(
      image,
      quality: 50, // Adjust quality to reduce size
    );
    return compressedImage;
  }

  // Function to add a service to Firestore
  Future<String> addService({
    required String title,
    required String category,
    required int price,
    required String description,
    required int pricePerHer,
    required Uint8List file,
  }) async {
    String res = 'Some error occurred';
    try {
      if (title.isNotEmpty && category.isNotEmpty) {
        // Compress image before upload
        Uint8List compressedFile = await compressImage(file);

        // Upload compressed image to Firestore storage
        String photoURL = await StorageMethods().uploadImageToStorage(
          'servicesImages',
          compressedFile,
        );

        var uuid = Uuid().v4();

        // Create ServiceModel object
        ServiceModel serviceModel = ServiceModel(
          favorite: false,
          pricePerHr: pricePerHer,
          uid: FirebaseAuth.instance.currentUser!.uid,
          title: title,
          description: description,
          uuid: uuid,
          price: price,
          category: category,
          photo: photoURL,
        );

        // Add service to Firestore
        await FirebaseFirestore.instance
            .collection('services')
            .doc(uuid)
            .set(serviceModel.toJson());

        res = 'success';
      }
    } catch (e) {
      res = e.toString();
    }
    return res;
  }
}
