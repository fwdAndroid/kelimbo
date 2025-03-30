import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RatingList extends StatefulWidget {
  final serviceId;
  const RatingList({super.key, required this.serviceId});

  @override
  State<RatingList> createState() => _RatingListState();
}

class _RatingListState extends State<RatingList> {
  @override
  void initState() {
    super.initState();
    print(widget.serviceId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('services')
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
              bool hasRating = review['totalRate'] != null;

              return Card(
                child: ListTile(
                  leading: review['userImage'] != null
                      ? Image.network(
                          review['userImage'],
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        )
                      : Icon(Icons.person),
                  title: Text(review['clientName'] ?? 'Nombre no disponible'),
                  subtitle: Text(review['clientThought'] ?? 'Sin comentarios'),
                  trailing: hasRating
                      ? Text("Valoración: ${review['totalRate']}")
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star_border, color: Colors.grey),
                            SizedBox(width: 4),
                            Text("Sin valoración aún",
                                style: TextStyle(color: Colors.grey)),
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
