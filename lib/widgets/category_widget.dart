import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (builder) => HogarClass()));
                  },
                  child: Image.asset(
                    "assets/home category.png",
                    width: 100,
                    height: 100,
                  ),
                ),
                Container(
                  height: 40,
                  width: 115,
                  decoration: BoxDecoration(
                    color: Color(0xffF3E0FF),
                    border: Border.all(
                        width: 2,
                        color: Color(
                          0xff6202F1,
                        )),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: FutureBuilder<String>(
                    future: fetchFirstSubcategory("Hogar"),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Text("Loading...");
                      } else if (snapshot.hasError || !snapshot.hasData) {
                        return Text("Error!");
                      } else {
                        return Center(
                          child: Text(
                            snapshot.data ?? "No Subcategories",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xff6202F1)),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (builder) => Salud()));
              },
              child: Column(
                children: [
                  Image.asset(
                    "assets/health category.png",
                    width: 100,
                    height: 100,
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 10, right: 10),
                    height: 40,
                    width: 115,
                    decoration: BoxDecoration(
                      color: Color(0xffF3E0FF),
                      border: Border.all(
                          width: 2,
                          color: Color(
                            0xff6202F1,
                          )),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: FutureBuilder<String>(
                      future: fetchFirstSubcategory("Salud"),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Text("Loading...");
                        } else if (snapshot.hasError || !snapshot.hasData) {
                          return Text("Error!");
                        } else {
                          return Center(
                            child: Text(
                              snapshot.data ?? "No Subcategories",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xff6202F1)),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (builder) => Turismo()));
              },
              child: Column(
                children: [
                  Image.asset(
                    "assets/turism category.png",
                    width: 100,
                    height: 100,
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 10, right: 10),
                    height: 40,
                    width: 115,
                    decoration: BoxDecoration(
                      color: Color(0xffF3E0FF),
                      border: Border.all(
                          width: 2,
                          color: Color(
                            0xff6202F1,
                          )),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: FutureBuilder<String>(
                      future: fetchFirstSubcategory("Turismo"),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Text("Loading...");
                        } else if (snapshot.hasError || !snapshot.hasData) {
                          return Text("Error!");
                        } else {
                          return Center(
                            child: Text(
                              snapshot.data ?? "No Subcategories",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xff6202F1)),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (builder) => Entermiato()));
              },
              child: Column(
                children: [
                  Image.asset(
                    "assets/trainning category.png",
                    width: 100,
                    height: 100,
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 10, right: 10),
                    height: 40,
                    width: 115,
                    decoration: BoxDecoration(
                      color: Color(0xffF3E0FF),
                      border: Border.all(
                          width: 2,
                          color: Color(
                            0xff6202F1,
                          )),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: FutureBuilder<String>(
                      future: fetchFirstSubcategory("Entrenamiento"),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Text("Loading...");
                        } else if (snapshot.hasError || !snapshot.hasData) {
                          return Text("Error!");
                        } else {
                          return Center(
                            child: Text(
                              snapshot.data ?? "No Subcategories",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xff6202F1)),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (builder) => Mascotas()));
              },
              child: Column(
                children: [
                  Image.asset(
                    "assets/pets category.png",
                    width: 100,
                    height: 100,
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 10, right: 10),
                    height: 40,
                    width: 115,
                    decoration: BoxDecoration(
                      color: Color(0xffF3E0FF),
                      border: Border.all(
                          width: 2,
                          color: Color(
                            0xff6202F1,
                          )),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: FutureBuilder<String>(
                      future: fetchFirstSubcategory("Mascotas"),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Text("Loading...");
                        } else if (snapshot.hasError || !snapshot.hasData) {
                          return Text("Error!");
                        } else {
                          return Center(
                            child: Text(
                              snapshot.data ?? "No Subcategories",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xff6202F1)),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (builder) => Vehiclescat()));
              },
              child: Column(
                children: [
                  Image.asset(
                    "assets/vehicle category.png",
                    width: 100,
                    height: 100,
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 10, right: 10),
                    height: 40,
                    width: 115,
                    decoration: BoxDecoration(
                      color: Color(0xffF3E0FF),
                      border: Border.all(
                          width: 2,
                          color: Color(
                            0xff6202F1,
                          )),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: FutureBuilder<String>(
                      future: fetchFirstSubcategory("Vehículos"),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Text("Loading...");
                        } else if (snapshot.hasError || !snapshot.hasData) {
                          return Text("Error!");
                        } else {
                          return Center(
                            child: Text(
                              snapshot.data ?? "No Subcategories",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xff6202F1)),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (builder) => Photography()));
              },
              child: Column(
                children: [
                  Image.asset(
                    "assets/photography category.png",
                    width: 100,
                    height: 100,
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 10, right: 10),
                    height: 40,
                    width: 115,
                    decoration: BoxDecoration(
                      color: Color(0xffF3E0FF),
                      border: Border.all(
                          width: 2,
                          color: Color(
                            0xff6202F1,
                          )),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: FutureBuilder<String>(
                      future: fetchFirstSubcategory("Fotografía y video"),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Text("Loading...");
                        } else if (snapshot.hasError || !snapshot.hasData) {
                          return Text("Error!");
                        } else {
                          return Center(
                            child: Text(
                              snapshot.data ?? "No Subcategories",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xff6202F1)),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (builder) => Bellaza()));
              },
              child: Column(
                children: [
                  Image.asset(
                    "assets/beauty category.png",
                    width: 100,
                    height: 100,
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 10, right: 10),
                    height: 40,
                    width: 115,
                    decoration: BoxDecoration(
                      color: Color(0xffF3E0FF),
                      border: Border.all(
                          width: 2,
                          color: Color(
                            0xff6202F1,
                          )),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: FutureBuilder<String>(
                      future: fetchFirstSubcategory("Belleza"),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Text("Loading...");
                        } else if (snapshot.hasError || !snapshot.hasData) {
                          return Text("Error!");
                        } else {
                          return Center(
                            child: Text(
                              snapshot.data ?? "No Subcategories",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xff6202F1)),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<String> fetchFirstSubcategory(String category) async {
    try {
      // Query Firestore for documents where 'category' matches
      final querySnapshot = await FirebaseFirestore.instance
          .collection('categories')
          .where('category', isEqualTo: category)
          .get();

      // Check if documents exist
      if (querySnapshot.docs.isNotEmpty) {
        final data =
            querySnapshot.docs.first.data(); // Get the first document data
        if (data.containsKey('subcategories') &&
            data['subcategories'] is List) {
          // Extract the subcategories as a List<String>
          final List<String> subcategories =
              List<String>.from(data['subcategories']);
          return subcategories.isNotEmpty
              ? subcategories.first
              : "No Subcategories"; // Return the first subcategory
        }
      }
      return "No Subcategories Found"; // Fallback if no subcategories exist
    } catch (e) {
      print("Error fetching subcategories: $e");
      return "Error";
    }
  }
}
