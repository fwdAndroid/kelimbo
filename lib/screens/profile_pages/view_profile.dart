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
  String addressController = "";
  String phoneController = "";
  String nameController = "";
  String emailContorller = "";
//  String priceController = "";
  String servicesController = "";
  Uint8List? _image;
  String? imageUrl;
  String bussinessName = "";
  List<String> subCategories = [];

  double price = 0.0;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    // Fetch data from Firestore
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // Update the controllers with the fetched data
    setState(() {
      addressController = data['location'] ?? '';
      phoneController = (data['phone'] ?? ''); // Convert int to string
      nameController = data['fullName'] ?? ''; // Convert int to string
      emailContorller = data['email'] ?? '';
      imageUrl = data['image'];
      //priceController = data['price'] ?? '';
      servicesController = data['description'] ?? '';
      bussinessName = data['businessName'] ?? '';
      subCategories = List<String>.from(data['subCategory'] ?? []);
      price = data['price'] != null
          ? data['price'].toDouble()
          : 0.0; // Ensure it's a double
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: SingleChildScrollView(
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
                  Text(
                    bussinessName,
                    style: GoogleFonts.inter(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff240F51)),
                  ),
                ],
              ),
            ),
            subCategories.isNotEmpty
                ? Wrap(
                    spacing: 8.0, // Horizontal space between items
                    runSpacing: 4.0, // Vertical space between rows
                    children: subCategories.map((subCategory) {
                      return Chip(
                          label: Container(
                        margin: const EdgeInsets.only(right: 12.0),
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        child: Text(
                          subCategory,
                          style: const TextStyle(
                            color: Color(0xff6202F1),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ));
                    }).toList(),
                  )
                : Text(
                    "No subcategories available",
                    style: GoogleFonts.inter(fontSize: 16),
                  ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8, top: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.person,
                    color: Colors.black,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    nameController,
                    style: GoogleFonts.inter(
                        color: Color(0xff240F51),
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                children: [
                  Icon(
                    Icons.mobile_friendly,
                    color: Colors.black,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    phoneController,
                    style: GoogleFonts.inter(
                        color: Color(0xff240F51),
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                children: [
                  Icon(
                    Icons.email,
                    color: Colors.black,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    emailContorller,
                    style: GoogleFonts.inter(
                        color: Color(0xff240F51),
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                children: [
                  Icon(
                    Icons.location_pin,
                    color: Colors.black,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    addressController,
                    style: GoogleFonts.inter(
                        color: Color(0xff240F51),
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                children: [
                  Icon(
                    Icons.price_check,
                    color: Colors.black,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "Price: \$${price.toStringAsFixed(2)}",
                    style: GoogleFonts.inter(
                      color: Color(0xff240F51),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: SizedBox(
                width: 300,
                height: 100,
                child: Text(
                  servicesController,
                  style: GoogleFonts.workSans(
                      fontWeight: FontWeight.w500, fontSize: 16),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SaveButton(
                  title: "Editar Perfil",
                  onTap: () async {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (builder) => EditProfile()));
                  }),
            ),
          ],
        ),
      ),
    ));
  }
}
