import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserRatings extends StatefulWidget {
  final serviceId;
  const UserRatings({super.key, required this.serviceId});

  @override
  State<UserRatings> createState() => _UserRatingsState();
}

class _UserRatingsState extends State<UserRatings> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reseñas de Usuario'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(widget.serviceId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text("No se han encontrado reseñas"));
          }

          List<dynamic> finalReviews = snapshot.data!.get('finalreviews') ?? [];

          if (finalReviews.isEmpty) {
            return Center(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.star,
                    color: Colors.yellow,
                    size: 40,
                  ),
                ),
                Text("No hay reseñas disponibles"),
              ],
            ));
          }

          return ListView.builder(
            itemCount: finalReviews.length,
            itemBuilder: (context, index) {
              var review = finalReviews[index];
              bool hasRating =
                  review['totalRate'] != null && review['totalRate'] != 0;

              return Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  contentPadding: EdgeInsets.all(12),
                  leading: review['clientImage'] != null
                      ? CircleAvatar(
                          radius: 25,
                          backgroundImage: NetworkImage(review['clientImage']),
                        )
                      : CircleAvatar(
                          radius: 25,
                          child: Icon(Icons.person),
                        ),
                  title: Text(
                    review['clientName'] ?? 'Anónimo',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 4),
                      Text(
                        review['clientThought'] ?? 'Sin comentarios',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  trailing: hasRating
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.star, color: Colors.amber),
                            Text(
                              "${review['totalRate']}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star_border, color: Colors.grey),
                            SizedBox(width: 4),
                            Text(
                              "Sin valorar",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
