import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kelimbo/screens/categories/location_filter_category.dart';
import 'package:kelimbo/screens/hiring/hiring_service.dart';
import 'package:kelimbo/screens/main/pages/favourite_page.dart';
import 'package:kelimbo/screens/services/edit_service.dart';
import 'package:kelimbo/utils/colors.dart';

class CategoryPage extends StatefulWidget {
  final String categoryName;

  const CategoryPage({super.key, required this.categoryName});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final String? currentUserUid = FirebaseAuth.instance.currentUser?.uid;
  String searchQuery = "";
  List<String> _appliedFilters = [];

  final List<String> filterOptions = [
    "Precio más alto",
    "Precio más bajo",
    "Calificación más alta",
    "Calificación más baja",
    "Más trabajo realizado",
    "Menos trabajo realizado",
  ];

  String removeDiacritics(String str) {
    const withDia =
        'ÀÁÂÃÄÅàáâãäåÒÓÔÕÕÖØòóôõöøÈÉÊËèéêëðÇçÐÌÍÎÏìíîïÙÚÛÜùúûüÑñŠšŸÿýŽž';
    const withoutDia =
        'AAAAAAaaaaaaOOOOOOOooooooEEEEeeeeeCcDIIIIiiiiUUUUuuuuNnSsYyyZz';

    for (int i = 0; i < withDia.length; i++) {
      str = str.replaceAll(withDia[i], withoutDia[i]);
    }

    return str;
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
    Query query = FirebaseFirestore.instance
        .collection("services")
        .where("category", isEqualTo: widget.categoryName);

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
            icon: Image.asset("assets/filters.png", height: 20),
            onPressed: () => _showFilterMenu(context),
          ),
        ],
        centerTitle: true,
        title: Text(widget.categoryName),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(100.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "Buscar",
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
                    IconButton(
                      icon: Icon(Icons.location_pin),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LocationFilterCategory(
                              locationCategory: widget.categoryName,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
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
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _buildQuery().snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                "No hay servicios disponibles en esta categoría",
                style: TextStyle(color: colorBlack),
              ),
            );
          }

          final List<DocumentSnapshot> filteredDocuments =
              snapshot.data!.docs.where((doc) {
            final Map<String, dynamic> data =
                doc.data() as Map<String, dynamic>;
            final title =
                removeDiacritics(data['title']?.toString().toLowerCase() ?? '');
            final description = removeDiacritics(
                data['description']?.toString().toLowerCase() ?? '');
            final searchNormalized =
                removeDiacritics(searchQuery.toLowerCase());

            return title.contains(searchNormalized) ||
                description.contains(searchNormalized);
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
              return GestureDetector(
                onTap: () {
                  if (data['uid'] == currentUserUid) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (builder) =>
                              EditService(uuid: data['uuid'])),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (builder) => HiringService(
                          serviceId: data['uuid'],
                          currencyType: data['currency'],
                          userEmail: data['userEmail'],
                          userImage: data['userImage'],
                          userName: data['userName'],
                          category: data['category'],
                          totalReviews: data['totalReviews'].toString(),
                          uuid: data['uuid'],
                          serviceDescription: data['description'],
                          uid: data['uid'],
                          totalRating: data['totalRate'].toString(),
                          title: data['title'],
                          price: data['price'].toString(),
                          perHrPrice: data['pricePerHr'].toString(),
                          photo: data['photo'],
                          description: data['description'],
                        ),
                      ),
                    );
                  }
                },
                child: Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    children: [
                      ListTile(
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
                              color: Color(0xff9C9EA2),
                              fontWeight: FontWeight.w300,
                              fontSize: 15),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                Text(
                                  "${getCurrencySymbol(data['currency'] ?? 'Euro')}${data['price'] ?? '0.0'}",
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                                Text(
                                  data['priceType'],
                                  style: GoogleFonts.inter(
                                      color: Color(0xff9C9EA2),
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
                                    Icon(
                                      Icons.star,
                                      color: yellow,
                                    ),
                                    Text(
                                      data['totalReviews'].toString(),
                                      style: GoogleFonts.inter(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20),
                                    ),
                                  ],
                                ),
                                Text(
                                  data['ratingCount'].toString() + " Reviews",
                                  style: GoogleFonts.inter(
                                      color: Color(0xff9C9EA2),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 19),
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
    );
  }
}
