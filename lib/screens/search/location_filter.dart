import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
  List<String> allCityNames = [];
  List<String> availableCityNames = [];
  String? selectedMunicipality;
  TextEditingController _searchController = TextEditingController();
  TextEditingController _dropdownSearchController = TextEditingController();
  bool isLoading = true;
  final currentUserId = FirebaseAuth.instance.currentUser!.uid;
  String searchQuery = "";

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
    _searchController.addListener(_onSearchChanged);
    _dropdownSearchController.addListener(_onDropdownSearchChanged);
    _loadData();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _dropdownSearchController.removeListener(_onDropdownSearchChanged);
    _searchController.dispose();
    _dropdownSearchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    String text = _searchController.text.trim();
    if (_searchController.text != text) {
      _searchController.value = TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    }
  }

  void _onDropdownSearchChanged() {
    setState(() {
      selectedMunicipality = _dropdownSearchController.text.trim();
    });
  }

  Future<void> _loadData() async {
    try {
      await fetchCities();
      await fetchAvailableLocations();
      setState(() => isLoading = false);
    } catch (e) {
      print("Error loading data: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchCities() async {
    const apiUrl =
        "https://raw.githubusercontent.com/etereo-io/spain-communities-cities-json/master/towns.json";

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          allCityNames = data.map((item) => item["name"] as String).toList();
        });
      } else {
        throw Exception("Failed to load cities: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching cities: $e");
      rethrow;
    }
  }

  Future<void> fetchAvailableLocations() async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection('services').get();

      final Set<String> uniqueLocations = {};
      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        if (data['location'] is List) {
          final locations = (data['location'] as List).cast<String>();
          uniqueLocations.addAll(locations);
        }
      }

      setState(() {
        availableCityNames = allCityNames
            .where((city) => uniqueLocations.contains(city))
            .toList();

        if (availableCityNames.isEmpty) {
          availableCityNames = allCityNames;
        }
      });
    } catch (e) {
      print("Error fetching available locations: $e");
      setState(() => availableCityNames = allCityNames);
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
            ...filterOptions
                .map((filter) => ListTile(
                      title: Text(filter),
                      onTap: () => Navigator.pop(context, filter),
                    ))
                .toList(),
          ],
        );
      },
    );

    if (selectedFilter != null) {
      setState(() => _appliedFilters = [selectedFilter]);
    }
  }

  Query _buildQuery() {
    Query query = FirebaseFirestore.instance.collection("services");

    // SOLUTION 1: If you've created the composite index in Firestore
    query = query.where('uid', isNotEqualTo: currentUserId);

    if (selectedMunicipality != null &&
        selectedMunicipality!.trim().isNotEmpty) {
      query =
          query.where('location', arrayContains: selectedMunicipality!.trim());
    }

    // SOLUTION 2: If you prefer client-side filtering (comment out the uid filter above)
    // if (selectedMunicipality != null && selectedMunicipality!.trim().isNotEmpty) {
    //   query = query.where('location', arrayContains: selectedMunicipality!.trim());
    // }
    // Note: You'll need to filter out current user's services in the StreamBuilder

    // Apply sorting
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
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(100.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "¿Qué necesitas?",
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  onChanged: (value) =>
                      setState(() => searchQuery = value.toLowerCase()),
                ),
              ),
              if (_appliedFilters.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    children: [
                      Chip(
                        label: Text(_appliedFilters.first),
                        onDeleted: () =>
                            setState(() => _appliedFilters.clear()),
                      ),
                      Spacer(),
                    ],
                  ),
                ),
            ],
          ),
        ),
        title: const Text("Filtrar por ubicación"),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () => _showFilterMenu(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownSearch<String>(
              items: availableCityNames,
              popupProps: PopupProps.menu(
                showSearchBox: true,
                searchFieldProps: TextFieldProps(
                  controller: _dropdownSearchController,
                  decoration: InputDecoration(
                    hintText: "Buscar ubicación...",
                  ),
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
              onChanged: (value) => setState(() {
                selectedMunicipality = value;
                _dropdownSearchController.text = value ?? "";
              }),
              selectedItem: selectedMunicipality,
            ),
          ),
          if (isLoading)
            Center(child: CircularProgressIndicator())
          else
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _buildQuery().snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return _buildNoResultsWidget();
                  }

                  // If using SOLUTION 2 (client-side filtering), add this filter:
                  // final filteredDocs = snapshot.data!.docs.where((doc) {
                  //   final data = doc.data() as Map<String, dynamic>;
                  //   return data['uid'] != currentUserId;
                  // }).toList();

                  // If using SOLUTION 1 (composite index), use this:
                  final filteredDocs = _filterDocuments(snapshot.data!.docs);

                  if (filteredDocs.isEmpty) {
                    return _buildNoResultsWidget();
                  }

                  return ListView.builder(
                    itemCount: filteredDocs.length,
                    itemBuilder: (context, index) =>
                        _buildServiceCard(filteredDocs[index]),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNoResultsWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.search_off, size: 100, color: Colors.grey),
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            "No se han encontrado resultados para la búsqueda actual.",
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  List<DocumentSnapshot> _filterDocuments(List<DocumentSnapshot> docs) {
    return docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final userName = data['userName']?.toString().toLowerCase() ?? '';
      final serviceName = data['title']?.toString().toLowerCase() ?? '';
      final location = data['location'] is List
          ? (data['location'] as List).join(", ").toLowerCase()
          : data['location']?.toString().toLowerCase() ?? '';
      final price = data['price']?.toString().toLowerCase() ?? '';

      if (searchQuery.isEmpty) return true;

      return userName.contains(searchQuery) ||
          serviceName.contains(searchQuery) ||
          location.contains(searchQuery) ||
          price.contains(searchQuery);
    }).toList();
  }

  Widget _buildServiceCard(DocumentSnapshot document) {
    final data = document.data() as Map<String, dynamic>;
    final favorites = data['favorite'] ?? [];
    final isFavorite = favorites.contains(currentUserId);

    return GestureDetector(
      onTap: () => _navigateToServiceDetail(context, data),
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            ListTile(
              trailing: IconButton(
                icon: Icon(Icons.favorite,
                    color: isFavorite ? Colors.red : Colors.grey),
                onPressed: () => _toggleFavorite(document, isFavorite),
              ),
              leading: CircleAvatar(
                  backgroundImage: NetworkImage(data['photo'] ?? "")),
              title: Text(
                data['title'] ?? "No Title",
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold, fontSize: 16),
              ),
              subtitle: Text(
                _formatLocation(data['location']),
                style: GoogleFonts.inter(
                  color: const Color(0xff9C9EA2),
                  fontWeight: FontWeight.w300,
                  fontSize: 13,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildPriceInfo(data),
                  Image.asset("assets/line.png", height: 40, width: 52),
                  _buildRatingInfo(data),
                ],
              ),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  String _formatLocation(dynamic location) {
    if (location == null) return "No location";
    if (location is List && location.length > 10)
      return "Todas las ciudades de España";
    if (location is List) return location.join(", ");
    return location.toString();
  }

  Widget _buildPriceInfo(Map<String, dynamic> data) {
    return Column(
      children: [
        Text(
          "€${data['price'].toString()}",
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 20),
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
    );
  }

  Widget _buildRatingInfo(Map<String, dynamic> data) {
    return Column(
      children: [
        Row(
          children: [
            const Icon(Icons.star, color: Colors.yellow),
            Text(
              data['totalReviews']?.toString() ?? "0",
              style:
                  GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 20),
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
    );
  }

  Future<void> _toggleFavorite(DocumentSnapshot doc, bool isFavorite) async {
    try {
      await FirebaseFirestore.instance
          .collection('services')
          .doc(doc.id)
          .update({
        'favorite': isFavorite
            ? FieldValue.arrayRemove([currentUserId])
            : FieldValue.arrayUnion([currentUserId])
      });
    } catch (e) {
      print("Error toggling favorite: $e");
    }
  }

  void _navigateToServiceDetail(
      BuildContext context, Map<String, dynamic> data) {
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
  }
}
