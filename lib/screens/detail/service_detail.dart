import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marketplace/screens/detail/service_rate.dart';
import 'package:marketplace/utils/colors.dart';
import 'package:marketplace/widgets/save_button.dart';

class ServiceDetail extends StatefulWidget {
  const ServiceDetail({super.key});

  @override
  State<ServiceDetail> createState() => _ServiceDetailState();
}

class _ServiceDetailState extends State<ServiceDetail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Asesoria legal y comercial",
          style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text(
                  "Price: ",
                  style: GoogleFonts.inter(
                      fontSize: 20, fontWeight: FontWeight.w700),
                ),
                Text(
                  "400\$",
                  style: GoogleFonts.inter(
                      fontSize: 20, fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage("assets/logo.png"),
            ),
            title: Text(
              "Maia Lopez",
              style:
                  GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            subtitle: Row(
              children: [
                Text(
                  "Contactor ",
                  style: GoogleFonts.inter(
                      fontSize: 18, fontWeight: FontWeight.w400),
                ),
                Icon(
                  Icons.message,
                  color: color,
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Details",
              style:
                  GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8),
            child: SizedBox(
              width: 389,
              height: 200,
              child: Text(
                "Estoy buscando asesoría legal sobre un tema de propiedad intelectual relacionado con mi empresa de tecnología. He desarrollado una aplicación innovadora y quiero asegurarme de proteger mi propiedad intelectual adecuadamente.",
                style: GoogleFonts.inter(
                    fontSize: 18, fontWeight: FontWeight.w400),
              ),
            ),
          ),
          Spacer(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: SaveButton(
                  title: "I have Received the Service",
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (builder) => ServiceRate()));
                  }),
            ),
          )
        ],
      ),
    );
  }
}
