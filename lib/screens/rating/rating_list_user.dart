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
    // TODO: implement initState
    super.initState();
    print(widget.serviceId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(widget.serviceId) // Replace with your document ID
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text("No se han encontrado reseñas"));
          }

          // Get the `finalreviews` list
          List<dynamic> finalReviews = snapshot.data!.get('finalreviews') ?? [];

          return ListView.builder(
            itemCount: finalReviews.length,
            itemBuilder: (context, index) {
              var review = finalReviews[index];
              return Card(
                child: ListTile(
                  leading: review['clientImage'] != null
                      ? Image.network(
                          review['clientImage'],
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        )
                      : Icon(Icons.person),
                  title: Text(review['clientName'] ?? 'No Name'),
                  subtitle: Text(review['clientThought'] ?? 'No Thoughts'),
                  trailing: Text("Valoración: ${review['totalRate'] ?? 0}"),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
