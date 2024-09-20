import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kelimbo/screens/main/main_dashboard.dart';
import 'package:kelimbo/utils/colors.dart';
import 'package:kelimbo/utils/image_utils.dart';
import 'package:kelimbo/widgets/save_button.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  TextEditingController addressController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  bool _isLoading = false;
  Uint8List? _image;
  String? imageUrl;

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
      addressController.text = data['address'] ?? '';
      phoneController.text = (data['phone'] ?? ''); // Convert int to string
      nameController.text = data['fullName'] ?? ''; // Convert int to string
      imageUrl = data['image'];
    });
  }

  Future<void> selectImage() async {
    Uint8List ui = await pickImage(ImageSource.gallery);
    setState(() {
      _image = ui;
    });
  }

  Future<String> uploadImageToStorage(Uint8List image) async {
    Reference ref = FirebaseStorage.instance
        .ref()
        .child('users')
        .child('${FirebaseAuth.instance.currentUser!.uid}.jpg');
    UploadTask uploadTask = ref.putData(image);
    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("Edit Profile"),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () => selectImage(),
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
            ),
            Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8, bottom: 8),
                child: TextFormField(
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(8),
                    fillColor: textColor,
                    filled: true,
                    hintStyle: GoogleFonts.nunitoSans(fontSize: 16),
                    hintText: "Nombre y apellido",
                  ),
                  controller: nameController,
                )),
            Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8, bottom: 8),
                child: TextFormField(
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(8),
                    fillColor: textColor,
                    filled: true,
                    hintStyle: GoogleFonts.nunitoSans(fontSize: 16),
                    hintText: "Domicilio",
                  ),
                  controller: addressController,
                )),
            Padding(
                padding: const EdgeInsets.only(
                    left: 8.0, right: 8, top: 8, bottom: 8),
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(8),
                    fillColor: textColor,
                    filled: true,
                    hintStyle: GoogleFonts.nunitoSans(fontSize: 16),
                    hintText: "Telefono",
                  ),
                  controller: phoneController,
                )),
            Spacer(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: mainColor,
                      ),
                    )
                  : SaveButton(
                      title: "Edit Profile",
                      onTap: () async {
                        setState(() {
                          _isLoading = true;
                        });

                        String? downloadUrl;
                        if (_image != null) {
                          downloadUrl = await uploadImageToStorage(_image!);
                        } else {
                          downloadUrl = imageUrl;
                        }

                        try {
                          await FirebaseFirestore.instance
                              .collection("users")
                              .doc(FirebaseAuth.instance.currentUser!
                                  .uid) // Use widget.uuid here
                              .update({
                            "fullName": nameController.text,
                            "phone":
                                phoneController.text, // Convert string to int
                            "address":
                                addressController.text, // Convert string to int
                            "image": downloadUrl,
                          });
                          showMessageBar(
                              "Profile Updated Successfully ", context);
                        } catch (e) {
                          // Handle errors here
                          print("Error updating service: $e");
                          showMessageBar("Failed to update service", context);
                        } finally {
                          setState(() {
                            _isLoading = false;
                          });
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (builder) => MainDashboard()));
                        }
                      }),
            ),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}
