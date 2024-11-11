import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kelimbo/widgets/save_button.dart';

class JobsCompletedDetail extends StatefulWidget {
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
  const JobsCompletedDetail(
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
  State<JobsCompletedDetail> createState() => _JobsCompletedDetailState();
}

class _JobsCompletedDetailState extends State<JobsCompletedDetail> {
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
            subtitle: Row(
              children: [
                Text(
                  widget.serviceTitle,
                  style: GoogleFonts.inter(
                      fontSize: 18, fontWeight: FontWeight.w400),
                ),
              ],
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
              child: SaveButton(title: "Tasa", onTap: () async {}),
            ),
          )
        ],
      ),
    );
  }
}
