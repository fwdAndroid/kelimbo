import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marketplace/screens/main/main_dashboard.dart';
import 'package:marketplace/utils/colors.dart';
import 'package:marketplace/widgets/save_button.dart';

class HiringServiceComments extends StatefulWidget {
  const HiringServiceComments({super.key});

  @override
  State<HiringServiceComments> createState() => _HiringServiceCommentsState();
}

class _HiringServiceCommentsState extends State<HiringServiceComments> {
  TextEditingController descriptionController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Cuentanos que necesitas)",
              style: GoogleFonts.inter(
                color: colorBlack,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                filled: true,
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(28)),
                    borderSide: BorderSide(
                      color: textColor,
                    )),
                contentPadding: EdgeInsets.all(8),
                fillColor: Color(0xffF5F4F8),
                hintText: "Description",
                hintStyle: GoogleFonts.nunitoSans(fontSize: 16),
                border: InputBorder.none,
              ),
            ),
          ),
          Spacer(),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SaveButton(
                  title: "Finalizar",
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (builder) => MainDashboard()));
                  }),
            ),
          )
        ],
      ),
    ));
  }
}
