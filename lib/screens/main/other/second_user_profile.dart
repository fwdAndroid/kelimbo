import 'package:cloud_firestore/cloud_firestore.dart';
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
  var totalReviews;
  SecondUserProfile(
      {super.key,
      required this.userEmail,
      required this.userId,
      required this.userImage,
      required this.userName,
      required this.uuid,
      required this.totalReviews});

  @override
  State<SecondUserProfile> createState() => _SecondUserProfileState();
}

class _SecondUserProfileState extends State<SecondUserProfile> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(widget.userId);
  }

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
                        final List<DocumentSnapshot> documents =
                            snapshot.data!.docs;
                        final Map<String, dynamic> data =
                            documents[index].data() as Map<String, dynamic>;
                        return Card(
                          child: Column(
                            children: [
                              ListTile(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (builder) => HiringService(
                                                userEmail: data['userEmail'],
                                                userImage: data['userImage'],
                                                userName: data['userName'],
                                                category: data['category'],
                                                totalReviews:
                                                    data['totalReviews']
                                                        .toString(),
                                                uuid: data['uuid'],
                                                uid: data['uid'],
                                                currencyType: data['currency'],
                                                totalRating: data['totalRate']
                                                    .toString(),
                                                title: data['title'],
                                                price: data['price'].toString(),
                                                serviceId: data['uuid'],
                                                perHrPrice: data['pricePerHr']
                                                    .toString(),
                                                photo: data['photo'],
                                                description:
                                                    data['description'],
                                              )));
                                },
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
                                subtitle: SizedBox(
                                  width: 200,
                                  height: 150,
                                  child: Text(
                                    data['description'],
                                    style: GoogleFonts.inter(
                                        color: Color(0xff9C9EA2),
                                        fontWeight: FontWeight.w300,
                                        fontSize: 15),
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
                        );
                      }),
                );
              }),
        ],
      ),
    );
  }
}
