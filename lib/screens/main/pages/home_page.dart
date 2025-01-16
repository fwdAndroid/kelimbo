import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kelimbo/screens/hiring/hiring_service.dart';
import 'package:kelimbo/screens/search/filters.dart';
import 'package:kelimbo/utils/colors.dart';
import 'package:kelimbo/widgets/category_widget.dart';
import 'package:kelimbo/widgets/favourite_widget.dart';
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
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100), // Adjust the height as needed
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor:
              Color(0xFFEFEFFB), // Background color similar to your image
          elevation: 0,
          flexibleSpace: Padding(
            padding: const EdgeInsets.only(
                top: 30.0), // Add padding to position the search bar
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (builder) => Filters()));
                  },
                  child: Align(
                    alignment: AlignmentDirectional.topEnd,
                    child: Padding(
                      padding:
                          const EdgeInsets.only(top: 8.0, right: 20, bottom: 8),
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
                                _searchText =
                                    value.trim(); // Update search text
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
      ),
      body: SingleChildScrollView(
        child: _searchText.isEmpty
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CategoryWidget(),
                  Center(
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
                  PopularServiceWidget(),
                  FavouriteWidget(),
                ],
              )
            : StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("services")
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
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
                    return Center(
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
                                        final docRef = FirebaseFirestore
                                            .instance
                                            .collection("services")
                                            .doc(data[
                                                'uuid']); // Reference the service document

                                        if (isFavorite) {
                                          // If already favorited, remove current user ID from the favorites list
                                          await docRef.update({
                                            "favorite": FieldValue.arrayRemove(
                                                [currentUserId]),
                                          });
                                        } else {
                                          // If not favorited, add current user ID to the favorites list
                                          await docRef.update({
                                            "favorite": FieldValue.arrayUnion(
                                                [currentUserId]),
                                          });
                                        }

                                        setState(() {
                                          // Update local state to reflect the new favorite status
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
                                            builder: (builder) => HiringService(
                                                  serviceDescription:
                                                      data['description'],
                                                  currencyType:
                                                      data['currency'],
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
                                                  price:
                                                      data['price'].toString(),
                                                  perHrPrice: data['pricePerHr']
                                                      .toString(),
                                                  photo: data['photo'],
                                                  description:
                                                      data['description'],
                                                )));
                                  },
                                  leading: CircleAvatar(
                                    backgroundImage:
                                        NetworkImage(data['photo']),
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
                      });
                },
              ),
      ),
    );
  }
}
