import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_social_button/flutter_social_button.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kelimbo/screens/auth/auth_signup.dart';
import 'package:kelimbo/screens/auth/forgot_password.dart';
import 'package:kelimbo/screens/main/main_dashboard.dart';
import 'package:kelimbo/services/auth_methods.dart';
import 'package:kelimbo/user_exist_profle/profile_page_1.dart';
import 'package:kelimbo/utils/colors.dart';
import 'package:kelimbo/widgets/save_button.dart';

class AuthLogin extends StatefulWidget {
  const AuthLogin({super.key});

  @override
  State<AuthLogin> createState() => _AuthLoginState();
}

class _AuthLoginState extends State<AuthLogin> {
  final TextEditingController customerEmailController = TextEditingController();
  final TextEditingController customerPassController = TextEditingController();

  bool isLoading = false;
  bool isGoogle = false;
  bool showPassword = false;

  // Toggle password visibility
  void toggleShowPassword() {
    setState(() {
      showPassword = !showPassword;
    });
  }

  // Display a message bar
  void showMessageBar(String message, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
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
              "Utiliza tu correo electrónico y contraseña para iniciar sesión",
              style: GoogleFonts.poppins(fontSize: 14),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: customerEmailController,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.email, color: iconColor),
                filled: true,
                fillColor: textColor,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(22)),
                  borderSide: BorderSide(color: textColor),
                ),
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
                  borderSide: BorderSide(color: textColor),
                ),
                filled: true,
                fillColor: textColor,
                hintText: "Contraseña",
                hintStyle: GoogleFonts.nunitoSans(
                  fontSize: 16,
                  color: iconColor,
                ),
                prefixIcon: Icon(Icons.lock, color: iconColor),
                suffixIcon: IconButton(
                  onPressed: toggleShowPassword,
                  icon: Icon(
                    showPassword ? Icons.visibility_off : Icons.visibility,
                    color: iconColor,
                  ),
                ),
              ),
            ),
          ),
          isLoading
              ? Center(
                  child: CircularProgressIndicator(color: mainColor),
                )
              : Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SaveButton(
                      title: "Iniciar sesión",
                      onTap: () async {
                        if (customerEmailController.text.isEmpty ||
                            customerPassController.text.isEmpty) {
                          showMessageBar(
                            "Se requiere correo electrónico y contraseña",
                            context,
                          );
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
                                  builder: (context) => MainDashboard()),
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
                ),
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (builder) => ForgotPassword()),
                  );
                },
                child: Text(
                  'Olvidé mi contraseña',
                  style: GoogleFonts.workSans(
                    color: mainColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          isGoogle
              ? Center(child: CircularProgressIndicator())
              : Center(
                  child: FlutterSocialButton(
                      buttonType: ButtonType.google,
                      mini: true,
                      onTap: () async {
                        setState(() {
                          isGoogle = true;
                        });

                        await AuthMethods().signInWithGoogle();

                        try {
                          // Get the UserCredential object

                          final userDoc = await FirebaseFirestore.instance
                              .collection("users")
                              .doc(FirebaseAuth.instance.currentUser!.uid)
                              .get();

                          if (userDoc.exists) {
                            // Retrieve user data
                            final userData = userDoc.data();
                            final fullName = userData?['fullName'];
                            final phone = userData?['phone'];
                            final location = userData?['location'];

                            // Check if any field is null or empty
                            if ((fullName == null || fullName.isEmpty) ||
                                (phone == null || phone.isEmpty) ||
                                (location == null || location.isEmpty)) {
                              // Navigate to ProfilePage1 to complete the profile
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (builder) => ProfilePage1()),
                              );
                            } else {
                              // All fields are valid, navigate to MainDashboard
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (builder) => MainDashboard()),
                              );
                            }
                          } else {
                            // If the user does not exist, create a new document
                            await FirebaseFirestore.instance
                                .collection("users")
                                .doc(FirebaseAuth.instance.currentUser!.uid)
                                .set({
                              "image":
                                  FirebaseAuth.instance.currentUser!.photoURL,
                              "email": FirebaseAuth.instance.currentUser!.email,
                              "uid": FirebaseAuth.instance.currentUser!.uid,
                              "password": "Auto Take Password",
                              "confirmPassword": "Auto Take Password",
                              "fullName": "",
                              "phone": "",
                              "location": "",
                            });

                            // Navigate to ProfilePage1 for new users
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (builder) => ProfilePage1()),
                            );
                          }
                        } catch (e) {
                          print("Error during Google Sign-In: $e");
                          showMessageBar(
                              "Error during sign-in. Please try again.",
                              context);
                        }

                        setState(() {
                          isGoogle = false;
                        });
                      }),
                ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (builder) => SignUp()),
                  );
                },
                child: Text.rich(
                  TextSpan(
                    text: '¿No tienes una cuenta?',
                    children: [
                      TextSpan(
                        text: ' Únete ahora',
                        style: GoogleFonts.workSans(
                          color: mainColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
