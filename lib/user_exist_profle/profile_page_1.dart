import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kelimbo/user_exist_profle/profile_page_2.dart';
import 'package:kelimbo/utils/colors.dart';
import 'package:kelimbo/utils/image_utils.dart';
import 'package:kelimbo/widgets/save_button.dart';
import 'package:kelimbo/widgets/text_form_field.dart';

class ProfilePage1 extends StatefulWidget {
  const ProfilePage1({super.key});

  @override
  State<ProfilePage1> createState() => _ProfilePage1State();
}

class _ProfilePage1State extends State<ProfilePage1> {
  TextEditingController locationController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController NameController = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          "Paso 1",
          style: TextStyle(
              color: colorBlack, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8),
              child: TextFormInputField(
                  controller: NameController,
                  hintText: "Nombre completo",
                  IconSuffix: Icons.person,
                  textInputType: TextInputType.emailAddress),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8),
              child: TextFormInputField(
                  controller: phoneController,
                  hintText: "Teléfono",
                  IconSuffix: Icons.phone,
                  textInputType: TextInputType.phone),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8),
              child: TextFormInputField(
                  controller: locationController,
                  hintText: "Ubicación",
                  IconSuffix: Icons.location_pin,
                  textInputType: TextInputType.text),
            ),
          ),
          isLoading
              ? Center(child: CircularProgressIndicator())
              : SaveButton(
                  title: "Continuar",
                  onTap: () async {
                    if (NameController.text.isEmpty) {
                      showMessageBar("El nombre es requerido", context);
                    } else if (phoneController.text.isEmpty) {
                      showMessageBar("El teléfono es requerido", context);
                    } else if (locationController.text.isEmpty) {
                      showMessageBar("La ubicación es requerida", context);
                    } else {
                      setState(() {
                        isLoading = true;
                      });
                      await FirebaseFirestore.instance
                          .collection("users")
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .update({
                        "fullName": NameController.text.trim(),
                        "phone": phoneController.text.trim(),
                        "location": locationController.text.trim(),
                      });
                      setState(() {
                        isLoading = false;
                      });

                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (builder) => ProfilePage2()));
                    }
                  })
        ],
      ),
    );
  }
}
