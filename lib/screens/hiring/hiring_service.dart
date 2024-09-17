import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marketplace/screens/hiring/hiring_service_comment.dart';
import 'package:marketplace/widgets/save_button.dart';

class HiringService extends StatefulWidget {
  const HiringService({super.key});

  @override
  State<HiringService> createState() => _HiringServiceState();
}

class _HiringServiceState extends State<HiringService> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage("assets/logo.png"),
              radius: 50,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Estudio juridico \nAlvarez",
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold, fontSize: 28),
                textAlign: TextAlign.center,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.star,
                  color: Colors.yellow,
                ),
                Text(
                  "(15)",
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: 19,
                      color: Color(0xff9C9EA2)),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Asesoria legal y comercial",
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
            Center(
              child: SizedBox(
                height: 150,
                width: 390,
                child: Text(
                  "Proporcionamos apoyo integral a las empresas, ayudándolas a navegar por el complejo entorno legal y a maximizar sus oportunidades comerciales. Este enfoque proactivo y estratégico asegura que las empresas no solo cumplan con las normativas, sino que también optimicen su rendimiento y crecimiento a largo plazo.",
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w500, fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(
                "assets/marlet.png",
                height: 254,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SaveButton(
                  title: "Solicitar presupuesto",
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (builder) => HiringServiceComments()));
                  }),
            )
          ],
        ),
      ),
    );
  }
}
