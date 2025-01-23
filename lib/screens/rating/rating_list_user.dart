import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RatingListUser extends StatefulWidget {
  const RatingListUser({super.key});

  @override
  State<RatingListUser> createState() => _RatingListUserState();
}

class _RatingListUserState extends State<RatingListUser> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Reviews"),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text("No reviews found"));
          }

          List<dynamic> finalReviews = [];

          // Loop through documents and filter reviews
          for (var doc in snapshot.data!.docs) {
            var reviews = doc['reviews'] ?? []; // Get the review array
            if (reviews is List) {
              for (var review in reviews) {
                if (review['providerId'] ==
                    FirebaseAuth.instance.currentUser!.uid) {
                  finalReviews.add(review);
                }
              }
            }
          }

          if (finalReviews.isEmpty) {
            return Center(child: Text("No reviews found"));
          }

          return ListView.builder(
            itemCount: finalReviews.length,
            itemBuilder: (context, index) {
              var review = finalReviews[index];
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
                  title: Text(review['clientName'] ?? 'No Name'),
                  subtitle: Text(review['clientThought'] ?? 'No Thoughts'),
                  trailing: Text("Rating: ${review['totalRate'] ?? 0}"),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
