import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kelimbo/utils/colors.dart';
import 'package:kelimbo/widgets/text_form_field.dart';

class Messages extends StatefulWidget {
  final String providerId;
  final String customerId;
  final String providerName;
  final String providerEmail;
  final String providerPhoto;
  final String customerName;
  final String customerPhoto;
  final String customerEmail;
  final String chatId;
  final String description;

  const Messages({
    super.key,
    required this.providerEmail,
    required this.customerEmail,
    required this.chatId,
    required this.customerName,
    required this.customerPhoto,
    required this.providerId,
    required this.providerName,
    required this.customerId,
    required this.description,
    required this.providerPhoto,
  });

  @override
  State<Messages> createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  ScrollController scrollController = ScrollController();
  TextEditingController messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: GestureDetector(
          onTap: () {},
          child: Row(
            mainAxisSize: MainAxisSize.min, // Prevent extra spacing issues
            children: [
              CircleAvatar(
                radius: 20, // Avatar size
                backgroundImage: NetworkImage(
                  FirebaseAuth.instance.currentUser!.uid == widget.customerId
                      ? widget.providerPhoto
                      : widget.customerPhoto,
                ),
              ),
              Text(
                FirebaseAuth.instance.currentUser!.uid == widget.customerId
                    ? widget.providerName
                    : widget.customerName,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                  fontSize: 16, // Adjust font size
                ),
                textAlign: TextAlign.center, // Center align text
                maxLines: 2, // Ensure text wraps if long
                overflow: TextOverflow.ellipsis, // Prevent overflow issues
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: <Widget>[
          SizedBox(
            height: 60,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  widget.description,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w400,
                    color: colorBlack,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.start,
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("messages")
                  .doc(widget.chatId)
                  .collection("chats")
                  .orderBy("timestamp", descending: false)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  return snapshot.data!.docs.isEmpty
                      ? Center(child: Text("Aún no hay mensajes."))
                      : ListView.builder(
                          controller: scrollController,
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            var ds = snapshot.data!.docs[index];
                            final bool isCurrentUserSender =
                                ds.get("senderId") == currentUserId;
                            return Align(
                              alignment: isCurrentUserSender
                                  ? Alignment.topRight
                                  : Alignment.topLeft,
                              child: Container(
                                padding: EdgeInsets.all(12),
                                margin: EdgeInsets.symmetric(
                                    vertical: 4, horizontal: 10),
                                decoration: BoxDecoration(
                                  color: isCurrentUserSender
                                      ? Colors.blue[100]
                                      : Colors.grey[300],
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(ds.get("content")),
                              ),
                            );
                          },
                        );
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 14),
              height: 60,
              color: Colors.white,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextFormInputField(
                      controller: messageController,
                      hintText: "Send a message",
                      textInputType: TextInputType.name,
                    ),
                  ),
                  SizedBox(width: 10),
                  FloatingActionButton(
                    shape: CircleBorder(),
                    onPressed: () {
                      sendMessage(
                        messageController.text.trim(),
                      );
                    },
                    backgroundColor: mainColor,
                    elevation: 0,
                    child: Icon(Icons.send, color: Colors.white, size: 18),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void sendMessage(String content) {
    if (content.isNotEmpty) {
      messageController.clear();

      FirebaseFirestore.instance
          .collection("messages")
          .doc(widget.chatId)
          .collection("chats")
          .add({
        "senderId": FirebaseAuth.instance.currentUser!.uid,
        "content": content,
        "timestamp": FieldValue.serverTimestamp(),
      });

      updateLastMessage(content);
    }
  }

  void updateLastMessage(String messageContent) async {
    final chatDocRef =
        FirebaseFirestore.instance.collection('chats').doc(widget.chatId);

    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    // Determine the fields to update for both participants
    final String fieldToUpdateForCurrentUser =
        (currentUserId == widget.customerId)
            ? 'lastMessageByCustomer'
            : 'lastMessageByProvider';
    final String fieldToUpdateForOtherUser =
        (currentUserId == widget.customerId)
            ? 'lastMessageByProvider'
            : 'lastMessageByCustomer';

    final chatDocSnapshot = await chatDocRef.get();
    if (chatDocSnapshot.exists) {
      // Update both users' last messages
      await chatDocRef.update({
        'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
        fieldToUpdateForCurrentUser: messageContent,
        fieldToUpdateForOtherUser:
            messageContent, // Update the other user as well
      }).catchError((error) {
        print("Failed to update last message: $error");
      });
    }
  }
}
