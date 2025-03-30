import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kelimbo/screens/hiring/hiring_service.dart';
import 'package:kelimbo/screens/search/location_filter.dart';
import 'package:kelimbo/widgets/category_widget.dart';
import 'package:kelimbo/widgets/popular_service_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
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
    Query query = FirebaseFirestore.instance.collection("services");

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
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: const Color(0xFFEFEFFB),
            automaticallyImplyLeading: false,
            pinned: false,
            floating: true,
            expandedHeight: 230,
            flexibleSpace: FlexibleSpaceBar(
              background: Padding(
                padding: const EdgeInsets.only(top: 30.0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Align(
                        alignment: Alignment.topRight,
                        child: GestureDetector(
                          onTap: () => _showFilterMenu(context),
                          child: Image.asset(
                            "assets/filters.png",
                            height: 20,
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        width: MediaQuery.of(context).size.width * 0.9,
                        height: 50,
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                onChanged: (value) {
                                  setState(() {
                                    _searchText = value.trim();
                                  });
                                },
                                decoration: const InputDecoration(
                                  hintText: '¿Cómo podemos ayudarte?',
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                color: Color(0xFF3B82F6),
                                shape: BoxShape.circle,
                              ),
                              child: _searchText.isEmpty
                                  ? const Icon(Icons.search,
                                      color: Colors.white)
                                  : IconButton(
                                      icon: const Icon(Icons.close,
                                          color: Colors.white),
                                      onPressed: () {
                                        setState(() {
                                          _searchController.clear();
                                          _searchText = '';
                                        });
                                      },
                                    ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LocationFilter(),
                                  ),
                                );
                              },
                              child: const Icon(Icons.location_pin),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const CategoryWidget(),
                  ],
                ),
              ),
            ),
          ),
          if (_appliedFilters.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Wrap(
                  children: _appliedFilters.map((filter) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Chip(
                        label: Text(filter),
                        onDeleted: () {
                          setState(() {
                            _appliedFilters.remove(filter);
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          _buildContent(),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_searchText.isNotEmpty) {
      return _buildSearchResults();
    } else if (_appliedFilters.isNotEmpty) {
      return _buildFilteredResults();
    } else {
      return _buildDefaultContent();
    }
  }

  Widget _buildDefaultContent() {
    return SliverList(
      delegate: SliverChildListDelegate([
        Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Servicios Populares",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        const PopularServiceWidget(),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("services")
              .where("favorite", arrayContains: currentUserId)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.data!.docs.isEmpty) {
              return Column(
                children: [
                  Image.asset("assets/nofavourite.png",
                      height: 200, width: 200),
                  const Text(
                    "No hay favoritos disponibles",
                    style: TextStyle(color: Colors.black),
                  ),
                ],
              );
            }
            return Column(
              children: snapshot.data!.docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return _buildFavoriteItem(data);
              }).toList(),
            );
          },
        ),
      ]),
    );
  }

  Widget _buildFilteredResults() {
    return StreamBuilder<QuerySnapshot>(
      stream: _buildQuery().snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SliverToBoxAdapter(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return const SliverToBoxAdapter(
            child: Center(
              child: Text("No se encontraron servicios"),
            ),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              return _buildServiceCard(data);
            },
            childCount: docs.length,
          ),
        );
      },
    );
  }

  Widget _buildSearchResults() {
    return StreamBuilder<QuerySnapshot>(
      key: ValueKey(_searchText),
      stream: FirebaseFirestore.instance.collection("services").snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        final docs = snapshot.data!.docs;
        final filteredDocs = docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final title =
              removeDiacritics(data['title']?.toString().toLowerCase() ?? '');
          final description = removeDiacritics(
              data['description']?.toString().toLowerCase() ?? '');
          final category = removeDiacritics(
              data['category']?.toString().toLowerCase() ?? '');
          final searchNormalized = removeDiacritics(_searchText.toLowerCase());

          return title.contains(searchNormalized) ||
              description.contains(searchNormalized) ||
              category.contains(searchNormalized);
        }).toList();

        if (filteredDocs.isEmpty) {
          return SliverToBoxAdapter(
            child: Center(
              child: Column(
                children: [
                  Image.asset("assets/op.png", height: 200, width: 200),
                  Text(
                    "No se han encontrado resultados para '$_searchText'.",
                    style: const TextStyle(color: Colors.black),
                  ),
                ],
              ),
            ),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final data = filteredDocs[index].data() as Map<String, dynamic>;
              return _buildServiceCard(data);
            },
            childCount: filteredDocs.length,
          ),
        );
      },
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> data) {
    final List<dynamic> favorites = data['favorite'] ?? [];
    bool isFavorite = favorites.contains(currentUserId);

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
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            ListTile(
              trailing: IconButton(
                icon: Icon(
                  Icons.favorite,
                  color: isFavorite ? Colors.red : Colors.grey,
                ),
                onPressed: () async {
                  try {
                    final docRef = FirebaseFirestore.instance
                        .collection("services")
                        .doc(data['uuid']);

                    if (isFavorite) {
                      await docRef.update({
                        "favorite": FieldValue.arrayRemove([currentUserId]),
                      });
                    } else {
                      await docRef.update({
                        "favorite": FieldValue.arrayUnion([currentUserId]),
                      });
                    }

                    setState(() {
                      isFavorite = !isFavorite;
                    });
                  } catch (e) {
                    debugPrint("Error updating favorite status: $e");
                  }
                },
              ),
              leading: CircleAvatar(
                backgroundImage: NetworkImage(data['photo']),
              ),
              title: Text(
                data['title'],
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Text(
                data['category'],
                style: GoogleFonts.inter(
                  color: const Color(0xff9C9EA2),
                  fontWeight: FontWeight.w300,
                  fontSize: 15,
                ),
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
                        "€${data['price'].toString()}",
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      Text(
                        data['priceType'],
                        style: GoogleFonts.inter(
                          color: const Color(0xff9C9EA2),
                          fontWeight: FontWeight.bold,
                          fontSize: 19,
                        ),
                      ),
                    ],
                  ),
                  Image.asset("assets/line.png", height: 40, width: 52),
                  Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.yellow),
                          Text(
                            data['totalReviews'].toString(),
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        "${data['ratingCount'].toString()} Reviews",
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
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoriteItem(Map<String, dynamic> data) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HiringService(
                userEmail: data['userEmail'],
                serviceDescription: data['description'],
                userImage: data['userImage'],
                userName: data['userName'],
                category: data['category'],
                totalReviews: data['totalReviews'].toString(),
                uuid: data['uuid'],
                uid: data['uid'],
                currencyType: data['currency'],
                totalRating: data['totalRate'].toString(),
                title: data['title'],
                price: data['price'].toString(),
                serviceId: data['uuid'],
                perHrPrice: data['pricePerHr'].toString(),
                photo: data['photo'],
                description: data['description'],
              ),
            ),
          );
        },
        child: Column(
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundImage:
                    NetworkImage(data['photo'] ?? "assets/logo.png"),
              ),
              title: Text(
                data['title'] ?? "No Title",
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Text(
                data['category'] ?? "No Subtitle",
                style: GoogleFonts.inter(
                  color: const Color(0xff9C9EA2),
                  fontWeight: FontWeight.w300,
                  fontSize: 15,
                ),
              ),
              trailing: GestureDetector(
                onTap: () async {
                  final docRef = FirebaseFirestore.instance
                      .collection("services")
                      .doc(data['uuid']);
                  await docRef.update({
                    "favorite": FieldValue.arrayRemove([currentUserId])
                  });
                },
                child: const Icon(Icons.favorite, color: Colors.red),
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
                        "€${data['price'] ?? '0.0'}",
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      Text(
                        data['priceType'],
                        style: GoogleFonts.inter(
                          color: const Color(0xff9C9EA2),
                          fontWeight: FontWeight.bold,
                          fontSize: 19,
                        ),
                      ),
                    ],
                  ),
                  Image.asset("assets/line.png", height: 40, width: 52),
                  Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.yellow),
                          Text(
                            "${data['totalReviews'] ?? '0.0'}",
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        "${data['ratingCount'] ?? '0'} Reviews",
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
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
