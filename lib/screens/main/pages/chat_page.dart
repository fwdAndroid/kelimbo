import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kelimbo/screens/main/chat/messages.dart';
import 'package:kelimbo/utils/colors.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          "Chats",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: colorBlack,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: colorBlack),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("chats")
            .where("providerId", isEqualTo: currentUserId)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> providerSnapshot) {
          if (providerSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (providerSnapshot.hasError) {
            return Center(child: Text("Error: ${providerSnapshot.error}"));
          }

          final providerChats = providerSnapshot.data?.docs ?? [];

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("chats")
                .where("customerId", isEqualTo: currentUserId)
                .snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> customerSnapshot) {
              if (customerSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (customerSnapshot.hasError) {
                return Center(
                  child: Text("Error: ${customerSnapshot.error}"),
                );
              }

              final customerChats = customerSnapshot.data?.docs ?? [];
              final allChats = [...providerChats, ...customerChats];

              if (allChats.isEmpty) {
                return Center(
                  child: Text(
                    "No chats started yet.",
                    style: TextStyle(color: colorBlack),
                  ),
                );
              }

              return ListView.builder(
                itemCount: allChats.length,
                itemBuilder: (context, index) {
                  final chatDoc = allChats[index];
                  final chatData = chatDoc.data() as Map<String, dynamic>;

                  // Determine other participant details
                  final bool isProvider =
                      chatData['providerId'] == currentUserId;
                  final String otherUserId = isProvider
                      ? chatData['customerId']
                      : chatData['providerId'];
                  final String otherUserName = isProvider
                      ? chatData['customerName']
                      : chatData['providerName'];
                  final String otherUserPhoto = isProvider
                      ? chatData['customerPhoto']
                      : chatData['providerPhoto'];
                  final String lastMessage =
                      chatData['lastMessageByCustomer'] ??
                          chatData['lastMessageByProvider'] ??
                          "No Message";

                  return Column(
                    children: [
                      ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (builder) => Messages(
                                providerEmail:
                                    chatData['providerEmail'] ?? "No Email",
                                providerId: chatData['providerId'],
                                providerName: chatData['providerName'],
                                providerPhoto: chatData['providerPhoto'],
                                customerPhoto: chatData['customerPhoto'],
                                customerEmail:
                                    chatData['customerEmail'] ?? "No Email",
                                customerId: chatData['customerId'],
                                chatId: chatData['chatId'],
                                customerName: chatData['customerName'],
                              ),
                            ),
                          );
                        },
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(otherUserPhoto),
                        ),
                        title: Text(
                          otherUserName,
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600, fontSize: 16),
                        ),
                        subtitle: Text(
                          lastMessage,
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w300, fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Divider(),
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
