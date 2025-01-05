import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kelimbo/screens/main/main_dashboard.dart';
import 'package:kelimbo/services/database.dart';
import 'package:kelimbo/utils/colors.dart';
import 'package:kelimbo/utils/image_utils.dart';
import 'package:kelimbo/widgets/save_button.dart';
import 'package:kelimbo/widgets/text_form_field.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class AddServicePage extends StatefulWidget {
  const AddServicePage({super.key});

  @override
  State<AddServicePage> createState() => _AddServicePageState();
}

class _AddServicePageState extends State<AddServicePage> {
  TextEditingController serviceNameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController priceController = TextEditingController();

  String dropdownvalue = 'Acompañamiento';
  String currencyType = "Euro";
  String drop = "Por Hora";

  var PriceType = ['Por Hora', 'Por Servicio'];
  var currency = ['Euro', 'USD', 'BTC', 'ETH', 'G1'];

  var items = [
    'Acompañamiento',
    'Arte y Artesanía',
    'Asesoramiento',
    'Belleza',
    'Costura',
    'Crecimiento Personal',
    'Entrenamiento',
    'Enseñanzas',
    'Esoterismo',
    'Eventos',
    'Fotografía y video',
    'Gestiones',
    'Grupos temáticos',
    'Hogar',
    'Limpieza',
    'Mascotas',
    'Otros',
    'Recados',
    'Salud',
    'Tecnología',
    'Turismo',
    'Vehículos'
  ];

  Uint8List? _image;
  bool isAdded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          "Agregar servicio",
          style: GoogleFonts.workSans(
            color: colorBlack,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: StreamBuilder<Object>(
          stream: FirebaseFirestore.instance
              .collection("users")
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .snapshots(),
          builder: (context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data == null) {
              return Center(child: Text('No hay datos disponibles'));
            }
            var snap = snapshot.data;
            return SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 8),
                    child: TextFormInputField(
                      maxLenght: 30,
                      controller: serviceNameController,
                      hintText: "Nombre del título",
                      textInputType: TextInputType.text,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      controller: descriptionController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        filled: true,
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(22)),
                            borderSide: BorderSide(
                              color: textColor,
                            )),
                        contentPadding: EdgeInsets.all(8),
                        fillColor: Color(0xffF6F7F9),
                        hintText: "Descripción",
                        hintStyle: GoogleFonts.nunitoSans(fontSize: 16),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => selectImage(),
                    child: _image != null
                        ? CircleAvatar(
                            radius: 59, backgroundImage: MemoryImage(_image!))
                        : GestureDetector(
                            onTap: () => selectImage(),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Image.asset("assets/Choose Image.png"),
                            ),
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 8),
                    child: DropdownButton(
                      value: dropdownvalue,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down),
                      items: items.map((String items) {
                        return DropdownMenuItem(
                          value: items,
                          child: Text(items),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          dropdownvalue = newValue!;
                        });
                      },
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 8),
                          child: TextFormInputField(
                            controller: priceController,
                            hintText: "Precio",
                            textInputType: TextInputType.number,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 8),
                          child: DropdownButton(
                            value: drop,
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down),
                            items: PriceType.map((String PriceType) {
                              return DropdownMenuItem(
                                value: PriceType,
                                child: Text(PriceType),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                drop = newValue!;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 8),
                    child: DropdownButton(
                      value: currencyType,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down),
                      items: currency.map((String currency) {
                        return DropdownMenuItem(
                          value: currency,
                          child: Text(currency),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          currencyType = newValue!;
                        });
                      },
                    ),
                  ),
                  isAdded
                      ? Center(child: CircularProgressIndicator())
                      : SaveButton(
                          title: "Publicar",
                          onTap: () async {
                            if (validateInputs(context)) {
                              setState(() {
                                isAdded = true;
                              });

                              try {
                                await Database().addService(
                                  userName: snap['fullName'],
                                  userImage: snap['image'],
                                  userEmail: snap['email'],
                                  location: snap['location'],
                                  category: dropdownvalue,
                                  currency: currencyType,
                                  priceType: drop,
                                  title: serviceNameController.text,
                                  price: int.parse(priceController.text),
                                  description: descriptionController.text,
                                  pricePerHer: 0,
                                  file: _image, // Image is now optional
                                );

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (builder) => MainDashboard(),
                                  ),
                                );
                                showMessageBar(
                                    "Servicios agregados con éxito".toString(),
                                    context);
                              } catch (e) {
                                showMessageBar(e.toString(), context);
                              }
                            }
                          }),
                ],
              ),
            );
          }),
    );
  }

  bool validateInputs(BuildContext context) {
    if (serviceNameController.text.isEmpty) {
      showMessageBar("El título es obligatorio", context);
      return false;
    } else if (descriptionController.text.isEmpty) {
      showMessageBar("La descripción es obligatoria", context);
      return false;
    } else if (priceController.text.isEmpty) {
      showMessageBar("El precio es obligatorio", context);
      return false;
    }
    return true;
  }

  selectImage() async {
    Uint8List? selectedImage = await pickImage(ImageSource.gallery);
    if (selectedImage != null) {
      Uint8List? compressedImage =
          await compressImage(selectedImage); // Compress image
      setState(() {
        _image = compressedImage; // Set compressed image
      });
    }
  }

  Future<Uint8List?> compressImage(Uint8List imageBytes) async {
    // Compress the image to a smaller size
    Uint8List? compressedImage = await FlutterImageCompress.compressWithList(
      imageBytes,
      minWidth: 800, // Set your desired width
      minHeight: 600, // Set your desired height
      quality: 85, // Compression quality (0-100)
    );
    return compressedImage;
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
