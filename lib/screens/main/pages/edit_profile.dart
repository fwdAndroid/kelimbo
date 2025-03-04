import 'dart:typed_data';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kelimbo/screens/main/main_dashboard.dart';
import 'package:kelimbo/utils/colors.dart';
import 'package:kelimbo/utils/image_utils.dart';
import 'package:kelimbo/widgets/save_button.dart';
import 'dart:convert';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  TextEditingController phoneController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  bool _isLoading = false;
  Uint8List? _image;
  String? imageUrl;
  List<String> cityNames = [];
  List<String> selectedLocations = []; // List to store selected locations

  @override
  void initState() {
    super.initState();
    fetchData();
    loadJsonData();
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

  void fetchData() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    setState(() {
      phoneController.text = (data['phone'] ?? '');
      nameController.text = data['fullName'] ?? '';
      imageUrl = data['image'];

      // Ensure location is treated as List<String>
      selectedLocations =
          (data['location'] as List<dynamic>?)?.cast<String>() ?? [];
    });
  }

  Future<void> selectImage() async {
    Uint8List ui = await pickImage(ImageSource.gallery);
    setState(() {
      _image = ui;
    });
  }

  Future<String> uploadImageToStorage(Uint8List image) async {
    Reference ref = FirebaseStorage.instance
        .ref()
        .child('users')
        .child('${FirebaseAuth.instance.currentUser!.uid}.jpg');
    UploadTask uploadTask = ref.putData(image);
    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("Editar perfil"),
        ),
        body: Column(
          children: [
            // Profile Image Section
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () => selectImage(),
                child: _image != null
                    ? CircleAvatar(
                        radius: 59, backgroundImage: MemoryImage(_image!))
                    : imageUrl != null
                        ? CircleAvatar(
                            radius: 59,
                            backgroundImage: NetworkImage(imageUrl!))
                        : Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.asset("assets/profilephoto.png"),
                          ),
              ),
            ),

            // Full Name Input
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: TextFormField(
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(8),
                  fillColor: textColor,
                  filled: true,
                  hintStyle: GoogleFonts.nunitoSans(fontSize: 16),
                  hintText: "Nombre y apellido",
                ),
                controller: nameController,
              ),
            ),

            // Phone Number Input
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: TextFormField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(8),
                  fillColor: textColor,
                  filled: true,
                  hintStyle: GoogleFonts.nunitoSans(fontSize: 16),
                  hintText: "Telefono",
                ),
                controller: phoneController,
              ),
            ),

            // Location Selection
            Text("Cambiar Ubicación"),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownSearch<String>(
                items: cityNames,
                popupProps: PopupProps.menu(
                  showSearchBox: true,
                ),
                dropdownButtonProps: DropdownButtonProps(
                  color: Colors.blue,
                ),
                dropdownDecoratorProps: DropDownDecoratorProps(
                  textAlignVertical: TextAlignVertical.center,
                  dropdownSearchDecoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                ),
                onChanged: (value) {
                  if (value != null && !selectedLocations.contains(value)) {
                    setState(() {
                      selectedLocations.add(value);
                    });
                  }
                },
                selectedItem: "Seleccionar ubicación",
              ),
            ),

            // Show Selected Locations as Chips
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: selectedLocations.map((location) {
                  return Chip(
                    label: Text(location),
                    backgroundColor: Colors.purple.shade100,
                    deleteIcon: Icon(Icons.close, size: 18),
                    onDeleted: () {
                      setState(() {
                        selectedLocations.remove(location);
                      });
                    },
                  );
                }).toList(),
              ),
            ),

            Spacer(),

            // Save Button
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: mainColor,
                      ),
                    )
                  : SaveButton(
                      title: "Guardar Perfil",
                      onTap: () async {
                        setState(() {
                          _isLoading = true;
                        });

                        String? downloadUrl;
                        if (_image != null) {
                          downloadUrl = await uploadImageToStorage(_image!);
                        } else {
                          downloadUrl = imageUrl;
                        }

                        try {
                          await FirebaseFirestore.instance
                              .collection("users")
                              .doc(FirebaseAuth.instance.currentUser!.uid)
                              .update({
                            "fullName": nameController.text,
                            "phone": phoneController.text,
                            "location":
                                selectedLocations, // Save as List<String>
                            "image": downloadUrl,
                          });
                          showMessageBar(
                              "Perfil actualizado con éxito", context);
                        } catch (e) {
                          print("Error updating profile: $e");
                          showMessageBar(
                              "No se pudo actualizar el perfil", context);
                        } finally {
                          setState(() {
                            _isLoading = false;
                          });
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (builder) => MainDashboard()));
                        }
                      }),
            ),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
