import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kelimbo/screens/main/pages/edit_profile.dart';
import 'package:kelimbo/widgets/save_button.dart';

class ViewProfile extends StatefulWidget {
  const ViewProfile({super.key});

  @override
  State<ViewProfile> createState() => _ViewProfileState();
}

class _ViewProfileState extends State<ViewProfile> {
  String? addressController;
  String? phoneController;
  String? nameController;
  String? emailController;

  Uint8List? _image;
  String? imageUrl;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      setState(() {
        addressController = data['location'] ?? '';
        phoneController = (data['phone'] ?? '').toString();
        nameController = data['fullName'] ?? '';
        emailController = data['email'] ?? '';
        imageUrl = data['image'];
      });
    } catch (e) {
      // Handle any errors
      print("Error fetching data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    child: _image != null
                        ? CircleAvatar(
                            radius: 59, backgroundImage: MemoryImage(_image!))
                        : imageUrl != null
                            ? CircleAvatar(
                                radius: 59,
                                backgroundImage: NetworkImage(imageUrl!))
                            : Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.asset("assets/profilephoto.png"),
                              ),
                  ),
                ],
              ),
            ),
            buildInfoRow(Icons.person, nameController!),
            buildInfoRow(Icons.mobile_friendly, phoneController!),
            buildInfoRow(Icons.email, emailController!),
            buildInfoRow(Icons.location_pin, addressController!),
            Spacer(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SaveButton(
                title: "Editar Perfil",
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (builder) => EditProfile()));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Row(
        children: [
          Icon(icon, color: Colors.black),
          const SizedBox(width: 10),
          Text(
            text.isNotEmpty ? text : "No Data",
            style: GoogleFonts.inter(
              color: Color(0xff240F51),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
