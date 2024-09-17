import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:marketplace/screens/main/main_dashboard.dart';
import 'package:marketplace/services/database.dart';
import 'package:marketplace/utils/colors.dart';
import 'package:marketplace/utils/image_utils.dart';
import 'package:marketplace/widgets/save_button.dart';
import 'package:marketplace/widgets/text_form_field.dart';
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
  TextEditingController discountController = TextEditingController();

  String dropdownvalue = 'Hogar';

  var items = [
    'Hogar',
    'Salud',
    'Turismo',
    'Entrenamiento personal',
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
          "Add Service",
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
                hintText: "Title Name",
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
                  hintText: "Description",
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
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 8),
                    child: TextFormInputField(
                      controller: priceController,
                      hintText: "Price",
                      textInputType: TextInputType.number,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 8),
                    child: TextFormInputField(
                      controller: discountController,
                      hintText: "Price Per Hr",
                      textInputType: TextInputType.number,
                    ),
                  ),
                ),
              ],
            ),
            isAdded
                ? Center(child: CircularProgressIndicator())
                : SaveButton(
                    title: "Publish",
                    onTap: () async {
                      if (validateInputs(context)) {
                        setState(() {
                          isAdded = true;
                        });

                        try {
                          Database().addService(
                            category: dropdownvalue,
                            title: serviceNameController.text,
                            price: int.parse(priceController.text),
                            description: descriptionController.text,
                            pricePerHer: int.parse(discountController.text),
                            // file: _image!,
                          );

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (builder) => MainDashboard(),
                            ),
                          );
                        } catch (e) {
                          showMessageBar(e.toString(), context);
                        } finally {
                          setState(() {
                            isAdded = false;
                          });
                        }
                      }
                    }),
          ],
        ),
      ),
    );
  }

  bool validateInputs(BuildContext context) {
    if (serviceNameController.text.isEmpty) {
      showMessageBar("Title is Required", context);
      return false;
    } else if (descriptionController.text.isEmpty) {
      showMessageBar("Description is Required", context);
      return false;
    } else if (_image == null) {
      showMessageBar("Image is Required", context);
      return false;
    } else if (priceController.text.isEmpty) {
      showMessageBar("Price is Required", context);
      return false;
    } else if (discountController.text.isEmpty) {
      showMessageBar("Price Per Hr is Required", context);
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
