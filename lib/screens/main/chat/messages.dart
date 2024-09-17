import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kelimbo/utils/colors.dart';
import 'package:kelimbo/widgets/text_form_field.dart';

class Messages extends StatefulWidget {
  const Messages({super.key});

  @override
  State<Messages> createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  List<ChatMessage> messages = [
    ChatMessage(
        messageContent:
            "Hola! Estoy interesada/o en el aviso asesoría legal y comercial",
        messageType: "receiver",
        time: "12:50"),
    ChatMessage(messageContent: "Hola!", messageType: "sender", time: "12:50"),
    ChatMessage(
        messageContent:
            "Claro, estaré encantado de ayudarte. Cuéntame, ¿qué problema estás teniendo?",
        messageType: "sender",
        time: "12:50"),
    ChatMessage(
        messageContent:
            "resulta que vivo en el apartamento hace casi un año...",
        messageType: "receiver",
        time: "12:50"),
  ];

  @override
  Widget build(BuildContext context) {
    TextEditingController messageController = TextEditingController();
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
        title: Column(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage:
                  AssetImage("assets/logo.png"), // Add your image here
            ),
            SizedBox(height: 4),
            Text(
              "Ana Mansilla",
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                color: colorBlack,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: <Widget>[
          ListView.builder(
            itemCount: messages.length,
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Align(
                  alignment: (messages[index].messageType == "receiver"
                      ? Alignment.topLeft
                      : Alignment.topRight),
                  child: Column(
                    crossAxisAlignment:
                        messages[index].messageType == "receiver"
                            ? CrossAxisAlignment.start
                            : CrossAxisAlignment.end,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: (messages[index].messageType == "receiver"
                              ? Color(0xfff0f2f9)
                              : Color(0xff668681)),
                        ),
                        padding: EdgeInsets.all(12),
                        child: Text(
                          messages[index].messageContent,
                          style: TextStyle(
                              fontSize: 15,
                              color: messages[index].messageType == "receiver"
                                  ? colorBlack
                                  : colorWhite),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        messages[index].time,
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
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
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
                      // Send message action
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
}

class ChatMessage {
  String messageContent;
  String messageType;
  String time;
  ChatMessage(
      {required this.messageContent,
      required this.messageType,
      required this.time});
}
