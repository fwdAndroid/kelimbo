import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_social_button/flutter_social_button.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kelimbo/screens/auth/auth_login.dart';
import 'package:kelimbo/screens/main/main_dashboard.dart';
import 'package:kelimbo/services/auth_methods.dart';
import 'package:kelimbo/utils/colors.dart';
import 'package:kelimbo/utils/image_utils.dart';
import 'package:kelimbo/widgets/save_button.dart';
import 'package:kelimbo/widgets/text_form_field.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  TextEditingController providerEmailController = TextEditingController();
  TextEditingController providerFullNameContoller = TextEditingController();
  TextEditingController providerPassController = TextEditingController();
  TextEditingController NameController = TextEditingController();
  //Password Check
  bool passwordVisible = false;
  bool passwordVisibleConfrim = false;
  bool isGoogle = false;
  @override
  void initState() {
    super.initState();
    passwordVisible = true;
    passwordVisibleConfrim = true;
  }

  //loader
  bool isLoading = false;

  //Image
  Uint8List? _image;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            body: Column(children: [
      const SizedBox(
        height: 10,
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          "Crea tu Cuenta",
          style:
              GoogleFonts.workSans(fontSize: 22, fontWeight: FontWeight.w500),
        ),
      ),
      GestureDetector(
        onTap: () => selectImage(),
        child: Stack(
          children: [
            _image != null
                ? CircleAvatar(
                    radius: 59, backgroundImage: MemoryImage(_image!))
                : CircleAvatar(
                    radius: 59,
                    backgroundImage: AssetImage('assets/profilephoto.png'),
                  ),
            Positioned(
              bottom: -10,
              left: 70,
              child: IconButton(
                onPressed: () => selectImage(),
                icon: Icon(
                  Icons.add_a_photo,
                  color: colorBlack,
                ),
              ),
            ),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(left: 8.0, right: 8),
        child: TextFormInputField(
            controller: NameController,
            hintText: "Nombre completo",
            IconSuffix: Icons.email,
            textInputType: TextInputType.emailAddress),
      ),
      Padding(
        padding: const EdgeInsets.only(left: 8.0, right: 8),
        child: TextFormInputField(
            controller: providerEmailController,
            hintText: "Dirección de correo electrónico",
            IconSuffix: Icons.email,
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
              suffixIcon: IconButton(
                icon: Icon(
                    passwordVisible ? Icons.visibility : Icons.visibility_off),
                onPressed: () {
                  setState(
                    () {
                      passwordVisible = !passwordVisible;
                    },
                  );
                },
              ),
              fillColor: textColor,
              filled: true,
              hintStyle: GoogleFonts.nunitoSans(fontSize: 16),
              hintText: "Nueva contraseña",
            ),
            controller: providerPassController,
          )),
      Padding(
          padding:
              const EdgeInsets.only(left: 8.0, right: 8, top: 8, bottom: 8),
          child: TextFormField(
            obscureText: passwordVisibleConfrim,
            keyboardType: TextInputType.visiblePassword,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(8),
              suffixIcon: IconButton(
                icon: Icon(passwordVisibleConfrim
                    ? Icons.visibility
                    : Icons.visibility_off),
                onPressed: () {
                  setState(
                    () {
                      passwordVisibleConfrim = !passwordVisibleConfrim;
                    },
                  );
                },
              ),
              fillColor: textColor,
              filled: true,
              hintStyle: GoogleFonts.nunitoSans(fontSize: 16),
              hintText: "Confirmar contraseña",
            ),
            controller: providerFullNameContoller,
          )),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: mainColor,
                ),
              )
            : SaveButton(
                title: "Únete",
                onTap: () async {
                  if (providerEmailController.text.isEmpty) {
                    showMessageBar("Se requiere correo electrónico", context);
                  } else if (providerPassController.text.isEmpty) {
                    showMessageBar("Se requiere contraseña ", context);
                  } else {
                    setState(() {
                      isLoading = true;
                    });
                    Uint8List imageToUpload = _image ?? Uint8List(0);
                    await AuthMethods().signUpUser(
                        email: providerEmailController.text.trim(),
                        pass: providerPassController.text.trim(),
                        name: NameController.text.trim(),
                        file: imageToUpload);
                    setState(() {
                      isLoading = false;
                    });
                    showMessageBar("Inscripción completa", context);
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (builder) => MainDashboard()));
                  }
                },
              ),
      ),
      const SizedBox(
        height: 20,
      ),
      Spacer(),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        FlutterSocialButton(
          onTap: () {
            AuthMethods().signInWithGoogle().then((value) async {
              setState(() {
                isGoogle = true;
              });
              User? user = FirebaseAuth.instance.currentUser;

              // Check if user data exists in Firestore

              // If user data doesn't exist, store it

              // Set user data in Firestore
              await FirebaseFirestore.instance
                  .collection("users")
                  .doc(user?.uid)
                  .set({
                "image": user?.photoURL?.toString(),
                "email": user?.email,
                "fullName": user?.displayName,
                "uid": user?.uid,
                "password": "Auto Take Password",
                "confrimPassword": "Auto Take Password"
              });

              setState(() {
                isGoogle = false;
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (builder) => MainDashboard()));
              });
            });
          },
          mini: true,
          buttonType: ButtonType.google,
        ),
        // const SizedBox(
        //   width: 20,
        // ),
        // FlutterSocialButton(
        //   onTap: () {},
        //   mini: true,
        //   buttonType: ButtonType.facebook,
        // ),
      ]),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: GestureDetector(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (builder) => AuthLogin()));
            },
            child: Text.rich(
                TextSpan(text: 'Ya tienes una cuenta ', children: <InlineSpan>[
              TextSpan(
                text: 'Inicia sesión',
                style: GoogleFonts.workSans(
                    color: mainColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w700),
              )
            ])),
          ),
        ),
      )
    ])));
  }

  //Fucctions
  /// Select Image From Gallery
  selectImage() async {
    Uint8List ui = await pickImage(ImageSource.gallery);
    setState(() {
      _image = ui;
    });
  }
}
