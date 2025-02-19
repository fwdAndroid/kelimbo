import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kelimbo/screens/hiring/hiring_service.dart';
import 'package:kelimbo/screens/main/pages/favourite_page.dart';
import 'package:kelimbo/screens/search/filters.dart';
import 'package:kelimbo/utils/colors.dart';
import 'package:kelimbo/widgets/category_widget.dart';
import 'package:kelimbo/widgets/popular_service_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  final currentUserId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Removed the normal appBar and added a CustomScrollView below
      body: CustomScrollView(
        slivers: [
          // SliverAppBar containing the search bar, filter button and CategoryWidget
          SliverAppBar(
            backgroundColor: Color(0xFFEFEFFB),
            automaticallyImplyLeading: false,
            pinned: false,
            floating: true,
            expandedHeight: 230,
            flexibleSpace: FlexibleSpaceBar(
              background: Padding(
                padding: const EdgeInsets.only(top: 30.0),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => Filters()));
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
                              child: _searchText.isEmpty
                                  ? Icon(Icons.search, color: Colors.white)
                                  : IconButton(
                                      icon: Icon(Icons.close,
                                          color: Colors.white),
                                      onPressed: () {
                                        setState(() {
                                          _searchController.clear();
                                          _searchText = '';
                                        });
                                      },
                                    ),
                            )
                          ],
                        ),
                      ),
                    ),
                    CategoryWidget(),
                  ],
                ),
              ),
            ),
          ),
          // If there is no search text, show the popular services and favourites
          if (_searchText.isEmpty) ...[
            SliverToBoxAdapter(
              child: Center(
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
            ),
            SliverToBoxAdapter(child: PopularServiceWidget()),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("services")
                  .where("favorite", arrayContains: currentUserId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return SliverToBoxAdapter(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.data!.docs.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Column(
                      children: [
                        Image.asset("assets/nofavourite.png",
                            height: 200, width: 200),
                        Text("No hay favoritos disponibles",
                            style: TextStyle(color: colorBlack)),
                      ],
                    ),
                  );
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final data = snapshot.data!.docs[index].data()
                          as Map<String, dynamic>;
                      return _buildFavoriteItem(data);
                    },
                    childCount: snapshot.data!.docs.length,
                  ),
                );
              },
            ),
          ] else
            // If there is search text, show the search results
            StreamBuilder(
              key: ValueKey(_searchText), // Optimizes re-rendering
              stream:
                  FirebaseFirestore.instance.collection("services").snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  );
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
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Column(
                        children: [
                          Image.asset(
                            "assets/op.png",
                            height: 200,
                            width: 200,
                          ),
                          Text(
                            "No results found for '$_searchText'.",
                            style: TextStyle(color: colorBlack),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final Map<String, dynamic> data =
                          filteredDocs[index].data() as Map<String, dynamic>;
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
                          child: Column(
                            children: [
                              ListTile(
                                trailing: IconButton(
                                  icon: Icon(
                                    Icons.favorite,
                                    color:
                                        isFavorite ? Colors.red : Colors.grey,
                                  ),
                                  onPressed: () async {
                                    try {
                                      final docRef = FirebaseFirestore.instance
                                          .collection("services")
                                          .doc(data[
                                              'uuid']); // Reference the service document

                                      if (isFavorite) {
                                        // Remove the current user ID from favorites
                                        await docRef.update({
                                          "favorite": FieldValue.arrayRemove(
                                              [currentUserId]),
                                        });
                                      } else {
                                        // Add the current user ID to favorites
                                        await docRef.update({
                                          "favorite": FieldValue.arrayUnion(
                                              [currentUserId]),
                                        });
                                      }

                                      setState(() {
                                        isFavorite = !isFavorite;
                                      });
                                    } catch (e) {
                                      print(
                                          "Error updating favorite status: $e");
                                    }
                                  },
                                ),
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => HiringService(
                                                serviceDescription:
                                                    data['description'],
                                                currencyType: data['currency'],
                                                userEmail: data['userEmail'],
                                                serviceId: data['uuid'],
                                                userImage: data['userImage'],
                                                userName: data['userName'],
                                                category: data['category'],
                                                totalReviews:
                                                    data['totalReviews']
                                                        .toString(),
                                                uuid: data['uuid'],
                                                uid: data['uid'],
                                                totalRating: data['totalRate']
                                                    .toString(),
                                                title: data['title'],
                                                price: data['price'].toString(),
                                                perHrPrice: data['pricePerHr']
                                                    .toString(),
                                                photo: data['photo'],
                                                description:
                                                    data['description'],
                                              )));
                                },
                                leading: CircleAvatar(
                                  backgroundImage: NetworkImage(data['photo']),
                                ),
                                title: Text(
                                  data['title'],
                                  style: GoogleFonts.inter(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                                subtitle: Text(
                                  data['category'],
                                  style: GoogleFonts.inter(
                                      color: Color(0xff9C9EA2),
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
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20),
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
                                        data['ratingCount'].toString() +
                                            " Reviews",
                                        style: GoogleFonts.inter(
                                            color: Color(0xff9C9EA2),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 19),
                                      ),
                                    ],
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: filteredDocs.length,
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildFavoriteItem(Map<String, dynamic> data) {
    return Card(
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
                    )),
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
                    fontWeight: FontWeight.bold, fontSize: 16),
              ),
              subtitle: Text(
                data['category'] ?? "No Subtitle",
                style: GoogleFonts.inter(
                    color: Color(0xff9C9EA2),
                    fontWeight: FontWeight.w300,
                    fontSize: 15),
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
                child: Icon(
                  Icons.favorite,
                  color: red,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
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
                          "${data['totalReviews'] ?? '0.0'}",
                          style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                      ],
                    ),
                    Text(
                      "${data['ratingCount'] ?? '0'} Reviews",
                      style: GoogleFonts.inter(
                          color: Color(0xff9C9EA2),
                          fontWeight: FontWeight.bold,
                          fontSize: 19),
                    ),
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
