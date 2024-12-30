import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kelimbo/screens/hiring/hiring_service.dart';

class LocationFilter extends StatefulWidget {
  const LocationFilter({Key? key}) : super(key: key);

  @override
  State<LocationFilter> createState() => _LocationFilterState();
}

class _LocationFilterState extends State<LocationFilter> {
  TextEditingController controller = TextEditingController();
  final currentUserId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Filter by Location"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: "Enter location",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {}); // Trigger rebuild to filter results
            },
            child: const Text("Filter"),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getFilteredQuery(controller.text),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "No results found for the entered location.",
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final DocumentSnapshot document =
                        snapshot.data!.docs[index];
                    final data = document.data() as Map<String, dynamic>;
                    final List<dynamic> favorites = data['favorite'] ?? [];

                    bool isFavorite = favorites.contains(currentUserId);

                    return GestureDetector(
                      onTap: () {
                        // Handle navigation or actions on item tap
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (builder) => HiringService(
                              serviceId: data['uuid'],
                              currencyType: data['currency'],
                              price: data['price'].toString(),
                              userEmail: data['userEmail'],
                              userImage: data['userImage'],
                              userName: data['userName'],
                              category: data['category'],
                              totalReviews: data['totalReviews'].toString(),
                              uuid: data['uuid'],
                              uid: data['uid'],
                              totalRating: data['totalRate'].toString(),
                              title: data['title'],
                              perHrPrice: data['pricePerHr'].toString(),
                              photo: data['photo'],
                              description: data['description'],
                            ),
                          ),
                        );
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
                                  if (isFavorite) {
                                    await FirebaseFirestore.instance
                                        .collection('services')
                                        .doc(document.id)
                                        .update({
                                      'favorite': FieldValue.arrayRemove(
                                          [currentUserId])
                                    });
                                  } else {
                                    await FirebaseFirestore.instance
                                        .collection('services')
                                        .doc(document.id)
                                        .update({
                                      'favorite':
                                          FieldValue.arrayUnion([currentUserId])
                                    });
                                  }
                                },
                              ),
                              leading: CircleAvatar(
                                backgroundImage:
                                    NetworkImage(data['photo'] ?? ""),
                              ),
                              title: Text(
                                data['category'] ?? "No category",
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Text(
                                data['location'] ?? "No location",
                                style: GoogleFonts.inter(
                                  color: const Color(0xff9C9EA2),
                                  fontWeight: FontWeight.w300,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      "€${data['price'].toString()}",
                                      style: GoogleFonts.inter(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20),
                                    ),
                                    Text(
                                      data['priceType'] ?? "No price type",
                                      style: GoogleFonts.inter(
                                          color: const Color(0xff9C9EA2),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 19),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 16),
                                Column(
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.star,
                                            color: Colors.yellow),
                                        Text(
                                          data['ratingCount']?.toString() ??
                                              "0",
                                          style: GoogleFonts.inter(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      "${data['totalReviews']?.toString() ?? "0"} Reviews",
                                      style: GoogleFonts.inter(
                                          color: const Color(0xff9C9EA2),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 19),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Stream<QuerySnapshot> _getFilteredQuery(String location) {
    final servicesCollection =
        FirebaseFirestore.instance.collection("services");

    if (location.trim().isEmpty) {
      // If no location is entered, return all results
      return servicesCollection.snapshots();
    }

    // Filter based on location
    return servicesCollection
        .where('location', isEqualTo: location.trim())
        .snapshots();
  }
}
