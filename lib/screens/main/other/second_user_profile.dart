import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kelimbo/screens/hiring/hiring_service.dart';
import 'package:kelimbo/screens/main/pages/favourite_page.dart';
import 'package:kelimbo/screens/rating/rating_list.dart';
import 'package:kelimbo/utils/colors.dart';

class SecondUserProfile extends StatefulWidget {
  String userEmail;
  String userImage;
  String userId;
  String userName;
  String uuid;
  String numberofJobs;
  var totalReviews;
  SecondUserProfile(
      {super.key,
      required this.userEmail,
      required this.userId,
      required this.userImage,
      required this.userName,
      required this.numberofJobs,
      required this.uuid,
      required this.totalReviews});

  @override
  State<SecondUserProfile> createState() => _SecondUserProfileState();
}

class _SecondUserProfileState extends State<SecondUserProfile> {
  final currentUserId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundImage: NetworkImage(widget.userImage),
                radius: 60,
              ),
            ),
          ),
          Text(
            widget.userName,
            style: GoogleFonts.workSans(
              fontWeight: FontWeight.w900,
              fontSize: 22,
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (builder) => RatingList(
                            serviceId: widget.uuid,
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
                  widget.totalReviews.toString(),
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
              Text(widget.numberofJobs.toString()),
            ],
          ),
          StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("services")
                  .where("uid", isEqualTo: widget.userId)
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
                return Expanded(
                    child: ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final data = snapshot.data!.docs[index].data()
                        as Map<String, dynamic>;

                    bool isFavorite = (data['favorite'] as List<dynamic>?)
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
                                      serviceDescription: data['description'],
                                      totalReviews:
                                          data['totalReviews'].toString(),
                                      uuid: data['uuid'],
                                      uid: data['uid'],
                                      totalRating: data['totalRate'].toString(),
                                      title: data['title'],
                                      price: data['price'].toString(),
                                      perHrPrice: data['pricePerHr'].toString(),
                                      photo: data['photo'],
                                      description: data['description'],
                                    )));
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
                                    print("Error updating favorite status: $e");
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
                                              totalReviews: data['totalReviews']
                                                  .toString(),
                                              uuid: data['uuid'],
                                              uid: data['uid'],
                                              totalRating:
                                                  data['totalRate'].toString(),
                                              title: data['title'],
                                              price: data['price'].toString(),
                                              perHrPrice:
                                                  data['pricePerHr'].toString(),
                                              photo: data['photo'],
                                              description: data['description'],
                                            )));
                              },
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
                ));
              }),
        ],
      ),
    );
  }
}
