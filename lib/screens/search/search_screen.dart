import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kelimbo/screens/hiring/hiring_service.dart';
import 'package:kelimbo/utils/colors.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  final currentUserId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
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
                    child: IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.arrow_forward, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: _searchText.isEmpty
                ? Center(
                    child: Text(
                      "Por favor ingresa un término de búsqueda",
                      style: TextStyle(color: colorBlack),
                    ),
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
                      if (snapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Text(
                            "No hay servicio disponible",
                            style: TextStyle(color: colorBlack),
                          ),
                        );
                      }

                      final filteredDocs = snapshot.data!.docs.where((doc) {
                        final data = doc.data() as Map<String, dynamic>;

                        // Check if _searchText exists in any field of the document
                        return data.values.any((value) => value
                            .toString()
                            .toLowerCase()
                            .contains(_searchText.toLowerCase()));
                      }).toList();
                      if (filteredDocs.isEmpty) {
                        return Center(
                          child: Text(
                            "No se han encontrado resultados",
                            style: TextStyle(
                                color:
                                    const Color.fromARGB(255, 150, 146, 146)),
                          ),
                        );
                      }
                      return ListView.builder(
                          itemCount: filteredDocs.length,
                          itemBuilder: (context, index) {
                            final Map<String, dynamic> data =
                                filteredDocs[index].data()
                                    as Map<String, dynamic>;
                            final List<dynamic> favorites =
                                data['favorite'] ?? [];

                            bool isFavorite = favorites.contains(currentUserId);
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (builder) => HiringService(
                                      serviceId: data['uuid'],
                                      currencyType: data['currency'],
                                      price: data['price'].toString(),
                                      userEmail: data['userEmail'],
                                      userImage: data['userImage'],
                                      userName: data['userName'],
                                      category: data['category'],
                                      totalReviews:
                                          data['totalReviews'].toString(),
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
                                          color: isFavorite
                                              ? Colors.red
                                              : Colors.grey,
                                        ),
                                        onPressed: () async {},
                                      ),
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (builder) =>
                                                    HiringService(
                                                      currencyType:
                                                          data['currency'],
                                                      userEmail:
                                                          data['userEmail'],
                                                      serviceId: data['uuid'],
                                                      userImage:
                                                          data['userImage'],
                                                      userName:
                                                          data['userName'],
                                                      category:
                                                          data['category'],
                                                      totalReviews:
                                                          data['totalReviews']
                                                              .toString(),
                                                      uuid: data['uuid'],
                                                      uid: data['uid'],
                                                      totalRating:
                                                          data['totalRate']
                                                              .toString(),
                                                      title: data['title'],
                                                      price: data['price']
                                                          .toString(),
                                                      perHrPrice:
                                                          data['pricePerHr']
                                                              .toString(),
                                                      photo: data['photo'],
                                                      description:
                                                          data['description'],
                                                    )));
                                      },
                                      leading: CircleAvatar(
                                        backgroundImage:
                                            NetworkImage(data['userImage']),
                                      ),
                                      title: Text(
                                        data['userName'],
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                                  data['totalReviews']
                                                      .toString(),
                                                  style: GoogleFonts.inter(
                                                      fontWeight:
                                                          FontWeight.bold,
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
                    }),
          ),
        ],
      ),
    );
  }
}
