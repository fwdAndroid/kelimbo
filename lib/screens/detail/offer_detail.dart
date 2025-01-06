import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kelimbo/screens/main/main_dashboard.dart';
import 'package:kelimbo/utils/image_utils.dart';
import 'package:kelimbo/widgets/save_button.dart';
import 'package:uuid/uuid.dart';

class OfferDetail extends StatefulWidget {
  final providerEmail,
      providerImage,
      providerName,
      serviceDescription,
      serviceProviderId,
      serviceTitle,
      status,
      uuid,
      work;
  final price;
  final priceprehr;
  final totalRating;
  final clientEmail, clientId, clientImage, clientName;

  OfferDetail(
      {super.key,
      required this.price,
      required this.priceprehr,
      required this.providerEmail,
      required this.clientName,
      required this.providerImage,
      required this.providerName,
      required this.serviceDescription,
      required this.serviceProviderId,
      required this.serviceTitle,
      required this.clientEmail,
      required this.clientId,
      required this.clientImage,
      required this.status,
      required this.totalRating,
      required this.uuid,
      required this.work});

  @override
  State<OfferDetail> createState() => _OfferDetailState();
}

class _OfferDetailState extends State<OfferDetail> {
  TextEditingController customerPassController = TextEditingController();
  var chatId = Uuid().v4();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.providerName,
          style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text(
                  "Precio: ",
                  style: GoogleFonts.inter(
                      fontSize: 20, fontWeight: FontWeight.w700),
                ),
                Text(
                  widget.price.toString() + "€",
                  style: GoogleFonts.inter(
                      fontSize: 20, fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(widget.clientImage),
            ),
            title: Text(
              widget.clientName,
              style:
                  GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            subtitle: Text(
              widget.serviceTitle,
              style:
                  GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w400),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Detalles",
              style:
                  GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8),
            child: SizedBox(
              width: 389,
              height: 200,
              child: Text(
                widget.work,
                style: GoogleFonts.inter(
                    fontSize: 18, fontWeight: FontWeight.w400),
              ),
            ),
          ),
          Spacer(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: SaveButton(
                  title: "Presupuestos",
                  onTap: () async {
                    await FirebaseFirestore.instance
                        .collection("offers")
                        .doc(widget.uuid)
                        .update({"status": "start"});
                    showMessageBar("Se acepta la oferta", context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (builder) => MainDashboard()));
                  }),
            ),
          ),
        ],
      ),
    );
  }
}
