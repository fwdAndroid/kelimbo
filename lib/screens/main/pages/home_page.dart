import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kelimbo/screens/search/filters.dart';
import 'package:kelimbo/screens/search/search_screen.dart';
import 'package:kelimbo/widgets/category_widget.dart';
import 'package:kelimbo/widgets/favourite_widget.dart';
import 'package:kelimbo/widgets/popular_service_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(100), // Adjust the height as needed
          child: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor:
                Color(0xFFEFEFFB), // Background color similar to your image
            elevation: 0,
            flexibleSpace: Padding(
              padding: const EdgeInsets.only(
                  top: 30.0), // Add padding to position the search bar
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (builder) => Filters()));
                    },
                    child: Align(
                      alignment: AlignmentDirectional.topEnd,
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 8.0, right: 20, bottom: 8),
                        child: Image.asset(
                          "assets/filters.png",
                          height: 20,
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      width: MediaQuery.of(context).size.width * 0.9,
                      height: 50,
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (builder) => SearchScreen()));
                              },
                              readOnly: true,
                              decoration: InputDecoration(
                                hintText: '¿Como podemos ayudarte?',
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Color(0xFF3B82F6),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (builder) => SearchScreen()));
                              },
                              icon: Icon(Icons.arrow_forward,
                                  color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CategoryWidget(),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Servicios Populares",
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              PopularServiceWidget(),
              FavouriteWidget()
            ],
          ),
        ));
  }
}
