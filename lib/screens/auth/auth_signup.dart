import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_social_button/flutter_social_button.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kelimbo/screens/auth/auth_login.dart';
import 'package:kelimbo/screens/main/main_dashboard.dart';
import 'package:kelimbo/services/auth_methods.dart';
import 'package:kelimbo/utils/colors.dart';
import 'package:kelimbo/utils/image_utils.dart';
import 'package:kelimbo/validator/validator_function.dart';
import 'package:kelimbo/widgets/save_button.dart';
import 'package:kelimbo/widgets/text_form_field.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  TextEditingController providerEmailController = TextEditingController();
  TextEditingController reenter = TextEditingController();
  TextEditingController providerPassController = TextEditingController();
  TextEditingController NameController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
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

  final _formKey = GlobalKey<FormState>();

  //Categories and SubCategories
  String? selectedCategory;
  String? selectedSubcategory;
  List<String> subcategories = [];

  // Fetch categories from Firestore
  Future<List<Map<String, dynamic>>> fetchCategories() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('categories').get();
    return snapshot.docs
        .map((doc) => {'id': doc.id, 'data': doc.data()})
        .toList();
  }

  // Fetch subcategories based on selected category document ID
  void fetchSubcategories(String documentId) async {
    final doc = await FirebaseFirestore.instance
        .collection('categories')
        .doc(documentId)
        .get();
    setState(() {
      subcategories = List<String>.from(doc['subcategories'] ?? []);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            body: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(children: [
                    const SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Crea tu Cuenta",
                        style: GoogleFonts.workSans(
                            fontSize: 22, fontWeight: FontWeight.w500),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => selectImage(),
                      child: Stack(
                        children: [
                          _image != null
                              ? CircleAvatar(
                                  radius: 59,
                                  backgroundImage: MemoryImage(_image!))
                              : CircleAvatar(
                                  radius: 59,
                                  backgroundImage:
                                      AssetImage('assets/profilephoto.png'),
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
                          IconSuffix: Icons.person,
                          textInputType: TextInputType.emailAddress),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 8.0,
                        right: 8,
                        top: 8,
                      ),
                      child: TextFormField(
                        validator: RegisterFunctions().validateEmail,
                        decoration: InputDecoration(
                          suffixIcon: Icon(
                            Icons.email,
                            color: iconColor,
                          ),
                          errorBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(22)),
                              borderSide: BorderSide(
                                color: textColor,
                              )),
                          focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(22)),
                              borderSide: BorderSide(
                                color: textColor,
                              )),
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(22)),
                              borderSide: BorderSide(
                                color: textColor,
                              )),
                          enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(22)),
                              borderSide: BorderSide(
                                color: textColor,
                              )),
                          fillColor: textColor,
                          hintText: "Dirección de correo electrónico",
                          hintStyle: GoogleFonts.nunitoSans(fontSize: 16),
                          filled: true,
                          contentPadding: EdgeInsets.only(left: 8, top: 15),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        controller: providerEmailController,
                      ),
                    ),
                    Padding(
                        padding: const EdgeInsets.only(
                          left: 8.0,
                          right: 8,
                          bottom: 8,
                          top: 8,
                        ),
                        child: TextFormField(
                          validator: RegisterFunctions().validatePassword,
                          obscureText: passwordVisible,
                          keyboardType: TextInputType.visiblePassword,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(8),
                            suffixIcon: IconButton(
                              icon: Icon(passwordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off),
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
                        padding: const EdgeInsets.only(
                            left: 8.0, right: 8, top: 8, bottom: 8),
                        child: TextFormField(
                          validator: _validateConfirmPassword,
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
                                    passwordVisibleConfrim =
                                        !passwordVisibleConfrim;
                                  },
                                );
                              },
                            ),
                            fillColor: textColor,
                            filled: true,
                            hintStyle: GoogleFonts.nunitoSans(fontSize: 16),
                            hintText: "Confirmar contraseña",
                          ),
                          controller: reenter,
                        )),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8),
                      child: TextFormInputField(
                          controller: locationController,
                          hintText: "Ubicación",
                          IconSuffix: Icons.location_pin,
                          textInputType: TextInputType.emailAddress),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8),
                      child: TextFormInputField(
                          controller: phoneController,
                          hintText: "Teléfono",
                          IconSuffix: Icons.phone,
                          textInputType: TextInputType.emailAddress),
                    ),
                    FutureBuilder<List<Map<String, dynamic>>>(
                      future: fetchCategories(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return CircularProgressIndicator();
                        }
                        final categories = snapshot.data!;
                        return DropdownButton<String>(
                          value: selectedCategory,
                          hint: Text("Select Category"),
                          items: categories
                              .map((category) => DropdownMenuItem<String>(
                                    value: category['data']['category'],
                                    child: Text(category['data']['category']),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedCategory = value;
                              selectedSubcategory = null; // Reset subcategory
                              subcategories = [];
                            });
                            if (value != null) {
                              final categoryDoc = categories.firstWhere(
                                  (cat) => cat['data']['category'] == value);
                              fetchSubcategories(categoryDoc['id']);
                            }
                          },
                        );
                      },
                    ),
                    SizedBox(height: 16),

                    // Subcategory Dropdown
                    if (selectedCategory != null)
                      DropdownButton<String>(
                        value: selectedSubcategory,
                        hint: Text("Select Subcategory"),
                        items: subcategories
                            .map((subcategory) => DropdownMenuItem<String>(
                                  value: subcategory,
                                  child: Text(subcategory),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedSubcategory = value;
                          });
                        },
                      ),

                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SaveButton(
                        title: "Únete",
                        onTap: () async {
                          if (NameController.text.isEmpty) {
                            showMessageBar("el nombre es requerido", context);
                          }
                          if (providerEmailController.text.isEmpty) {
                            showMessageBar(
                                "Se requiere correo electrónico", context);
                          } else if (providerPassController.text.isEmpty) {
                            showMessageBar("Se requiere contraseña ", context);
                          } else if (reenter.text.isEmpty) {
                            showMessageBar(
                                "Se requiere confirmar la contraseña ",
                                context);
                          } else {
                            setState(() {
                              isLoading = true;
                            });
                            if (_formKey.currentState?.validate() ?? false) {
                              Uint8List imageToUpload = _image ?? Uint8List(0);
                              await AuthMethods().signUpUser(
                                  phone: phoneController.text.trim(),
                                  category: selectedCategory!,
                                  subCategory: selectedSubcategory!,
                                  email: providerEmailController.text.trim(),
                                  pass: providerPassController.text.trim(),
                                  name: NameController.text.trim(),
                                  location: locationController.text.trim(),
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
                            setState(() {
                              isLoading = false;
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
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
                              "confrimPassword": "Auto Take Password",
                              "phone": user?.phoneNumber,
                              "location": "Spain",
                              "category": "Limpieza",
                              "subCategory": "dhfn",
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
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (builder) => AuthLogin()));
                          },
                          child: Text.rich(TextSpan(
                              text: 'Ya tienes una cuenta ',
                              children: <InlineSpan>[
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
                  ]),
                ))));
  }

  //Fucctions
  /// Select Image From Gallery
  selectImage() async {
    Uint8List ui = await pickImage(ImageSource.gallery);
    setState(() {
      _image = ui;
    });
  }

  // Confirm Password validation function
  String? _validateConfirmPassword(String? value) {
    if (value != providerPassController.text) {
      return 'Passwords do not match';
    }
    return null;
  }
}
