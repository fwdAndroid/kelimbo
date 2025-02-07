import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kelimbo/screens/hiring/hiring_service.dart';
import 'package:kelimbo/screens/search/filters.dart';
import 'package:kelimbo/widgets/category_widget.dart';
import 'package:kelimbo/widgets/favourite_widget.dart';
import 'package:kelimbo/widgets/popular_service_widget.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController _searchController = TextEditingController();
  String _searchText = "";
  String currentUserId =
      FirebaseAuth.instance.currentUser!.uid; // Replace with actual user ID

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            floating: false,
            expandedHeight: 150,
            backgroundColor: Color(0xFFEFEFFB),
            flexibleSpace: FlexibleSpaceBar(
              background: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 50), // Status bar spacing
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (builder) => Filters()));
                    },
                    child: Align(
                      alignment: AlignmentDirectional.topEnd,
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 8.0, right: 20, bottom: 8),
                        child: Image.asset(
                          "assets/filters.png",
                          height: 20,
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16),
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
                              decoration: InputDecoration(
                                hintText: '¿Como podemos ayudarte?',
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Color(0xFF3B82F6),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.search, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Category Widget Below the AppBar
          SliverToBoxAdapter(child: CategoryWidget()),

          // Popular Services Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Servicios Populares",
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: PopularServiceWidget()),

          // Favorites Section
          const SliverToBoxAdapter(child: FavouriteWidget()),

          // Search Results
          if (_searchText.isNotEmpty)
            SliverToBoxAdapter(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("services")
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data!.docs;
                  final filteredDocs = docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return data.values.any((value) =>
                        value != null &&
                        value
                            .toString()
                            .toLowerCase()
                            .contains(_searchText.toLowerCase()));
                  }).toList();

                  if (filteredDocs.isEmpty) {
                    return Center(
                      child: Column(
                        children: [
                          Image.asset("assets/op.png", height: 200, width: 200),
                          Text("No results found for '$_searchText'.",
                              style: TextStyle(color: Colors.black)),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: filteredDocs.length,
                    itemBuilder: (context, index) {
                      final Map<String, dynamic> data =
                          filteredDocs[index].data() as Map<String, dynamic>;
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
                          child: ListTile(
                            trailing: IconButton(
                              icon: Icon(Icons.favorite,
                                  color: isFavorite ? Colors.red : Colors.grey),
                              onPressed: () async {
                                try {
                                  final docRef = FirebaseFirestore.instance
                                      .collection("services")
                                      .doc(data['uuid']);

                                  if (isFavorite) {
                                    await docRef.update({
                                      "favorite": FieldValue.arrayRemove(
                                          [currentUserId]),
                                    });
                                  } else {
                                    await docRef.update({
                                      "favorite": FieldValue.arrayUnion(
                                          [currentUserId]),
                                    });
                                  }

                                  setState(() {
                                    isFavorite = !isFavorite;
                                  });
                                } catch (e) {
                                  print("Error updating favorite status: $e");
                                }
                              },
                            ),
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(data['photo']),
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
