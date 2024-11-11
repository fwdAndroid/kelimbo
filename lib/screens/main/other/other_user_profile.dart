import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kelimbo/screens/hiring/hiring_service.dart';
import 'package:kelimbo/utils/colors.dart';

class OtherUserProfile extends StatefulWidget {
  final uid;
  final customerName;
  final customerPhoto;
  final customerEmail;
  final userEmail;
  final userName;
  final userImage;

  const OtherUserProfile(
      {super.key,
      required this.customerEmail,
      required this.customerName,
      required this.customerPhoto,
      required this.userEmail,
      required this.userName,
      required this.userImage,
      required this.uid});

  @override
  State<OtherUserProfile> createState() => _OtherUserProfileState();
}

class _OtherUserProfileState extends State<OtherUserProfile> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(widget.uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(widget.customerPhoto),
                    radius: 60,
                  )),
            ),
            Text(
              widget.customerName,
              style: GoogleFonts.workSans(
                  fontWeight: FontWeight.w900, fontSize: 22),
            ),
            SizedBox(
              height: 600,
              child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("services")
                      .where("uid", isEqualTo: widget.uid)
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
                          return Card(
                            child: Column(
                              children: [
                                ListTile(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (builder) => HiringService(
                                                  currencyType:
                                                      data['currency'],
                                                  serviceId: data['uuid'],
                                                  totalReviews:
                                                      data['totalReviews']
                                                          .toString(),
                                                  userEmail: widget.userEmail,
                                                  userImage: widget.userImage,
                                                  userName: widget.userName,
                                                  uid: FirebaseAuth.instance
                                                      .currentUser!.uid,
                                                  photo: data['photo'],
                                                  perHrPrice: data['pricePerHr']
                                                      .toString(),
                                                  totalRating: data['totalRate']
                                                      .toString(),
                                                  description:
                                                      data['description'],
                                                  price:
                                                      data['price'].toString(),
                                                  title: data['title'],
                                                  uuid: data['uuid'],
                                                  category: data['category'],
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
                                              data['totalRate'].toString(),
                                              style: GoogleFonts.inter(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          data['totalReviews'].toString() +
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
                        });
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
