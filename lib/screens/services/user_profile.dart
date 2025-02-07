import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kelimbo/screens/main/pages/favourite_page.dart';
import 'package:kelimbo/screens/rating/rating_list_user.dart';
import 'package:kelimbo/screens/services/service_description.dart';
import 'package:kelimbo/utils/colors.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("users")
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .snapshots(),
                builder: (context, AsyncSnapshot snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data == null) {
                    return Center(child: Text('No data available'));
                  }
                  var snap = snapshot.data;

                  return Column(
                    children: [
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child:
                              snap['image'] != null && snap['image'].isNotEmpty
                                  ? CircleAvatar(
                                      backgroundImage: NetworkImage(
                                        snap['image'],
                                      ),
                                      radius: 60,
                                    )
                                  : CircleAvatar(
                                      radius: 60,
                                      child: Icon(Icons.person, size: 60),
                                    ),
                        ),
                      ),
                      Text(
                        snap['fullName'],
                        style: GoogleFonts.workSans(
                            fontWeight: FontWeight.w900, fontSize: 22),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (builder) => UserRatings(
                                        serviceId: FirebaseAuth
                                            .instance.currentUser!.uid,
                                      )));
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.star,
                              color: Colors.yellow,
                            ),
                            Text(
                              snap['totalReviews'].toString(),
                              style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 19,
                                  color: Color(0xff9C9EA2)),
                            )
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Número de trabajos: "),
                          Text(snap['numberofjobs'].toString()),
                        ],
                      ),
                    ],
                  );
                }),
            Container(
              height: 500,
              child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("services")
                      .where("uid",
                          isEqualTo: FirebaseAuth.instance.currentUser!.uid)
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
                                      builder: (builder) => ServiceDescription(
                                            photo: data['photo'],
                                            perpriceHr:
                                                data['pricePerHr'].toString(),
                                            description: data['description'],
                                            price: data['price'].toString(),
                                            title: data['title'],
                                            uuid: data['uuid'],
                                            category: data['category'],
                                          )));
                            },
                            child: Card(
                              child: Column(
                                children: [
                                  ListTile(
                                    leading: data['photo'] == ""
                                        ? CircleAvatar()
                                        : CircleAvatar(
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
                                      data['description'],
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
      ),
    );
  }
}
