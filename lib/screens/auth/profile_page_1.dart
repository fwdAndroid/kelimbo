import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:kelimbo/screens/main/main_dashboard.dart';
import 'package:kelimbo/widgets/save_button.dart';
import 'package:kelimbo/widgets/text_form_field.dart';

class ProfilePage1 extends StatefulWidget {
  @override
  State<ProfilePage1> createState() => _ProfilePage1State();
}

class _ProfilePage1State extends State<ProfilePage1> {
  List<String> cityNames = [];
  List<String> selectedMunicipalities = [];
  bool isLoading = false;

  TextEditingController phoneController = TextEditingController();
  TextEditingController NameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadJsonData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          "Paso 1",
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
            TextButton(
              onPressed: () {
                showSelectAllDialog();
              },
              child: Text("Select All Cities"),
            ),

            // Multi-selection dropdown
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownSearch<String>.multiSelection(
                items: cityNames,
                selectedItems: selectedMunicipalities,
                popupProps: PopupPropsMultiSelection.menu(
                  showSearchBox: true,
                ),
                dropdownDecoratorProps: DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    labelText: 'Select Municipality',
                    border: OutlineInputBorder(),
                  ),
                ),
                onChanged: (values) {
                  setState(() {
                    selectedMunicipalities = values;
                  });
                },
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
                      } else if (selectedMunicipalities.isEmpty) {
                        showMessage("La ubicación es requerida", context);
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
                          "locations":
                              selectedMunicipalities, // Store as an array
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

  /// Function to show the Select All dialog

  void showSelectAllDialog() {
    List<String> tempSelected =
        List.from(selectedMunicipalities); // ✅ Start with selected items only

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text("Select Cities"),
              content: Container(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: cityNames.length,
                  itemBuilder: (context, index) {
                    return CheckboxListTile(
                      title: Text(cityNames[index]),
                      value: tempSelected.contains(cityNames[index]),
                      onChanged: (bool? value) {
                        setDialogState(() {
                          if (value == true) {
                            if (!tempSelected.contains(cityNames[index])) {
                              tempSelected.add(cityNames[index]);
                            }
                          } else {
                            tempSelected.remove(cityNames[index]);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog without saving
                  },
                  child: Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      // ✅ Ensure UI updates correctly
                      selectedMunicipalities = List.from(tempSelected);
                    });

                    Navigator.pop(context); // ✅ Close dialog smoothly
                  },
                  child: Text("Confirm"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> loadJsonData() async {
    try {
      String jsonString = await rootBundle.loadString('assets/cities.json');
      List<dynamic> jsonData = json.decode(jsonString);
      setState(() {
        cityNames = jsonData.map((e) => e["Nom"] as String).toList();
        cityNames.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
      });
    } catch (e) {
      print("Error loading JSON: $e");
    }
  }

  void showMessage(String message, BuildContext context) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
