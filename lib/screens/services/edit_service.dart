import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kelimbo/screens/main/main_dashboard.dart';
import 'package:kelimbo/utils/colors.dart';
import 'package:kelimbo/utils/image_utils.dart';
import 'package:kelimbo/widgets/save_button.dart';
import 'package:kelimbo/widgets/text_form_field.dart';

class EditService extends StatefulWidget {
  final uuid;
  const EditService({super.key, required this.uuid});

  @override
  State<EditService> createState() => _EditServiceState();
}

class _EditServiceState extends State<EditService> {
  TextEditingController serviceNameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController discountController = TextEditingController();

  String dropdownvalue = 'Hogar';
  String currencyType = "Euro";
  String drop = "Por Hora";

  var PriceType = ['Por Hora', 'Por Servicio'];
  var currency = ['Euro', 'USD', 'BTC', 'ETH', 'G1'];

  var items = [
    'Hogar',
    'Salud',
    'Turismo',
    'Entrenamiento',
    'Vehículos',
    'Mascotas',
    'Fotografía y video',
    'Eventos',
    'Belleza',
    'Limpieza',
    'Acompañamiento',
    'Recados',
    'Esoterismo',
    'Costura',
    'Asesoramiento',
    'Enseñanzas',
    'Crecimiento Personal',
    'Gestiones',
    'Tecnología',
    'Arte y Artesanía',
    'Grupos temáticos',
    'Otros'
  ];

  bool _isLoading = false;
  Uint8List? _image;
  String? imageUrl;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    // Fetch data from Firestore
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('services')
        .doc(widget.uuid)
        .get();

    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // Update the controllers with the fetched data
    setState(() {
      serviceNameController.text = data['title'] ?? '';
      descriptionController.text = data['description'] ?? '';
      priceController.text = (data['price'] ?? 0).toString();
      discountController.text = (data['pricePerHr'] ?? 0).toString();
      imageUrl = data['photo'];
      dropdownvalue = data['category'] ?? 'Hogar'; // Set dropdown value
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
        .child('services')
        .child('${FirebaseAuth.instance.currentUser!.uid}.jpg');
    UploadTask uploadTask = ref.putData(image);
    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Editar servicio",
          style: GoogleFonts.workSans(
            color: colorBlack,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
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
                      radius: 59,
                      backgroundImage: MemoryImage(_image!),
                    )
                  : (imageUrl != null && imageUrl!.isNotEmpty)
                      ? CircleAvatar(
                          radius: 59,
                          backgroundImage: NetworkImage(imageUrl!),
                        )
                      : Image.asset(
                          "assets/Choose Image.png",
                          width: 118,
                          height: 118,
                          fit: BoxFit.cover,
                        ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
              child: DropdownButton(
                value: dropdownvalue,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down),
                items: items.map((String item) {
                  return DropdownMenuItem(
                    value: item,
                    child: Text(item),
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
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
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
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : SaveButton(
                    title: "Publicar",
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
                            .collection("services")
                            .doc(widget.uuid) // Use widget.uuid here
                            .update({
                          "description": descriptionController.text,
                          "title": serviceNameController
                              .text, // Convert string to int
                          "price": int.parse(
                              priceController.text), // Convert string to int
                          "photo": downloadUrl,
                          "pricePerHr": int.parse(discountController.text),
                          "priceType": drop,
                          "currency": currencyType,
                          "category":
                              dropdownvalue, // Save the selected category
                        });
                        showMessageBar(
                            "Servicio actualizado con éxito ", context);
                      } catch (e) {
                        // Handle errors here
                        print("Error updating service: $e");
                        showMessageBar(
                            "No se pudo actualizar el servicio", context);
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
          ],
        ),
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
