import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:kelimbo/screens/main/chat/messages.dart';
import 'package:kelimbo/utils/colors.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  Widget build(BuildContext context) {
    final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("chats")
            .where("providerId", isEqualTo: currentUserId)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> providerSnapshot) {
          // Check if the providerSnapshot has data and no errors
          if (providerSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (providerSnapshot.hasError) {
            return Center(
              child: Text("Error: ${providerSnapshot.error}"),
            );
          } else if (!providerSnapshot.hasData ||
              providerSnapshot.data == null) {
            return Center(
              child: Text("No data available for providers."),
            );
          }

          var prods = providerSnapshot
              .data!; // This is safe because we've checked for null

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("chats")
                .where("customerId", isEqualTo: currentUserId)
                .snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> customerSnapshot) {
              if (customerSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (customerSnapshot.hasError) {
                return Center(
                  child: Text("Error: ${customerSnapshot.error}"),
                );
              } else if (!customerSnapshot.hasData ||
                  customerSnapshot.data == null) {
                return Center(
                  child: Text("No data available for customers."),
                );
              }

              // Combine the two snapshots
              List<DocumentSnapshot> documents = [];
              if (providerSnapshot.hasData) {
                documents.addAll(providerSnapshot.data!.docs);
              }
              if (customerSnapshot.hasData) {
                documents.addAll(customerSnapshot.data!.docs);
              }

              if (documents.isEmpty) {
                return Center(
                  child: Text(
                    "Todavía no se ha iniciado el chat",
                    style: TextStyle(color: colorBlack),
                  ),
                );
              }

              return ListView.builder(
                itemCount: documents.length,
                itemBuilder: (context, index) {
                  final Map<String, dynamic> data =
                      documents[index].data() as Map<String, dynamic>;

                  final prodData =
                      prods.docs.isNotEmpty && index < prods.docs.length
                          ? prods.docs[index].data() as Map<String, dynamic>
                          : null;

                  return Column(
                    children: [
                      ListTile(
                        onTap: () {
                          if (prodData != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (builder) => Messages(
                                  providerEmail: data['providerEmail'],
                                  providerId: prodData[
                                      'providerId'], // Use prodData safely
                                  providerName: prodData['providerName'],
                                  providerPhoto: prodData['providerPhoto'],
                                  customerPhoto: data['customerPhoto'],
                                  customerEmail: data['customerEmail'],
                                  customerId: data['customerId'],
                                  chatId: data['chatId'],
                                  customerName: data['customerName'],
                                ),
                              ),
                            );
                          }
                        },
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(data['customerPhoto']),
                        ),
                        title: Text(
                          data['customerName'],
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600, fontSize: 16),
                        ),
                        subtitle: Text(
                          data['lastMessageByCustomer'] ?? "No Message",
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w300, fontSize: 14),
                        ),
                      ),
                      Divider(),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
