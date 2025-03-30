import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kelimbo/screens/main/main_dashboard.dart';
import 'package:kelimbo/widgets/save_button.dart';
import 'package:kelimbo/widgets/text_form_field.dart';

class ProfilePage1 extends StatefulWidget {
  @override
  State<ProfilePage1> createState() => _ProfilePage1State();
}

class _ProfilePage1State extends State<ProfilePage1> {
  bool isLoading = false;

  TextEditingController phoneController = TextEditingController();
  TextEditingController NameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          "Tu información",
          style: TextStyle(
              color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Divider(
              thickness: 2,
              endIndent: MediaQuery.of(context).size.width / 2,
              color: Colors.black,
            ),
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

            // "Select All" button with dialog
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Tu dirección de correo electrónico y tu teléfono NO serán visibles para los demás usuarios",
                textAlign: TextAlign.center,
              ),
            ),
            isLoading
                ? CircularProgressIndicator()
                : SaveButton(
                    onTap: () async {
                      if (NameController.text.isEmpty) {
                        showMessage("El nombre es requerido", context);
                      } else if (phoneController.text.isEmpty) {
                        showMessage("El teléfono es requerido", context);
                      } else {
                        setState(() {
                          isLoading = true;
                        });

                        // Store selected cities as an array in Firebase
                        await FirebaseFirestore.instance
                            .collection("users")
                            .doc(FirebaseAuth.instance.currentUser!.uid)
                            .set({
                          "fullName": NameController.text.trim(),
                          "phone": phoneController.text.trim(),
                        }, SetOptions(merge: true));

                        setState(() {
                          isLoading = false;
                        });

                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (builder) => MainDashboard()));
                      }
                    },
                    title: "Continuar",
                  ),
          ],
        ),
      ),
    );
  }

  void showMessage(String message, BuildContext context) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
