import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kelimbo/screens/auth/auth_login.dart';
import 'package:kelimbo/utils/colors.dart';
import 'package:kelimbo/utils/image_utils.dart';

class DeleteAlertWidget extends StatefulWidget {
  const DeleteAlertWidget({
    super.key,
  });

  @override
  State<DeleteAlertWidget> createState() => _DeleteAlertWidgetState();
}

class _DeleteAlertWidgetState extends State<DeleteAlertWidget> {
  final uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.delete,
                color: red,
              )),
          SingleChildScrollView(
            child: ListBody(
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Eliminar cuenta",
                      style: GoogleFonts.workSans(
                          fontWeight: FontWeight.w500,
                          fontSize: 18,
                          color: Colors.black),
                    ),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "¿Estás segura de que quieres eliminar esta cuenta?",
                      style: GoogleFonts.workSans(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: Colors.black),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
      actions: <Widget>[
        const SizedBox(
          height: 10,
        ),
        TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("Cancelar")),
        ElevatedButton(
          onPressed: () async {
            final servicesSnapshot = await FirebaseFirestore.instance
                .collection("services")
                .where("uid", isEqualTo: uid)
                .get();

            // Delete each service document
            for (var doc in servicesSnapshot.docs) {
              await FirebaseFirestore.instance
                  .collection("services")
                  .doc(doc.id)
                  .delete();
            }

            // Optionally, delete the user after deleting their services
            await FirebaseAuth.instance.currentUser!.delete();
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (builder) => AuthLogin()));
            showMessageBar("Cuenta eliminada con éxito", context);
          },
          child: Text(
            "Borrar",
            style: TextStyle(color: colorWhite),
          ),
          style: ElevatedButton.styleFrom(
              fixedSize: Size(137, 50),
              backgroundColor: mainColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              )),
        ),
      ],
    );
  }
}
