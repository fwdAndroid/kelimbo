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

  var items = [
    'Hogar',
    'Salud',
    'Turismo',
    'Entrenamiento personal',
    'Vehículos',
    'Mascotas',
    'Fotografía y vídeo',
    'Belleza'
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
      descriptionController.text =
          (data['description'] ?? ''); // Convert int to string
      priceController.text = data['price'] ?? 0; // Convert int to string
//discountController.text = data['pricePerHr'] ?? 0;
      imageUrl = data['photo'];
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
                maxLength: 30,
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
              child: TextFormInputField(
                controller: priceController,
                hintText: "Precio",
                textInputType: TextInputType.number,
              ),
            ),
            // Row(
            //   children: [
            //     Expanded(
            //       child: Padding(
            //         padding: const EdgeInsets.symmetric(
            //             horizontal: 8.0, vertical: 8),
            //         child: TextFormInputField(
            //           controller: priceController,
            //           hintText: "Price",
            //           textInputType: TextInputType.number,
            //         ),
            //       ),
            //     ),
            //     Expanded(
            //       child: Padding(
            //         padding: const EdgeInsets.symmetric(
            //             horizontal: 8.0, vertical: 8),
            //         child: TextFormInputField(
            //           controller: discountController,
            //           hintText: "Price Per Hr",
            //           textInputType: TextInputType.number,
            //         ),
            //       ),
            //     ),
            //   ],
            // ),
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
                          // "pricePerHr": int.parse(discountController.text)
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

                      // if (validateInputs(context)) {
                      //   setState(() {
                      //     _isLoading = true;
                      //   });

                      //   try {
                      //     Database().addService(
                      //       category: dropdownvalue,
                      //       title: serviceNameController.text,
                      //       price: int.parse(priceController.text),
                      //       description: descriptionController.text,
                      //       pricePerHer: int.parse(discountController.text),
                      //       file: _image!,
                      //     );

                      //     Navigator.push(
                      //       context,
                      //       MaterialPageRoute(
                      //         builder: (builder) => MainDashboard(),
                      //       ),
                      //     );
                      //     showMessageBar(
                      //         "Services Added Successfully".toString(),
                      //         context);
                      //   } catch (e) {
                      //     showMessageBar(e.toString(), context);
                      //   }
                      // }
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
