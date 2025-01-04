import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kelimbo/screens/main/other/other_user_profile_chat.dart';
import 'package:kelimbo/utils/colors.dart';
import 'package:kelimbo/widgets/text_form_field.dart';
import 'package:intl/intl.dart';

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
    required this.providerPhoto,
  });

  @override
  State<Messages> createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  late String groupChatId;
  ScrollController scrollController = ScrollController();
  TextEditingController messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    print(widget.customerEmail);
    print(widget.providerEmail);
    groupChatId = widget.customerId.hashCode <= widget.providerId.hashCode
        ? "${widget.customerId}-${widget.providerId}"
        : "${widget.providerId}-${widget.customerId}";
  }

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
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (builder) => OtherUserProfileChat(
                  userImage: FirebaseAuth.instance.currentUser!.uid ==
                          widget.customerId
                      ? widget.providerPhoto
                      : widget.customerPhoto,
                  userName: FirebaseAuth.instance.currentUser!.uid ==
                          widget.customerId
                      ? widget.providerName
                      : widget.customerName,
                  userEmail: FirebaseAuth.instance.currentUser!.uid ==
                          widget.customerId
                      ? widget.providerEmail
                      : widget.customerEmail,
                  customerEmail: widget.customerEmail,
                  customerName: widget.customerName,
                  customerPhoto: widget.customerPhoto,
                  uid: FirebaseAuth.instance.currentUser!.uid ==
                          widget.customerId
                      ? widget.providerId
                      : widget.customerId,
                ),
              ),
            );
          },
          child: Column(
            children: [
              const SizedBox(
                height: 3,
              ),
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(
                  FirebaseAuth.instance.currentUser!.uid == widget.customerId
                      ? widget.providerPhoto
                      : widget.customerPhoto,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                FirebaseAuth.instance.currentUser!.uid == widget.customerId
                    ? widget.providerName
                    : widget.customerName,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w500,
                  color: colorBlack,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: <Widget>[
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("messages")
                .doc(groupChatId)
                .collection(groupChatId)
                .orderBy("timestamp", descending: false)
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasData) {
                return snapshot.data!.docs.isEmpty
                    ? Expanded(
                        child: Center(child: Text("No messages yet.")),
                      )
                    : Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 14),
                          reverse: false,
                          controller: scrollController,
                          shrinkWrap: true,
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            var ds = snapshot.data!.docs[index];
                            final bool isCurrentUserSender =
                                ds.get("senderId") == currentUserId;

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Align(
                                alignment: isCurrentUserSender
                                    ? Alignment.topRight
                                    : Alignment.topLeft,
                                child: Column(
                                  crossAxisAlignment: isCurrentUserSender
                                      ? CrossAxisAlignment.end
                                      : CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        color: isCurrentUserSender
                                            ? Color(0xfff0f2f9)
                                            : Color(0xff668681),
                                      ),
                                      padding: EdgeInsets.all(12),
                                      child: Text(
                                        ds.get("content"),
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: isCurrentUserSender
                                              ? colorBlack
                                              : colorWhite,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      DateFormat.jm().format(
                                        DateTime.fromMillisecondsSinceEpoch(
                                          int.parse(ds.get("time")),
                                        ),
                                      ),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      );
              } else if (snapshot.hasError) {
                return Center(child: Icon(Icons.error_outline));
              } else {
                return Center(child: CircularProgressIndicator());
              }
            },
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
                      sendMessage(messageController.text.trim(), 0);
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

  void sendMessage(String content, int type) {
    if (content.trim().isNotEmpty) {
      messageController.clear();

      final currentUserId = FirebaseAuth.instance.currentUser!.uid;
      final String senderId = currentUserId;
      final String receiverId = (currentUserId == widget.customerId)
          ? widget.providerId
          : widget.customerId;

      var documentReference = FirebaseFirestore.instance
          .collection('messages')
          .doc(groupChatId)
          .collection(groupChatId)
          .doc(DateTime.now().millisecondsSinceEpoch.toString());

      FirebaseFirestore.instance.runTransaction((transaction) async {
        await transaction.set(
          documentReference,
          {
            "senderId": senderId,
            "receiverId": receiverId,
            "time": DateTime.now().millisecondsSinceEpoch.toString(),
            'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
            'content': content,
            'type': type
          },
        );
      }).then((value) {
        if (type == 0) {
          updateLastMessage(content); // Now updates both users' last messages
        }
      });

      scrollController.animateTo(0.0,
          duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      // Optionally, show a snackbar or error dialog to inform the user about the empty message
      print("Message cannot be empty.");
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
