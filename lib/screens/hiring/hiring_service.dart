import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kelimbo/screens/hiring/hiring_service_comment.dart';
import 'package:kelimbo/widgets/save_button.dart';

class HiringService extends StatefulWidget {
  final title;
  final description;
  final price;
  final perHrPrice;
  final totalReviews;
  final totalRating;
  final photo;
  final uuid;
  final category;
  final uid;
  const HiringService(
      {super.key,
      required this.description,
      required this.perHrPrice,
      required this.price,
      required this.title,
      required this.category,
      required this.photo,
      required this.totalRating,
      required this.uid,
      required this.uuid,
      required this.totalReviews});

  @override
  State<HiringService> createState() => _HiringServiceState();
}

class _HiringServiceState extends State<HiringService> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.photo),
              radius: 50,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                widget.title,
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold, fontSize: 28),
                textAlign: TextAlign.center,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.star,
                  color: Colors.yellow,
                ),
                Text(
                  widget.totalRating.toString(),
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: 19,
                      color: Color(0xff9C9EA2)),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                widget.category,
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
            Center(
              child: SizedBox(
                height: 150,
                width: 390,
                child: Text(
                  widget.description,
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w500, fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.network(
                widget.photo,
                height: 254,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SaveButton(
                  title: "Solicitar presupuesto",
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (builder) => HiringServiceComments()));
                  }),
            )
          ],
        ),
      ),
    );
  }
}
