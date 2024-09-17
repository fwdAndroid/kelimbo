import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marketplace/screens/hiring/hiring_service.dart';
import 'package:marketplace/utils/colors.dart';

class FavouritePage extends StatefulWidget {
  const FavouritePage({super.key});

  @override
  State<FavouritePage> createState() => _FavouritePageState();
}

class _FavouritePageState extends State<FavouritePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(itemBuilder: (index, contrxt) {
        return GestureDetector(
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (builder) => HiringService()));
          },
          child: Card(
            child: Column(
              children: [
                ListTile(
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
                                  fontWeight: FontWeight.bold, fontSize: 20),
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
          ),
        );
      }),
    );
  }
}
