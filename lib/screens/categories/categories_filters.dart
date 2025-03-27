import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:group_button/group_button.dart';
import 'package:kelimbo/screens/hiring/hiring_service.dart';
import 'package:kelimbo/utils/colors.dart';

class CategoriesFilters extends StatefulWidget {
  final String categoryName;

  const CategoriesFilters({Key? key, required this.categoryName})
      : super(key: key);

  @override
  State<CategoriesFilters> createState() => _CategoriesFiltersState();
}

class _CategoriesFiltersState extends State<CategoriesFilters> {
  List<String> specialSituations = [
    "Precio más alto",
    "Precio más bajo",
    "Calificación más alta",
    "Calificación más baja",
    "Más trabajo realizado",
    "Menos trabajo realizado",
  ];

  List<String> selectedCategoriesFilters = [];
  List<String> appliedCategoriesFilters = [];
  final currentUserId = FirebaseAuth.instance.currentUser!.uid;
  late Stream<QuerySnapshot> _filteredStream;

  @override
  void initState() {
    super.initState();
    _filteredStream = _getFilteredQuery();
  }

  @override
  void didUpdateWidget(CategoriesFilters oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.categoryName != widget.categoryName) {
      _filteredStream = _getFilteredQuery();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Ordenar Por:",
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: colorBlack,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close),
        ),
      ),
      body: Column(
        children: [
          GroupButton(
            buttons: specialSituations,
            onSelected: (value, index, isSelected) {
              setState(() {
                selectedCategoriesFilters.clear();
                if (isSelected) {
                  selectedCategoriesFilters.add(value);
                }
                appliedCategoriesFilters = List.from(selectedCategoriesFilters);
                _filteredStream = _getFilteredQuery();
              });
            },
            isRadio: true,
            options: GroupButtonOptions(
              buttonWidth: 150,
              unselectedTextStyle: GoogleFonts.poppins(
                color: colorBlack,
                fontSize: 11,
              ),
              selectedTextStyle: GoogleFonts.poppins(
                color: colorWhite,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
              selectedBorderColor: mainColor,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: appliedCategoriesFilters.isEmpty
                ? _buildEmptyFilterState()
                : StreamBuilder<QuerySnapshot>(
                    stream: _filteredStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting &&
                          !snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return _buildNoResultsState();
                      }

                      return RefreshIndicator(
                        onRefresh: () async {
                          setState(() {
                            _filteredStream = _getFilteredQuery();
                          });
                        },
                        child: ListView.builder(
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            final DocumentSnapshot document =
                                snapshot.data!.docs[index];
                            final data =
                                document.data() as Map<String, dynamic>;
                            final List<dynamic> favorites =
                                data['favorite'] ?? [];
                            bool isFavorite = favorites.contains(currentUserId);

                            return _buildServiceCard(
                                data, isFavorite, document.id);
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyFilterState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.filter_alt_outlined,
            size: 100,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            "Filtros disponibles para: ${widget.categoryName}",
            style: const TextStyle(color: Colors.black, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            "Seleccione un filtro para ver los resultados",
            style: TextStyle(color: Colors.grey, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 100, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            "No se encontraron resultados para ${widget.categoryName}",
            style: const TextStyle(color: Colors.black, fontSize: 16),
          ),
          if (appliedCategoriesFilters.isNotEmpty)
            const Text(
              "con los filtros aplicados",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(
      Map<String, dynamic> data, bool isFavorite, String documentId) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HiringService(
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
                        .doc(documentId)
                        .update({
                      'favorite': FieldValue.arrayRemove([currentUserId])
                    });
                  } else {
                    await FirebaseFirestore.instance
                        .collection('services')
                        .doc(documentId)
                        .update({
                      'favorite': FieldValue.arrayUnion([currentUserId])
                    });
                  }
                },
              ),
              leading: CircleAvatar(
                backgroundImage: NetworkImage(data['userImage']),
              ),
              title: Text(
                data['title'],
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold, fontSize: 16),
              ),
              subtitle: Text(
                data['category'],
                style: GoogleFonts.inter(
                    color: const Color(0xff9C9EA2),
                    fontWeight: FontWeight.w300,
                    fontSize: 15),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Text(
                      "€" + data['price'].toString(),
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    Text(
                      data['priceType'],
                      style: GoogleFonts.inter(
                          color: const Color(0xff9C9EA2),
                          fontWeight: FontWeight.bold,
                          fontSize: 19),
                    ),
                  ],
                ),
                Image.asset(
                  "assets/line.png",
                  height: 40,
                  width: 52,
                ),
                Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.yellow),
                        Text(
                          data['totalReviews'].toString(),
                          style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                      ],
                    ),
                    Text(
                      data['ratingCount'].toString() + " Reviews",
                      style: GoogleFonts.inter(
                          color: const Color(0xff9C9EA2),
                          fontWeight: FontWeight.bold,
                          fontSize: 19),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Stream<QuerySnapshot> _getFilteredQuery() {
    Query query = FirebaseFirestore.instance
        .collection("services")
        .where('category', isEqualTo: widget.categoryName);

    if (appliedCategoriesFilters.contains("Precio más alto")) {
      query = query.orderBy("price", descending: true);
    } else if (appliedCategoriesFilters.contains("Precio más bajo")) {
      query = query.orderBy("price");
    }

    if (appliedCategoriesFilters.contains("Calificación más alta")) {
      query = query.orderBy("totalReviews", descending: true);
    } else if (appliedCategoriesFilters.contains("Calificación más baja")) {
      query = query.orderBy("totalReviews");
    }

    if (appliedCategoriesFilters.contains("Más trabajo realizado")) {
      query = query.orderBy("numberOfJobs", descending: true);
    } else if (appliedCategoriesFilters.contains("Menos trabajo realizado")) {
      query = query.orderBy("numberOfJobs");
    }

    if (appliedCategoriesFilters.contains("Ubicación")) {
      query = query.orderBy("location");
    }

    return query.snapshots();
  }
}
