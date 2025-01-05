import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kelimbo/screens/categories/bellaza.dart';
import 'package:kelimbo/screens/categories/entermiato.dart';
import 'package:kelimbo/screens/categories/hogar.dart';
import 'package:kelimbo/screens/categories/mascotas.dart';
import 'package:kelimbo/screens/categories/photography.dart';
import 'package:kelimbo/screens/categories/salud.dart';
import 'package:kelimbo/screens/categories/turismo.dart';
import 'package:kelimbo/screens/categories/vehiclescat.dart';

class CategoryWidget extends StatefulWidget {
  const CategoryWidget({super.key});

  @override
  State<CategoryWidget> createState() => _CategoryWidgetState();
}

class _CategoryWidgetState extends State<CategoryWidget> {
  final Map<String, List<String>> _subcategoriesMap = {};
  String? _expandedCategory;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildCategory(
                context, "Hogar", "assets/home_category.png", HogarClass()),
            _buildCategory(
                context, "Salud", "assets/health_category.png", Salud()),
            _buildCategory(
                context, "Turismo", "assets/turism_category.png", Turismo()),
            _buildCategory(context, "Entrenamiento",
                "assets/trainning_category.png", Entermiato()),
            _buildCategory(
                context, "Mascotas", "assets/pets_category.png", Mascotas()),
            _buildCategory(context, "Vehículos", "assets/vehicle_category.png",
                Vehiclescat()),
            _buildCategory(context, "Fotografía y vídeo",
                "assets/photography_category.png", Photography()),
            _buildCategory(
                context, "Belleza", "assets/beauty_category.png", Bellaza()),
          ],
        ),
      ),
    );
  }

  Widget _buildCategory(
      BuildContext context, String category, String assetPath, Widget page) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (builder) => page));
            },
            child: Image.asset(
              assetPath,
              width: 100,
              height: 70,
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

  // This function breaks the list into chunks of the desired size (4 items per row)
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
}
