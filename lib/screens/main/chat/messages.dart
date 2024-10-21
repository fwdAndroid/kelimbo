import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kelimbo/screens/main/other/other_user_profile.dart';
import 'package:kelimbo/utils/colors.dart';
import 'package:kelimbo/widgets/text_form_field.dart';
import 'package:intl/intl.dart';

class Messages extends StatefulWidget {
  final providerId;
  final customerId;
  final providerName;
  final providerEmail;
  final providerPhoto;
  final customerName;
  final customerPhoto;
  final customerEmail;
  final chatId;
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
  String groupChatId = "";
  ScrollController scrollController = ScrollController();
  bool show = false;

  TextEditingController messageController = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    if (widget.customerId.hashCode <= widget.providerId.hashCode) {
      groupChatId = "${widget.customerId}-${widget.providerId}";
    } else {
      groupChatId = "${widget.providerId}-${widget.customerId}";
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (builder) => OtherUserProfile(
                          userImage: widget.providerPhoto,
                          userName: widget.providerName,
                          userEmail: widget.providerEmail,
                          customerEmail: widget.customerEmail,
                          customerName: widget.customerName,
                          customerPhoto: widget.customerPhoto,
                          uid: widget.customerId,
                        )));
          },
          child: Column(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage:
                    NetworkImage(widget.customerPhoto), // Add your image here
              ),
              SizedBox(height: 4),
              Text(
                widget.customerName,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  color: colorBlack,
                  fontSize: 16,
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
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  return snapshot.data!.docs == 0
                      ? Center(child: Text("Vacía "))
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
                              return ds.get("type") == 0
                                  ? Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 4),
                                      child: Align(
                                        alignment: (ds.get("senderId") ==
                                                FirebaseAuth
                                                    .instance.currentUser!.uid
                                            ? Alignment.topLeft
                                            : Alignment.topRight),
                                        child: Column(
                                          crossAxisAlignment:
                                              (ds.get("senderId") ==
                                                      FirebaseAuth.instance
                                                          .currentUser!.uid
                                                  ? CrossAxisAlignment.start
                                                  : CrossAxisAlignment.end),
                                          //     crossAxisAlignment:
                                          // messages[index].messageType ==
                                          //         "receiver"
                                          //     ? CrossAxisAlignment.start
                                          //     : CrossAxisAlignment.end,
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                color: (ds.get("senderId") ==
                                                        FirebaseAuth.instance
                                                            .currentUser!.uid
                                                    ? Color(0xfff0f2f9)
                                                    : Color(0xff668681)),
                                              ),
                                              padding: EdgeInsets.all(12),
                                              child: Text(
                                                ds.get("content"),
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    color: (ds.get(
                                                                "senderId") ==
                                                            FirebaseAuth
                                                                .instance
                                                                .currentUser!
                                                                .uid
                                                        ? colorBlack
                                                        : colorWhite)),
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              DateFormat.jm().format(DateTime
                                                  .fromMillisecondsSinceEpoch(
                                                      int.parse(
                                                          ds.get("time")))),
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : Container();
                            },
                          ),
                        );
                } else if (snapshot.hasError) {
                  return Center(child: Icon(Icons.error_outline));
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              }),
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
                      hintText: "Enviar mensaje",
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
    // type: 0 = text, 1 = image, 2 = sticker
    if (content.trim() != '') {
      messageController.clear();

      var documentReference = FirebaseFirestore.instance
          .collection('messages')
          .doc(groupChatId)
          .collection(groupChatId)
          .doc(DateTime.now().millisecondsSinceEpoch.toString());

      FirebaseFirestore.instance.runTransaction((transaction) async {
        await transaction.set(
          documentReference,
          {
            "senderId": widget.customerId,
            "receiverId": widget.providerId,
            "time": DateTime.now().millisecondsSinceEpoch.toString(),
            'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
            'content': content,
            'type': type
          },
        );
      }).then((value) {
        if (type == 0) {
          // Assuming type 0 is for 'note'
          updateLastMessageByProvider(content);
        }
      });

      scrollController.animateTo(0.0,
          duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      // Fluttertoast.showToast(msg: 'Nothing to send');
    }
  }

  void updateLastMessageByProvider(String messageContent) async {
    final chatDocRef =
        FirebaseFirestore.instance.collection('chats').doc(widget.chatId);

    // Check if the document exists before attempting to update it
    final chatDocSnapshot = await chatDocRef.get();
    if (chatDocSnapshot.exists) {
      // Document exists, update the lastMessageByProvider field
      await chatDocRef.update({
        'lastMessageByCustomer': messageContent,
      }).catchError((error) {
        print("Failed to update last message by provider: $error");
      });
    } else {
      print("Document does not exist, cannot update last message by provider");
    }
  }
}
