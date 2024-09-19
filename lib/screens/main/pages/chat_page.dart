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
    return Scaffold(
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("chats")
              .where("providerId",
                  isEqualTo: FirebaseAuth.instance.currentUser!.uid)
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Text(
                  "No Chat Started Yet",
                  style: TextStyle(color: colorBlack),
                ),
              );
            }
            return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (index, contrxt) {
                  final List<DocumentSnapshot> documents = snapshot.data!.docs;
                  final Map<String, dynamic> data =
                      documents[contrxt].data() as Map<String, dynamic>;
                  // DateTime date = (data['chatTime'] as Timestamp).toDate();
                  // String formattedTime = DateFormat.jm().format(date);
                  return Column(
                    children: [
                      ListTile(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (builder) => Messages(
                                        providerEmail: data['providerEmail'],
                                        providerId: data['providerId'],
                                        providerName: data['providerName'],
                                        providerPhoto: data['providerPhoto'],
                                        customerPhoto: data['customerPhoto'],
                                        customerEmail: data['customerEmail'],
                                        customerId: data['customerId'],
                                        chatId: data['chatId'],
                                        customerName: data['customerName'],
                                      )));
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
                          data['lastMessageByCustomer'],
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w300, fontSize: 14),
                        ),
                        // trailing: Text(
                        //   "12:00",
                        //   style: GoogleFonts.poppins(
                        //       fontWeight: FontWeight.w300, fontSize: 14),
                        // ),
                      ),
                      Divider()
                    ],
                  );
                });
          }),
    );
  }
}
