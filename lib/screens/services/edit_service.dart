import 'dart:convert';
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
import 'package:http/http.dart' as http;

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

  bool _isLoading = false;
  Uint8List? _image;
  String? imageUrl;
  List<String> cityNames = [];
  List<String> selectedLocations = [];
  bool isLoading = true;
  bool showAllCities = false;
  String? searchQuery;
  List<String> filteredCities = [];
  bool showLocationDropdown = false;

  @override
  void initState() {
    super.initState();
    fetchData();
    fetchCities();
  }

  void fetchData() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('services')
        .doc(widget.uuid)
        .get();

    if (doc.exists) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      setState(() {
        serviceNameController.text = data['title'] ?? '';
        descriptionController.text = data['description'] ?? '';
        priceController.text = (data['price'] ?? 0).toString();
        discountController.text = (data['pricePerHr'] ?? 0).toString();
        imageUrl = data['photo'];
        dropdownvalue = data['category'] ?? 'Hogar';
        currencyType = data['currency'] ?? "EURO";
        selectedLocations =
            (data['location'] as List<dynamic>?)?.cast<String>() ?? [];

        // Initialize showAllCities based on whether all cities are selected
        if (selectedLocations.length == cityNames.length &&
            cityNames.isNotEmpty) {
          showAllCities = true;
        }
      });
    }
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

  void filterCities(String query) {
    setState(() {
      searchQuery = query;
      filteredCities = cityNames
          .where((city) => city.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void toggleLocationSelection(String location) {
    setState(() {
      if (selectedLocations.contains(location)) {
        selectedLocations.remove(location);
      } else {
        selectedLocations.add(location);
      }
      // If we've selected all cities, update the checkbox
      if (selectedLocations.length == cityNames.length) {
        showAllCities = true;
      } else {
        showAllCities = false;
      }
    });
  }

  void toggleAllCities(bool? value) {
    if (value == null) return;

    setState(() {
      showAllCities = value;
      if (value) {
        selectedLocations = List.from(cityNames);
      } else {
        selectedLocations.clear();
      }
    });
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Ubicaciones",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  if (cityNames.isNotEmpty)
                    Column(
                      children: [
                        CheckboxListTile(
                          title: Text("Todas las ciudades de España"),
                          value: showAllCities,
                          onChanged: toggleAllCities,
                        ),
                        // Show dropdown only when not all cities are selected
                        if (!showAllCities) ...[
                          // Show search dropdown
                          TextField(
                            decoration: InputDecoration(
                              hintText: "Buscar ciudad...",
                              prefixIcon: Icon(Icons.search),
                            ),
                            onChanged: filterCities,
                            onTap: () {
                              setState(() {
                                showLocationDropdown = true;
                              });
                            },
                          ),
                          if (showLocationDropdown && searchQuery != null)
                            Container(
                              height: 200,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: ListView.builder(
                                itemCount: filteredCities.length,
                                itemBuilder: (context, index) {
                                  final city = filteredCities[index];
                                  return ListTile(
                                    title: Text(city),
                                    trailing: selectedLocations.contains(city)
                                        ? Icon(Icons.check, color: Colors.green)
                                        : null,
                                    onTap: () {
                                      toggleLocationSelection(city);
                                    },
                                  );
                                },
                              ),
                            ),
                          // Show chips for selected locations (only if less than 10)
                          if (selectedLocations.isNotEmpty &&
                              selectedLocations.length < 10)
                            Wrap(
                              spacing: 8.0,
                              runSpacing: 4.0,
                              children: selectedLocations.map((location) {
                                return Chip(
                                  label: Text(location),
                                  backgroundColor: Colors.blue.shade100,
                                  deleteIcon:
                                      Icon(Icons.cancel, color: Colors.red),
                                  onDeleted: () {
                                    setState(() {
                                      selectedLocations.remove(location);
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                          // Show count if more than 10 locations selected
                          if (selectedLocations.length >= 10)
                            Text(
                              "${selectedLocations.length} ciudades seleccionadas",
                              style: TextStyle(color: Colors.grey),
                            ),
                        ],
                      ],
                    ),
                  if (cityNames.isEmpty && isLoading)
                    Center(child: CircularProgressIndicator()),
                  if (cityNames.isEmpty && !isLoading)
                    Text("No se pudieron cargar las ubicaciones"),
                ],
              ),
            ),
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SaveButton(
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
                                .doc(widget.uuid)
                                .update({
                              "description": descriptionController.text,
                              "title": serviceNameController.text,
                              "price": int.parse(priceController.text),
                              "photo": downloadUrl,
                              "pricePerHr": int.parse(discountController.text),
                              "priceType": drop,
                              "currency": currencyType,
                              "category": dropdownvalue,
                              "location": selectedLocations,
                            });
                            showMessageBar(
                                "Servicio actualizado con éxito ", context);
                          } catch (e) {
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
                  ),
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

  Future<void> fetchCities() async {
    const String apiUrl =
        "https://raw.githubusercontent.com/etereo-io/spain-communities-cities-json/master/towns.json";

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          cityNames = data.map((item) => item["name"] as String).toList();
          isLoading = false;
          // Initialize showAllCities if all cities are selected
          if (selectedLocations.length == cityNames.length) {
            showAllCities = true;
          }
        });
      } else {
        print("Error: ${response.statusCode}");
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }
}
