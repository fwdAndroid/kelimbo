import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kelimbo/screens/hiring/hiring_service.dart';
import 'package:http/http.dart' as http;
import 'package:kelimbo/utils/colors.dart';

class LocationFilter extends StatefulWidget {
  const LocationFilter({Key? key}) : super(key: key);

  @override
  State<LocationFilter> createState() => _LocationFilterState();
}

class _LocationFilterState extends State<LocationFilter> {
  List<String> cityNames = [];
  String? selectedMunicipality;
  TextEditingController _searchController = TextEditingController();
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    fetchCities();

    _searchController.addListener(() {
      String text = _searchController.text.trim(); // Trim spaces
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

  Stream<QuerySnapshot> _getFilteredQuery() {
    final servicesCollection =
        FirebaseFirestore.instance.collection("services");

    if (selectedMunicipality == null || selectedMunicipality!.trim().isEmpty) {
      return servicesCollection.snapshots();
    }

    return servicesCollection
        .where('location',
            arrayContains:
                selectedMunicipality!.trim()) // ✅ Filter by arrayContains
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60.0),
          child: Padding(
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
        ),
        title: const Text("Filtrar por ubicación"),
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
                ),
              ),
              onChanged: (value) {
                setState(() {
                  selectedMunicipality = value.toString();
                });
              },
              selectedItem: "Seleccionar ubicación",
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getFilteredQuery(),
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
                      const Center(
                        child: Text(
                          "No se han encontrado resultados para la ubicación introducida.",
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
                  final String location =
                      data['location']?.toString().toLowerCase() ?? '';
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
                    final DocumentSnapshot document =
                        snapshot.data!.docs[index];
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
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
                                const SizedBox(width: 16),
                                Column(
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.star,
                                            color: Colors.yellow),
                                        Text(
                                          data['ratingCount']?.toString() ??
                                              "0",
                                          style: GoogleFonts.inter(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      "${data['totalReviews']?.toString() ?? "0"} Reviews",
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
