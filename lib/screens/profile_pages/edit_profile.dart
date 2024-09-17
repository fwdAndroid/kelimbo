import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marketplace/utils/colors.dart';
import 'package:marketplace/widgets/save_button.dart';
import 'package:marketplace/widgets/text_form_field.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  TextEditingController providerEmailController = TextEditingController();
  TextEditingController providerFullNameContoller = TextEditingController();
  TextEditingController providerPassController = TextEditingController();
  TextEditingController providerConfrimPassController = TextEditingController();
  TextEditingController providerContactController = TextEditingController();
  TextEditingController providerLocation = TextEditingController();

  //Password Check
  bool passwordVisible = false;
  bool passwordVisibleConfrim = false;
  @override
  void initState() {
    super.initState();
    passwordVisible = true;
    passwordVisibleConfrim = true;
  }

  String? selectedLocation; // New variable to hold the selected description
  void setSelectedDescription(String description) {
    setState(() {
      selectedLocation = description;
      providerLocation.text =
          description; // Optionally set the text field value
    });
  }

  //loader
  bool isLoading = false;

  //Image
  Uint8List? _image;

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
              child: CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage("assets/profilephoto.png"),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8),
              child: TextFormInputField(
                  controller: providerEmailController,
                  hintText: "Email Address",
                  textInputType: TextInputType.emailAddress),
            ),
            Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8, bottom: 8),
                child: TextFormField(
                  obscureText: passwordVisible,
                  keyboardType: TextInputType.visiblePassword,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(8),
                    fillColor: textColor,
                    filled: true,
                    hintStyle: GoogleFonts.nunitoSans(fontSize: 16),
                    hintText: "Domicilio",
                  ),
                  controller: providerPassController,
                )),
            Padding(
                padding: const EdgeInsets.only(
                    left: 8.0, right: 8, top: 8, bottom: 8),
                child: TextFormField(
                  obscureText: passwordVisibleConfrim,
                  keyboardType: TextInputType.visiblePassword,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(8),
                    fillColor: textColor,
                    filled: true,
                    hintStyle: GoogleFonts.nunitoSans(fontSize: 16),
                    hintText: "Telefono",
                  ),
                  controller: providerConfrimPassController,
                )),
            Spacer(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: mainColor,
                      ),
                    )
                  : SaveButton(title: "Edit Profile", onTap: () async {}),
            ),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }

  //Fucctions
  /// Select Image From Gallery
  selectImage() async {}
}
