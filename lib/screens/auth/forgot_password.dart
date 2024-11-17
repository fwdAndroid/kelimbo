import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kelimbo/screens/auth/auth_login.dart';
import 'package:kelimbo/utils/colors.dart';
import 'package:kelimbo/widgets/save_button.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  TextEditingController customerEmailController = TextEditingController();

  bool isLoading = false;

  // Function to reauthenticate the user

  void showMessageBar(String message, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // Function to reset the password

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              "assets/logo.png",
              height: 100,
            ),
          ),
          const SizedBox(height: 50),
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
                border: InputBorder.none,
                hintText: "Correo electrónico",
                hintStyle:
                    GoogleFonts.nunitoSans(fontSize: 16, color: iconColor),
              ),
            ),
          ),
          const SizedBox(height: 25),
          isLoading
              ? Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SaveButton(
                    title: "Restablecer Contraseña",
                    onTap: () async {
                      if (customerEmailController.text.isEmpty) {
                        showMessageBar(
                            "Se requiere correo electrónico", context);
                      } else {
                        await FirebaseAuth.instance.sendPasswordResetEmail(
                            email: customerEmailController.text);
                        showMessageBar(
                            "El enlace de restablecimiento de contraseña se envía a su dirección de correo electrónico restablezca su contraseña",
                            context);
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (builder) => AuthLogin()));
                      }
                    }, // Call the resetPassword function
                  ),
                ),
        ],
      ),
    );
  }
}
