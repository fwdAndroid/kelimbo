import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kelimbo/screens/categories/bellaza.dart';
import 'package:kelimbo/screens/categories/entermiato.dart';
import 'package:kelimbo/screens/categories/hogar.dart';
import 'package:kelimbo/screens/categories/mascotas.dart';
import 'package:kelimbo/screens/categories/photography.dart';
import 'package:kelimbo/screens/categories/salud.dart';
import 'package:kelimbo/screens/categories/turismo.dart';
import 'package:kelimbo/screens/categories/vehiclescat.dart';
import 'package:kelimbo/screens/hiring/hiring_service.dart';
import 'package:kelimbo/screens/main/other/other_user_profile.dart';
import 'package:kelimbo/screens/search/filters.dart';
import 'package:kelimbo/screens/search/search_screen.dart';
import 'package:kelimbo/utils/colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController serviceNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
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
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (builder) => SearchScreen()));
                            },
                            readOnly: true,
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
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (builder) => SearchScreen()));
                            },
                            icon:
                                Icon(Icons.arrow_forward, color: Colors.white),
                          ),
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
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("users")
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text("");
            }
            if (!snapshot.hasData || snapshot.data == null) {
              return Center(child: Text('No data available'));
            }
            var snap = snapshot.data;
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (builder) => HogarClass()));
                                },
                                child: Image.asset(
                                  "assets/home category.png",
                                  width: 100,
                                  height: 100,
                                ),
                              ),
                              FutureBuilder<String>(
                                future: fetchFirstSubcategory("Hogar"),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Text("Loading...");
                                  } else if (snapshot.hasError ||
                                      !snapshot.hasData) {
                                    return Text("Error!");
                                  } else {
                                    return Text(
                                        snapshot.data ?? "No Subcategories");
                                  }
                                },
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (builder) => Salud()));
                            },
                            child: Column(
                              children: [
                                Image.asset(
                                  "assets/health category.png",
                                  width: 100,
                                  height: 100,
                                ),
                                FutureBuilder<String>(
                                  future: fetchFirstSubcategory("Salud"),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Text("Loading...");
                                    } else if (snapshot.hasError ||
                                        !snapshot.hasData) {
                                      return Text("Error!");
                                    } else {
                                      return Text(
                                          snapshot.data ?? "No Subcategories");
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (builder) => Turismo()));
                            },
                            child: Column(
                              children: [
                                Image.asset(
                                  "assets/turism category.png",
                                  width: 100,
                                  height: 100,
                                ),
                                FutureBuilder<String>(
                                  future: fetchFirstSubcategory("Turismo"),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Text("Loading...");
                                    } else if (snapshot.hasError ||
                                        !snapshot.hasData) {
                                      return Text("Error!");
                                    } else {
                                      return Text(
                                          snapshot.data ?? "No Subcategories");
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (builder) => Entermiato()));
                            },
                            child: Column(
                              children: [
                                Image.asset(
                                  "assets/trainning category.png",
                                  width: 100,
                                  height: 100,
                                ),
                                FutureBuilder<String>(
                                  future:
                                      fetchFirstSubcategory("Entrenamiento"),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Text("Loading...");
                                    } else if (snapshot.hasError ||
                                        !snapshot.hasData) {
                                      return Text("Error!");
                                    } else {
                                      return Text(
                                          snapshot.data ?? "No Subcategories");
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (builder) => Mascotas()));
                            },
                            child: Column(
                              children: [
                                Image.asset(
                                  "assets/pets category.png",
                                  width: 100,
                                  height: 100,
                                ),
                                FutureBuilder<String>(
                                  future: fetchFirstSubcategory("Mascotas"),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Text("Loading...");
                                    } else if (snapshot.hasError ||
                                        !snapshot.hasData) {
                                      return Text("Error!");
                                    } else {
                                      return Text(
                                          snapshot.data ?? "No Subcategories");
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (builder) => Vehiclescat()));
                            },
                            child: Column(
                              children: [
                                Image.asset(
                                  "assets/vehicle category.png",
                                  width: 100,
                                  height: 100,
                                ),
                                FutureBuilder<String>(
                                  future: fetchFirstSubcategory("Vehículos"),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Text("Loading...");
                                    } else if (snapshot.hasError ||
                                        !snapshot.hasData) {
                                      return Text("Error!");
                                    } else {
                                      return Text(
                                          snapshot.data ?? "No Subcategories");
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (builder) => Photography()));
                            },
                            child: Column(
                              children: [
                                Image.asset(
                                  "assets/photography category.png",
                                  width: 100,
                                  height: 100,
                                ),
                                FutureBuilder<String>(
                                  future: fetchFirstSubcategory(
                                      "Fotografía y video"),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Text("Loading...");
                                    } else if (snapshot.hasError ||
                                        !snapshot.hasData) {
                                      return Text("Error!");
                                    } else {
                                      return Text(
                                          snapshot.data ?? "No Subcategories");
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (builder) => Bellaza()));
                            },
                            child: Column(
                              children: [
                                Image.asset(
                                  "assets/beauty category.png",
                                  width: 100,
                                  height: 100,
                                ),
                                FutureBuilder<String>(
                                  future: fetchFirstSubcategory("Belleza"),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Text("Loading...");
                                    } else if (snapshot.hasError ||
                                        !snapshot.hasData) {
                                      return Text("Error!");
                                    } else {
                                      return Text(
                                          snapshot.data ?? "No Subcategories");
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
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
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      height: 250,
                      width: MediaQuery.of(context).size.width,
                      child: StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection("services")
                            .where("uid", isNotEqualTo: currentUserId)
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

                          return ListView.builder(
                            itemCount: snapshot.data!.docs.length,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) {
                              final data = snapshot.data!.docs[index].data()
                                  as Map<String, dynamic>;

                              bool isFavorite =
                                  (data['favorite'] as List<dynamic>?)
                                          ?.contains(currentUserId) ??
                                      false;

                              return GestureDetector(
                                onTap: () {
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
                                child: SizedBox(
                                  height: 300,
                                  width: 300,
                                  child: Card(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Stack(
                                            children: [
                                              data['photo'] == ""
                                                  ? Container()
                                                  : ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                      child: Image.network(
                                                        fit: BoxFit.cover,
                                                        data['photo'],
                                                        height: 150,
                                                        width: 300,
                                                      ),
                                                    ),
                                              GestureDetector(
                                                onTap: () async {
                                                  final docRef =
                                                      FirebaseFirestore.instance
                                                          .collection(
                                                              "services")
                                                          .doc(data['uuid']);
                                                  if (isFavorite) {
                                                    // Remove from favorites
                                                    await docRef.update({
                                                      "favorite": FieldValue
                                                          .arrayRemove(
                                                              [currentUserId])
                                                    });
                                                  } else {
                                                    // Add to favorites
                                                    await docRef.update({
                                                      "favorite":
                                                          FieldValue.arrayUnion(
                                                              [currentUserId])
                                                    });
                                                  }
                                                },
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Align(
                                                    alignment:
                                                        AlignmentDirectional
                                                            .topEnd,
                                                    child: Container(
                                                      child: Icon(
                                                        isFavorite
                                                            ? Icons.favorite
                                                            : Icons
                                                                .favorite_outline,
                                                        color: red,
                                                      ),
                                                      height: 50,
                                                      width: 50,
                                                      decoration: BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          color: colorWhite),
                                                    ),
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            data['title'],
                                            style: GoogleFonts.inter(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(3.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
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
                                                        fontSize: 13),
                                                  ),
                                                ],
                                              ),
                                              Text(
                                                "${getCurrencySymbol(data['currency'] ?? 'Euro')}${data['price'] ?? '0.0'}",
                                                style: GoogleFonts.inter(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 400,
                    width: MediaQuery.of(context).size.width,
                    child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection("services")
                          .where("favorite", arrayContains: currentUserId)
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
                              "No hay favoritos disponibles",
                              style: TextStyle(color: colorBlack),
                            ),
                          );
                        }

                        return ListView.builder(
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            final List<DocumentSnapshot> documents =
                                snapshot.data!.docs;
                            final Map<String, dynamic> data =
                                documents[index].data() as Map<String, dynamic>;

                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => HiringService(
                                            userEmail: data['userEmail'],
                                            userImage: data['userImage'],
                                            userName: data['userName'],
                                            category: data['category'],
                                            totalReviews:
                                                data['totalReviews'].toString(),
                                            uuid: data['uuid'],
                                            uid: data['uid'],
                                            currencyType: data['currency'],
                                            totalRating:
                                                data['totalRate'].toString(),
                                            title: data['title'],
                                            price: data['price'].toString(),
                                            serviceId: data['uuid'],
                                            perHrPrice:
                                                data['pricePerHr'].toString(),
                                            photo: data['photo'],
                                            description: data['description'],
                                          )),
                                );
                              },
                              child: Card(
                                child: StreamBuilder(
                                    stream: FirebaseFirestore.instance
                                        .collection("users")
                                        .doc(FirebaseAuth
                                            .instance.currentUser!.uid)
                                        .snapshots(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return Text("");
                                      }
                                      if (!snapshot.hasData ||
                                          snapshot.data == null) {
                                        return Center(
                                            child: Text('No data available'));
                                      }
                                      var snap = snapshot.data;
                                      return GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (builder) =>
                                                      OtherUserProfile(
                                                          customerEmail:
                                                              data['userEmail'],
                                                          customerName:
                                                              data['userName'],
                                                          customerPhoto:
                                                              data['userImage'],
                                                          userEmail:
                                                              snap?['email'],
                                                          userName:
                                                              snap?['fullName'],
                                                          userImage:
                                                              snap?['image'],
                                                          uid: data['uid'])));
                                        },
                                        child: Column(
                                          children: [
                                            ListTile(
                                              leading: GestureDetector(
                                                child: CircleAvatar(
                                                  backgroundImage: NetworkImage(
                                                      data['photo'] ??
                                                          "assets/logo.png"),
                                                ),
                                              ),
                                              title: Text(
                                                data['title'] ?? "No Title",
                                                style: GoogleFonts.inter(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16),
                                              ),
                                              subtitle: Text(
                                                data['category'] ??
                                                    "No Subtitle",
                                                style: GoogleFonts.inter(
                                                    color: Color(0xff9C9EA2),
                                                    fontWeight: FontWeight.w300,
                                                    fontSize: 15),
                                              ),
                                              trailing: GestureDetector(
                                                onTap: () async {
                                                  final docRef =
                                                      FirebaseFirestore.instance
                                                          .collection(
                                                              "services")
                                                          .doc(data['uuid']);
                                                  await docRef.update({
                                                    "favorite":
                                                        FieldValue.arrayRemove(
                                                            [currentUserId])
                                                  });
                                                },
                                                child: Icon(
                                                  Icons.favorite,
                                                  color: red,
                                                ),
                                              ),
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Column(
                                                  children: [
                                                    Text(
                                                      "${getCurrencySymbol(data['currency'] ?? 'Euro')}${data['price'] ?? '0.0'}",
                                                      style: GoogleFonts.inter(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 20,
                                                      ),
                                                    ),
                                                    Text(
                                                      "Price",
                                                      style: GoogleFonts.inter(
                                                          color:
                                                              Color(0xff9C9EA2),
                                                          fontWeight:
                                                              FontWeight.bold,
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
                                                          style:
                                                              GoogleFonts.inter(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 20),
                                                        ),
                                                      ],
                                                    ),
                                                    Text(
                                                      "${data['ratingCount'] ?? '0'} Reviews",
                                                      style: GoogleFonts.inter(
                                                          color:
                                                              Color(0xff9C9EA2),
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 19),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      );
                                    }),
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
          }),
    );
  }

  Future<String> fetchFirstSubcategory(String category) async {
    try {
      // Query Firestore for documents where 'category' matches
      final querySnapshot = await FirebaseFirestore.instance
          .collection('categories')
          .where('category', isEqualTo: category)
          .get();

      // Check if documents exist
      if (querySnapshot.docs.isNotEmpty) {
        final data =
            querySnapshot.docs.first.data(); // Get the first document data
        if (data.containsKey('subcategories') &&
            data['subcategories'] is List) {
          // Extract the subcategories as a List<String>
          final List<String> subcategories =
              List<String>.from(data['subcategories']);
          return subcategories.isNotEmpty
              ? subcategories.first
              : "No Subcategories"; // Return the first subcategory
        }
      }
      return "No Subcategories Found"; // Fallback if no subcategories exist
    } catch (e) {
      print("Error fetching subcategories: $e");
      return "Error";
    }
  }
}

String getCurrencySymbol(String currency) {
  switch (currency) {
    case 'Euro':
      return '€';
    case 'USD':
      return '\$';
    case 'BTC':
      return '₿';
    case 'ETH':
      return 'Ξ';
    case 'G1': // Add custom icons or symbols as needed
      return 'G1';
    default:
      return ''; // Default to no symbol if currency is unrecognized
  }
}
