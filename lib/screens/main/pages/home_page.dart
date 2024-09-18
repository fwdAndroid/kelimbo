import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kelimbo/screens/hiring/hiring_service.dart';
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
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(130), // Adjust the height as needed
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor:
              Color(0xFFEFEFFB), // Background color similar to your image
          elevation: 0,
          actions: [],
          flexibleSpace: Padding(
            padding: const EdgeInsets.only(
                top: 30.0), // Add padding to position the search bar
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.tune, color: Colors.black),
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
      body: SingleChildScrollView(
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
                    Image.asset(
                      "assets/home category.png",
                      width: 100,
                      height: 100,
                    ),
                    Image.asset(
                      "assets/health category.png",
                      width: 100,
                      height: 100,
                    ),
                    Image.asset(
                      "assets/turism category.png",
                      width: 100,
                      height: 100,
                    ),
                    Image.asset(
                      "assets/trainning category.png",
                      width: 100,
                      height: 100,
                    ),
                    Image.asset(
                      "assets/pets category.png",
                      width: 100,
                      height: 100,
                    ),
                    Image.asset(
                      "assets/vehicle category.png",
                      width: 100,
                      height: 100,
                    ),
                    Image.asset(
                      "assets/photography category.png",
                      width: 100,
                      height: 100,
                    ),
                    Image.asset(
                      "assets/beauty category.png",
                      width: 100,
                      height: 100,
                    ),
                  ],
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Popular Services",
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
                        .where("uid",
                            isNotEqualTo:
                                FirebaseAuth.instance.currentUser!.uid)
                        .where("favorite", isEqualTo: false)
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
                            "No Service Available",
                            style: TextStyle(color: colorBlack),
                          ),
                        );
                      }
                      return ListView.builder(
                          itemCount: snapshot.data!.docs.length,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (index, contrxt) {
                            final List<DocumentSnapshot> documents =
                                snapshot.data!.docs;
                            final Map<String, dynamic> data = documents[contrxt]
                                .data() as Map<String, dynamic>;
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (builder) => HiringService()));
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
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                child: Image.network(
                                                  fit: BoxFit.cover,
                                                  data['photo'],
                                                  height: 150,
                                                  width: 300,
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Align(
                                                  alignment:
                                                      AlignmentDirectional
                                                          .topEnd,
                                                  child: Container(
                                                    child: Icon(
                                                      Icons.favorite_outline,
                                                      color: red,
                                                    ),
                                                    height: 50,
                                                    width: 50,
                                                    decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: colorWhite),
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
                                                    data['totalRate']
                                                        .toString(),
                                                    style: GoogleFonts.inter(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 13),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Text("€"),
                                                  Text(
                                                    data['price'].toString(),
                                                    style: GoogleFonts.inter(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 13),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  )),
                            );
                          });
                    }),
              ),
            ),
            SizedBox(
              height: 300,
              width: MediaQuery.of(context).size.width,
              child: ListView.builder(itemBuilder: (index, contrxt) {
                return Card(
                  child: Column(
                    children: [
                      ListTile(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (builder) => HiringService()));
                          },
                          leading: CircleAvatar(
                            backgroundImage: AssetImage("assets/logo.png"),
                          ),
                          title: Text(
                            "Marketing digital",
                            style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          subtitle: Text(
                            "Paula Rosseti",
                            style: GoogleFonts.inter(
                                color: Color(0xff9C9EA2),
                                fontWeight: FontWeight.w300,
                                fontSize: 15),
                          ),
                          trailing: Icon(
                            Icons.favorite,
                            color: red,
                          )),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              Text(
                                "€50.0",
                                style: GoogleFonts.inter(
                                    fontWeight: FontWeight.bold, fontSize: 20),
                              ),
                              Text(
                                "Per Hours",
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
                                    "5.0",
                                    style: GoogleFonts.inter(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20),
                                  ),
                                ],
                              ),
                              Text(
                                "85 Reviews",
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
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
