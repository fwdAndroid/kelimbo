import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kelimbo/screens/main/other/offers_profile.dart';
import 'package:kelimbo/screens/main/pages/favourite_page.dart';
import 'package:kelimbo/screens/rating/rating_list.dart';
import 'package:kelimbo/utils/colors.dart';
import 'package:kelimbo/utils/image_utils.dart';
import 'package:kelimbo/widgets/save_button.dart';

// ignore: must_be_immutable
class SellerReceivedDetail extends StatefulWidget {
  String uuid;
  String description;
  int price;
  var currency;
  String status;
  String clientImage;
  String clientName;
  String clientId;
  String serviceId;
  SellerReceivedDetail(
      {super.key,
      required this.status,
      required this.uuid,
      required this.clientImage,
      required this.clientName,
      required this.clientId,
      required this.serviceId,
      required this.description,
      required this.currency,
      required this.price});

  @override
  State<SellerReceivedDetail> createState() => _SellerReceivedDetailState();
}

class _SellerReceivedDetailState extends State<SellerReceivedDetail> {
  TextEditingController providerPassController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: GestureDetector(
            onTap: () {
              FocusScope.of(context)
                  .unfocus(); // Dismiss keyboard when tapping outside
            },
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (builder) => OffersProfile(
                                    serviceId: widget.serviceId,
                                    serviceProviderId: widget.clientId)));
                      },
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage: NetworkImage(
                          widget.clientImage,
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        widget.clientName,
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                  StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection("users")
                          .where("uid", isEqualTo: widget.clientId)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                            child: Text(""),
                          );
                        }
                        var userData = snapshot.data!.docs.first.data()
                            as Map<String, dynamic>;
                        return Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (builder) => RatingList(
                                              serviceId: widget.serviceId,
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
                                    userData['totalReviews'].toString(),
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
                                Text(userData['numberofjobs'].toString()),
                              ],
                            ),
                          ],
                        );
                      }),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Descripciónes de puestos de trabajo",
                      style: TextStyle(
                          color: colorBlack,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      height: 150,
                      child: Text(
                        widget.description,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Precio: ",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      widget.price.toString() +
                          " " +
                          getCurrencySymbol(widget.currency ?? 'Euro'),
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.only(
                        left: 8.0,
                        right: 8,
                        bottom: 8,
                        top: 8,
                      ),
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(8),
                          fillColor: textColor,
                          filled: true,
                          hintStyle: GoogleFonts.nunitoSans(fontSize: 16),
                          hintText: "Precio",
                        ),
                        controller: providerPassController,
                      )),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      controller: descriptionController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        filled: true,
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(22)),
                            borderSide: BorderSide(
                              color: textColor,
                            )),
                        contentPadding: EdgeInsets.all(8),
                        fillColor: Color(0xffF6F7F9),
                        hintText: "Observaciones",
                        hintStyle: GoogleFonts.nunitoSans(fontSize: 16),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: SaveButton(
                          title: "Enviar Presupuesto ",
                          onTap: () async {
                            FocusScope.of(context)
                                .unfocus(); // Hide keyboard on button
                            if (providerPassController.text.isEmpty) {
                              showMessageBar("Se requiere precio", context);
                            } else {
                              await FirebaseFirestore.instance
                                  .collection("offers")
                                  .doc(widget.uuid)
                                  .update({
                                "status": "counterOffer",
                                "price": int.parse(providerPassController.text),
                                "serviceDescription":
                                    descriptionController.text ??
                                        widget.description
                              });
                              showMessageBar("Presupuesto enviado", context);
                              Navigator.pop(context);
                            }
                            // accept the offer
                          }),
                    ),
                  ),
                ],
              ),
            )));
  }
}
