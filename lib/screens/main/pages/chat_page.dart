import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kelimbo/screens/main/chat/messages.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(itemBuilder: (index, contrxt) {
        return Column(
          children: [
            ListTile(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (builder) => Messages()));
              },
              leading: CircleAvatar(
                backgroundImage: AssetImage("assets/logo.png"),
              ),
              title: Text(
                "Estudio juridico Alvarez",
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600, fontSize: 16),
              ),
              subtitle: Text(
                "Hello, Where are you",
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w300, fontSize: 14),
              ),
              trailing: Text(
                "12:00",
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w300, fontSize: 14),
              ),
            ),
            Divider()
          ],
        );
      }),
    );
  }
}
