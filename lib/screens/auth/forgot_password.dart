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
  TextEditingController currentPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  bool isLoading = false;

  // Function to reauthenticate the user
  Future<void> reauthenticateUser(String email, String currentPassword) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      AuthCredential credential =
          EmailAuthProvider.credential(email: email, password: currentPassword);

      // Re-authenticate the user
      await user!.reauthenticateWithCredential(credential);
      print('Re-authentication successful');
    } catch (e) {
      print('Re-authentication failed: $e');
    }
  }

  // Function to update the user's password
  Future<void> updatePassword(String newPassword) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      // Update the user's password
      await user!.updatePassword(newPassword);
      print('Password updated successfully');
    } catch (e) {
      print('Password update failed: $e');
    }
  }

  void showMessageBar(String message, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // Function to reset the password
  void resetPassword() async {
    setState(() {
      isLoading = true;
    });

    String email = customerEmailController.text.trim();
    String currentPassword = currentPasswordController.text.trim();
    String newPassword = newPasswordController.text.trim();

    // Re-authenticate and then update the password
    await reauthenticateUser(email, currentPassword);
    await updatePassword(newPassword);

    setState(() {
      isLoading = false;
    });

    // Show a message and navigate to the login screen
    showMessageBar("Password has been updated successfully", context);
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (builder) => AuthLogin()));
  }

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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: currentPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.lock, color: iconColor),
                filled: true,
                fillColor: textColor,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(22)),
                  borderSide: BorderSide(color: textColor),
                ),
                border: InputBorder.none,
                hintText: "Current Password",
                hintStyle:
                    GoogleFonts.nunitoSans(fontSize: 16, color: iconColor),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: newPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.lock, color: iconColor),
                filled: true,
                fillColor: textColor,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(22)),
                  borderSide: BorderSide(color: textColor),
                ),
                border: InputBorder.none,
                hintText: "New Password",
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
                    title: "Reset Password",
                    onTap: resetPassword, // Call the resetPassword function
                  ),
                ),
        ],
      ),
    );
  }
}
