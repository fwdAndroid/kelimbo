import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kelimbo/screens/auth/auth_signup.dart';
import 'package:kelimbo/screens/auth/forgot_password.dart';
import 'package:kelimbo/screens/main/main_dashboard.dart';
import 'package:kelimbo/services/auth_methods.dart';
import 'package:kelimbo/utils/colors.dart';
import 'package:kelimbo/widgets/save_button.dart';
import 'package:flutter_social_button/flutter_social_button.dart';

class AuthLogin extends StatefulWidget {
  const AuthLogin({super.key});

  @override
  State<AuthLogin> createState() => _AuthLoginState();
}

class _AuthLoginState extends State<AuthLogin> {
  TextEditingController customerEmailController = TextEditingController();
  TextEditingController customerPassController = TextEditingController();
  bool isLoading = false;
  bool isGoogle = false;
  //Password
  bool showPassword = false;
  //Password Functions
  void toggleShowPassword() {
    setState(() {
      showPassword = !showPassword; // Toggle the showPassword flag
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Spacer(),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              "Iniciemos sesión",
              style: GoogleFonts.poppins(fontSize: 25),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              "quis nostrud exercitation ullamco laboris",
              style: GoogleFonts.poppins(fontSize: 14),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: customerEmailController,
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.email,
                  color: iconColor,
                ),
                filled: true,
                fillColor: textColor,
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(22)),
                    borderSide: BorderSide(
                      color: textColor,
                    )),
                border: InputBorder.none,
                hintText: "Correo electrónico",
                hintStyle: GoogleFonts.nunitoSans(
                  fontSize: 16,
                  color: iconColor,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              obscureText: !showPassword,
              controller: customerPassController,
              decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(22)),
                      borderSide: BorderSide(
                        color: textColor,
                      )),
                  border: InputBorder.none,
                  filled: true,
                  fillColor: textColor,
                  hintText: "Contraseña",
                  hintStyle: GoogleFonts.nunitoSans(
                    fontSize: 16,
                    color: iconColor,
                  ),
                  prefixIcon: Icon(
                    Icons.lock,
                    color: iconColor,
                  ),
                  suffixIcon: IconButton(
                    onPressed: toggleShowPassword,
                    icon: showPassword
                        ? Icon(
                            Icons.visibility_off,
                            color: iconColor,
                          )
                        : Icon(
                            Icons.visibility,
                            color: iconColor,
                          ),
                  )),
            ),
          ),
          isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: mainColor,
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SaveButton(
                    title: "Iniciar sesión",
                    onTap: () async {
                      if (customerEmailController.text.isEmpty ||
                          customerPassController.text.isEmpty) {
                        showMessageBar(
                            "Se requiere correo electrónico y contraseña",
                            context);
                      } else {
                        setState(() {
                          isLoading = true;
                        });
                        String result = await AuthMethods().loginUpUser(
                          email: customerEmailController.text.trim(),
                          pass: customerPassController.text.trim(),
                        );
                        if (result == 'success') {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (builder) => MainDashboard()),
                          );
                        } else {
                          showMessageBar(result, context);
                        }
                        setState(() {
                          isLoading = false;
                        });
                      }
                    },
                  ),
                ),
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (builder) => ForgotPassword()));
                },
                child: Text(
                  'Olvidé mi contraseña',
                  style: GoogleFonts.workSans(
                      color: mainColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (builder) => MainDashboard()));
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
              //   onTap: () {
              //     Navigator.push(context,
              //         MaterialPageRoute(builder: (builder) => MainDashboard()));
              //   },
              //   mini: true,
              //   buttonType: ButtonType.facebook,
              // ),
            ],
          ),
          Spacer(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (builder) => SignUp()));
                },
                child: Text.rich(TextSpan(
                    text: '¿No tienes una cuenta?',
                    children: <InlineSpan>[
                      TextSpan(
                        text: 'Únete ahora',
                        style: GoogleFonts.workSans(
                            color: mainColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w700),
                      )
                    ])),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void showMessageBar(String message, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
