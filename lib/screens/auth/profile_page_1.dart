import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kelimbo/screens/main/main_dashboard.dart';
import 'package:kelimbo/utils/colors.dart';
import 'package:kelimbo/utils/image_utils.dart';
import 'package:kelimbo/widgets/save_button.dart';
import 'package:kelimbo/widgets/text_form_field.dart';
import 'dart:convert';

class ProfilePage1 extends StatefulWidget {
  ProfilePage1({
    super.key,
  });

  @override
  State<ProfilePage1> createState() => _ProfilePage1State();
}

class _ProfilePage1State extends State<ProfilePage1> {
  List<String> cityNames = [];
  String? selectedMunicipality;
  @override
  void initState() {
    super.initState();
    loadJsonData();
  }

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
          Divider(
            thickness: 2,
            endIndent: MediaQuery.of(context).size.width / 2,
            color: colorBlack,
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
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownSearch<String>(
                items: cityNames,
                popupProps: PopupProps.menu(
                  showSearchBox: true,
                  emptyBuilder: (_, __) =>
                      Center(child: Text('No municipalities found')),
                ),
                dropdownDecoratorProps: DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    labelText: 'Select Municipality',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    selectedMunicipality = value;
                  });
                },
                selectedItem: selectedMunicipality,
              ),
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
                    } else if (selectedMunicipality!.isEmpty) {
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
                        "location": selectedMunicipality,
                      });
                      setState(() {
                        isLoading = false;
                      });

                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (builder) => MainDashboard()));
                    }
                  }),
          Spacer(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                "Tú teléfono y dirección de correo electrónico no serán visibles para otros usuarios",
                textAlign: TextAlign.center,
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> loadJsonData() async {
    try {
      String jsonString = await rootBundle.loadString('assets/cities.json');
      List<dynamic> jsonData = json.decode(jsonString);

      setState(() {
        cityNames = jsonData.map((e) => e["Nom"] as String).toList();
        cityNames.sort((a, b) =>
            a.toLowerCase().compareTo(b.toLowerCase())); // Sort alphabetically
      });
    } catch (e) {
      print("Error loading JSON: $e");
    }
  }
}
