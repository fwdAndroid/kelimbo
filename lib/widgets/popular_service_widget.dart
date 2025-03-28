import 'dart:io';
import 'dart:ui';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kelimbo/screens/hiring/hiring_service.dart';
import 'package:kelimbo/utils/colors.dart';
import 'package:kelimbo/widgets/currecysymbal.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cross_file/cross_file.dart';

class PopularServiceWidget extends StatelessWidget {
  const PopularServiceWidget({super.key});

  Future<XFile?> _imageToXFile(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/share_image.png');
      await file.writeAsBytes(response.bodyBytes);
      return XFile(file.path);
    } catch (e) {
      debugPrint('Error converting image: $e');
      return null;
    }
  }

  Future<XFile?> _captureWidget(GlobalKey key) async {
    try {
      final boundary =
          key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final image = await boundary.toImage();
      final byteData = await image.toByteData(format: ImageByteFormat.png);
      if (byteData == null) return null;

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/share_card.png');
      await file.writeAsBytes(byteData.buffer.asUint8List());

      return XFile(file.path);
    } catch (e) {
      debugPrint('Error capturing widget: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return Padding(
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
                child: Column(
                  children: [
                    Image.asset(
                      "assets/op.png",
                      height: 200,
                      width: 200,
                    ),
                    Text(
                      "No hay servicio disponible",
                      style: TextStyle(color: colorBlack),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                final data =
                    snapshot.data!.docs[index].data() as Map<String, dynamic>;

                bool isFavorite = (data['favorite'] as List<dynamic>?)
                        ?.contains(currentUserId) ??
                    false;

                final cardKey = GlobalKey();

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
                                  totalReviews: data['totalReviews'].toString(),
                                  uuid: data['uuid'],
                                  uid: data['uid'],
                                  totalRating: data['totalRate'].toString(),
                                  title: data['title'],
                                  price: data['price'].toString(),
                                  perHrPrice: data['pricePerHr'].toString(),
                                  photo: data['photo'],
                                  description: data['description'],
                                  serviceDescription: data['description'],
                                )));
                  },
                  child: SizedBox(
                    height: 300,
                    width: 300,
                    child: RepaintBoundary(
                      key: cardKey,
                      child: Card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Stack(
                                children: [
                                  data['photo'] == ""
                                      ? Image.asset(
                                          fit: BoxFit.cover,
                                          "assets/logo.png",
                                          height: 150,
                                          width: 300,
                                        )
                                      : ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          child: Image.network(
                                            fit: BoxFit.cover,
                                            data['photo'],
                                            height: 150,
                                            width: 300,
                                          ),
                                        ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      GestureDetector(
                                        onTap: () async {
                                          try {
                                            String shareText = """
🔹 *${data['title']}*
📌 *Category:* ${data['category']}
⭐ *Rating:* ${data['totalReviews'].toString()} reviews
💰 *Price:* ${getCurrencySymbol(data['currency'] ?? 'Euro')}${data['price'] ?? '0.0'}
📝 *Description:* ${data['description']}

Check out this service now!
""";

                                            // Try to capture the card as an image first
                                            final cardImage =
                                                await _captureWidget(cardKey);
                                            if (cardImage != null) {
                                              await Share.shareXFiles(
                                                [cardImage],
                                                text: shareText,
                                                subject: data['title'],
                                              );
                                            } else {
                                              // Fallback to sharing the service image if available
                                              if (data['photo'] != null &&
                                                  data['photo'] != "") {
                                                final serviceImage =
                                                    await _imageToXFile(
                                                        data['photo']);
                                                if (serviceImage != null) {
                                                  await Share.shareXFiles(
                                                    [serviceImage],
                                                    text: shareText,
                                                    subject: data['title'],
                                                  );
                                                } else {
                                                  // Final fallback to text only
                                                  await Share.share(shareText);
                                                }
                                              } else {
                                                await Share.share(shareText);
                                              }
                                            }
                                          } catch (e) {
                                            debugPrint('Error sharing: $e');
                                            // Ultimate fallback
                                            await Share.share(
                                                "Check out this service: ${data['title']}");
                                          }
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Align(
                                            alignment:
                                                AlignmentDirectional.topEnd,
                                            child: Container(
                                              child: Icon(Icons.share,
                                                  color: mainColor),
                                              height: 50,
                                              width: 50,
                                              decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: colorWhite),
                                            ),
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () async {
                                          final docRef = FirebaseFirestore
                                              .instance
                                              .collection("services")
                                              .doc(data['uuid']);
                                          if (isFavorite) {
                                            // Remove from favorites
                                            await docRef.update({
                                              "favorite":
                                                  FieldValue.arrayRemove(
                                                      [currentUserId])
                                            });
                                          } else {
                                            // Add to favorites
                                            await docRef.update({
                                              "favorite": FieldValue.arrayUnion(
                                                  [currentUserId])
                                            });
                                          }
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Align(
                                            alignment:
                                                AlignmentDirectional.topEnd,
                                            child: Container(
                                              child: Icon(
                                                isFavorite
                                                    ? Icons.favorite
                                                    : Icons.favorite_outline,
                                                color: red,
                                              ),
                                              height: 50,
                                              width: 50,
                                              decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: colorWhite),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
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
                                        data['totalReviews'].toString(),
                                        style: GoogleFonts.inter(
                                            fontWeight: FontWeight.bold,
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
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
