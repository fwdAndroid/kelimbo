import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kelimbo/screens/main/main_dashboard.dart';
import 'package:kelimbo/utils/colors.dart';
import 'package:kelimbo/utils/image_utils.dart';
import 'package:kelimbo/widgets/save_button.dart';
import 'package:kelimbo/widgets/text_form_field.dart';

class ProfilePage2 extends StatefulWidget {
  const ProfilePage2({super.key});

  @override
  State<ProfilePage2> createState() => _ProfilePage2State();
}

class _ProfilePage2State extends State<ProfilePage2> {
  final Map<String, List<String>> _subcategoriesMap = {};
  String? _expandedCategory;
  TextEditingController serviceNameController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  String currencyType = "Euro";
  var currency = ['Euro', 'USD', 'BTC', 'ETH', 'G1'];
  TextEditingController descriptionController = TextEditingController();
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Paso 2"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildCategory(
                      context,
                      "Hogar",
                      "assets/home_category.png",
                    ),
                    _buildCategory(
                      context,
                      "Salud",
                      "assets/health_category.png",
                    ),
                    _buildCategory(
                      context,
                      "Turismo",
                      "assets/turism_category.png",
                    ),
                    _buildCategory(
                      context,
                      "Entrenamiento",
                      "assets/trainning_category.png",
                    ),
                    _buildCategory(
                      context,
                      "Mascotas",
                      "assets/pets_category.png",
                    ),
                    _buildCategory(
                      context,
                      "Vehículos",
                      "assets/vehicle_category.png",
                    ),
                    _buildCategory(
                      context,
                      "Fotografía y vídeo",
                      "assets/photography_category.png",
                    ),
                    _buildCategory(
                      context,
                      "Belleza",
                      "assets/beauty_category.png",
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
              child: TextFormInputField(
                maxLenght: 30,
                controller: serviceNameController,
                hintText: "Agrega el nombre de tu empresa",
                textInputType: TextInputType.text,
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 8),
                    child: DropdownButton(
                      value: currencyType,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down),
                      items: currency.map((String items) {
                        return DropdownMenuItem(
                          value: items,
                          child: Text(items),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          currencyType = newValue!;
                        });
                      },
                    ),
                  ),
                ),
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
                )
              ],
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
            Row(
              children: [
                SizedBox(
                  width: 200,
                  height: 60,
                  child: SaveButton(
                      title: "Lo hare despues",
                      onTap: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MainDashboard()));
                      }),
                ),
                SizedBox(
                  width: 200,
                  height: 60,
                  child: SaveButton(
                      title: "Crear negocio",
                      onTap: () async {
                        if (serviceNameController.text.isEmpty) {
                          showMessageBar("El título es obligatorio", context);
                          return;
                        } else if (descriptionController.text.isEmpty) {
                          showMessageBar(
                              "La descripción es obligatoria", context);
                          return;
                        } else if (priceController.text.isEmpty) {
                          showMessageBar("El precio es obligatorio", context);
                          return;
                        } else {
                          setState(() {
                            isLoading = true;
                          });
                          await FirebaseFirestore.instance
                              .collection("users")
                              .doc(FirebaseAuth.instance.currentUser!.uid)
                              .collection("business")
                              .doc()
                              .set({
                            "name": serviceNameController.text,
                            "description": descriptionController.text,
                            "price": int.parse(priceController.text),
                            "currency": currencyType,
                            "category": _expandedCategory,
                            "subcategory": _subcategoriesMap[_expandedCategory],
                          });
                          setState(() {
                            isLoading = false;
                          });
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MainDashboard()));
                        }
                      }),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  _buildCategory(BuildContext context, String category, String assetPath) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {},
            child: Image.asset(
              assetPath,
              width: 100,
              height: 100,
            ),
          ),
          GestureDetector(
            onTap: () => _toggleSubcategories(category),
            child: Text(
              category,
              style: GoogleFonts.inter(
                  color: Color(0xff4E5057),
                  fontWeight: FontWeight.bold,
                  fontSize: 17),
            ),
          ),
          if (_expandedCategory == category &&
              _subcategoriesMap[category]?.isNotEmpty == true)
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Column(
                children: _buildSubcategoriesRows(_subcategoriesMap[category]!),
              ),
            ),
        ],
      ),
    );
  }

  void _toggleSubcategories(String category) async {
    if (_expandedCategory == category) {
      setState(() {
        _expandedCategory = null; // Hide subcategories if already expanded
      });
    } else {
      final subcategories = await fetchAllSubcategories(category);
      setState(() {
        _expandedCategory =
            category; // Show subcategories for the selected category
        _subcategoriesMap[category] = subcategories;
      });
    }
  }

  Future<List<String>> fetchAllSubcategories(String category) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('categories')
          .where('category', isEqualTo: category)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final data = querySnapshot.docs.first.data();
        if (data.containsKey('subcategories') &&
            data['subcategories'] is List) {
          return List<String>.from(data['subcategories']);
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  List<Widget> _buildSubcategoriesRows(List<String> subcategories) {
    List<Widget> rows = [];
    int itemsPerRow = 4; // You want 4 items per row
    int rowCount = (subcategories.length / itemsPerRow).ceil();

    for (int i = 0; i < rowCount; i++) {
      int startIndex = i * itemsPerRow;
      int endIndex = (i + 1) * itemsPerRow;
      List<String> rowItems = subcategories.sublist(startIndex,
          endIndex > subcategories.length ? subcategories.length : endIndex);

      rows.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: rowItems.map((subcategory) {
            return Container(
              margin: const EdgeInsets.only(right: 12.0),
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              decoration: BoxDecoration(
                color: const Color(0xffF3E0FF),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Text(
                subcategory,
                style: const TextStyle(
                  color: Color(0xff6202F1),
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }).toList(),
        ),
      );
    }

    return rows;
  }
}
