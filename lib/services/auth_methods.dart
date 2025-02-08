import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kelimbo/models/user_model.dart';
import 'package:kelimbo/services/storage_methods.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

//Get Users Details
// Future<UserModel> getUserDetails() async {
//    User currentUser = _auth.currentUser!;
//    DocumentSnapshot documentSnapshot =await firebaseFirestore.collection('users').doc(currentUser.uid).get();
//    return UserModel.fromSnap(documentSnapshot);
// }

  //Register Provider
  Future<String> signUpUser(
      {required String email,
      required String pass,
      required String name,
      required String category,
      required String subCategory,
      required String location,
      required String phone,
      required Uint8List file}) async {
    String res = 'Wrong Email or Password';
    try {
      if (email.isNotEmpty || pass.isNotEmpty) {
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
            email: email, password: pass);
        String photoURL = await StorageMethods().uploadImageToStorage(
          'ProfilePics',
          file,
        );
        //Add User to the database with modal
        UserModel userModel = UserModel(
          numberofjobs: 0,
          confrimPassword: pass,
          uid: cred.user!.uid,
          email: email,
          password: pass,
          fullName: name,
          phone: phone,
          category: category,
          subCategory: subCategory,
          location: location,
          image: photoURL,
          finalreviews: [],
          totalRate: 0,
          totalReviews: 0,
          ratingCount: 0,
          reviews: {},
        );
        await firebaseFirestore
            .collection('users')
            .doc(cred.user!.uid)
            .set(userModel.toJson());
        res = 'success';
      }
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  //For Provider Sign In
  Future<String> loginUpUser({
    required String email,
    required String pass,
  }) async {
    String res = ' Correo electrónico o contraseña incorrectos';
    try {
      if (email.isNotEmpty || pass.isNotEmpty) {
        await _auth.signInWithEmailAndPassword(email: email, password: pass);

        res = 'success';
      }
    } on FirebaseException catch (e) {
      if (e == 'WrongEmail') {
        print(e.message);
      }
      if (e == 'WrongPassword') {
        print(e.message);
      }
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  //Google SignIn
  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    final GoogleSignInAuthentication googleAuth =
        await googleUser!.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return await FirebaseAuth.instance.signInWithCredential(credential);
  }
}
