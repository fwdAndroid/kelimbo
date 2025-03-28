import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kelimbo/screens/hiring/hiring_service.dart';
import 'package:kelimbo/utils/colors.dart';

class LocationFilterCategory extends StatefulWidget {
  final String locationCategory;
  const LocationFilterCategory({super.key, required this.locationCategory});

  @override
  State<LocationFilterCategory> createState() => _LocationFilterCategoryState();
}

class _LocationFilterCategoryState extends State<LocationFilterCategory> {
  List<String> cityNames = [];
  String? selectedMunicipality;
  TextEditingController _searchController = TextEditingController();
  bool isLoading = true;

  // Filter options and state
  final List<String> filterOptions = [
    "Precio más alto",
    "Precio más bajo",
    "Calificación más alta",
    "Calificación más baja",
    "Más trabajo realizado",
    "Menos trabajo realizado",
  ];
  List<String> _appliedFilters = [];

  @override
  void initState() {
    super.initState();
    fetchCities();
    _searchController.addListener(() {
      String text = _searchController.text.trim();
      if (_searchController.text != text) {
        _searchController.value = TextEditingValue(
          text: text,
          selection: TextSelection.collapsed(offset: text.length),
        );
      }
    });
  }

  final currentUserId = FirebaseAuth.instance.currentUser!.uid;
  String searchQuery = "";

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
        });
      } else {
        print("Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  void _showFilterMenu(BuildContext context) async {
    final selectedFilter = await showModalBottomSheet<String>(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Ordenar por:',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Divider(),
            ...filterOptions.map((filter) {
              return ListTile(
                title: Text(filter),
                onTap: () => Navigator.pop(context, filter),
              );
            }).toList(),
          ],
        );
      },
    );

    if (selectedFilter != null) {
      setState(() {
        _appliedFilters = [selectedFilter];
      });
    }
  }

  Query _buildQuery() {
    // Start with base query filtered by category
    Query query = FirebaseFirestore.instance
        .collection("services")
        .where('category', isEqualTo: widget.locationCategory);

    // Apply location filter if selected
    if (selectedMunicipality != null &&
        selectedMunicipality!.trim().isNotEmpty) {
      query =
          query.where('location', arrayContains: selectedMunicipality!.trim());
    }

    // Apply sorting filters
    if (_appliedFilters.contains("Precio más alto")) {
      query = query.orderBy("price", descending: true);
    } else if (_appliedFilters.contains("Precio más bajo")) {
      query = query.orderBy("price");
    } else if (_appliedFilters.contains("Calificación más alta")) {
      query = query.orderBy("totalReviews", descending: true);
    } else if (_appliedFilters.contains("Calificación más baja")) {
      query = query.orderBy("totalReviews");
    } else if (_appliedFilters.contains("Más trabajo realizado")) {
      query = query.orderBy("numberOfJobs", descending: true);
    } else if (_appliedFilters.contains("Menos trabajo realizado")) {
      query = query.orderBy("numberOfJobs");
    }

    return query;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () => _showFilterMenu(context),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(100.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "¿Qué necesitas?",
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value.toLowerCase();
                    });
                  },
                ),
              ),
              if (_appliedFilters.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Chip(
                        label: Text(_appliedFilters.first),
                        onDeleted: () {
                          setState(() {
                            _appliedFilters.clear();
                          });
                        },
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        title: Text("${widget.locationCategory} - Filtrar por ubicación"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownSearch<String>(
              items: cityNames,
              popupProps: PopupProps.menu(
                showSearchBox: true,
                searchFieldProps: TextFieldProps(
                  controller: _searchController,
                ),
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
                  hintText: "Seleccionar ubicación",
                ),
              ),
              onChanged: (value) {
                setState(() {
                  selectedMunicipality = value;
                });
              },
              selectedItem: selectedMunicipality,
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _buildQuery().snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 100,
                        color: Colors.grey,
                      ),
                      Center(
                        child: Text(
                          "No se han encontrado servicios en esta ubicación para ${widget.locationCategory}.",
                          style: TextStyle(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  );
                }

                final List<DocumentSnapshot> filteredDocuments =
                    snapshot.data!.docs.where((doc) {
                  final Map<String, dynamic> data =
                      doc.data() as Map<String, dynamic>;
                  final String userName =
                      data['userName']?.toString().toLowerCase() ?? '';
                  final String serviceName =
                      data['title']?.toString().toLowerCase() ?? '';
                  final String location = data['location'] is List
                      ? (data['location'] as List).join(", ").toLowerCase()
                      : data['location']?.toString().toLowerCase() ?? '';
                  final String price =
                      data['price']?.toString().toLowerCase() ?? '';

                  return userName.contains(searchQuery) ||
                      serviceName.contains(searchQuery) ||
                      location.contains(searchQuery) ||
                      price.contains(searchQuery);
                }).toList();

                if (filteredDocuments.isEmpty) {
                  return Center(
                    child: Text(
                      "No se han encontrado resultados",
                      style: TextStyle(color: colorBlack),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filteredDocuments.length,
                  itemBuilder: (context, index) {
                    final Map<String, dynamic> data =
                        filteredDocuments[index].data() as Map<String, dynamic>;
                    final DocumentSnapshot document = filteredDocuments[index];
                    final List<dynamic> favorites = data['favorite'] ?? [];
                    bool isFavorite = favorites.contains(currentUserId);

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (builder) => HiringService(
                              serviceDescription: data['description'],
                              serviceId: data['uuid'],
                              currencyType: data['currency'],
                              price: data['price'].toString(),
                              userEmail: data['userEmail'],
                              userImage: data['userImage'],
                              userName: data['userName'],
                              category: data['category'],
                              totalReviews: data['totalReviews'].toString(),
                              uuid: data['uuid'],
                              uid: data['uid'],
                              totalRating: data['totalRate'].toString(),
                              title: data['title'],
                              perHrPrice: data['pricePerHr'].toString(),
                              photo: data['photo'],
                              description: data['description'],
                            ),
                          ),
                        );
                      },
                      child: Card(
                        margin:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Column(
                          children: [
                            ListTile(
                              trailing: IconButton(
                                icon: Icon(
                                  Icons.favorite,
                                  color: isFavorite ? Colors.red : Colors.grey,
                                ),
                                onPressed: () async {
                                  if (isFavorite) {
                                    await FirebaseFirestore.instance
                                        .collection('services')
                                        .doc(document.id)
                                        .update({
                                      'favorite': FieldValue.arrayRemove(
                                          [currentUserId])
                                    });
                                  } else {
                                    await FirebaseFirestore.instance
                                        .collection('services')
                                        .doc(document.id)
                                        .update({
                                      'favorite':
                                          FieldValue.arrayUnion([currentUserId])
                                    });
                                  }
                                },
                              ),
                              leading: CircleAvatar(
                                backgroundImage:
                                    NetworkImage(data['photo'] ?? ""),
                              ),
                              title: Text(
                                data['title'] ?? "No Title",
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Text(
                                (data['location'] != null &&
                                        (data['location'] as List<dynamic>)
                                                .length >
                                            10)
                                    ? "Todas las ciudades de España"
                                    : (data['location'] as List<dynamic>?)
                                            ?.join(", ") ??
                                        "No location",
                                style: GoogleFonts.inter(
                                  color: const Color(0xff9C9EA2),
                                  fontWeight: FontWeight.w300,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Column(
                                    children: [
                                      Text(
                                        "€${data['price'].toString()}",
                                        style: GoogleFonts.inter(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),
                                      Text(
                                        data['priceType'] ?? "No price type",
                                        style: GoogleFonts.inter(
                                          color: const Color(0xff9C9EA2),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 19,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Image.asset("assets/line.png",
                                      height: 40, width: 52),
                                  Column(
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.star,
                                              color: Colors.yellow),
                                          Text(
                                            data['totalReviews']?.toString() ??
                                                "0",
                                            style: GoogleFonts.inter(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        "${data['ratingCount']?.toString() ?? "0"} Reviews",
                                        style: GoogleFonts.inter(
                                          color: const Color(0xff9C9EA2),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 19,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 16),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
