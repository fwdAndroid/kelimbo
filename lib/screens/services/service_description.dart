import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kelimbo/screens/services/edit_service.dart';
import 'package:kelimbo/widgets/delete_service_widget.dart';
import 'package:kelimbo/widgets/save_button.dart';

class ServiceDescription extends StatefulWidget {
  final photo;
  final title;
  final description;
  final uuid;
  final price;
  final perpriceHr;
  final category;
  const ServiceDescription(
      {super.key,
      required this.description,
      required this.perpriceHr,
      required this.photo,
      required this.price,
      required this.title,
      required this.category,
      required this.uuid});

  @override
  State<ServiceDescription> createState() => _ServiceDescriptionState();
}

class _ServiceDescriptionState extends State<ServiceDescription> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.photo),
              radius: 50,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                widget.title,
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold, fontSize: 28),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                widget.category,
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
            Center(
              child: SizedBox(
                height: 150,
                width: 390,
                child: Text(
                  widget.description,
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w500, fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.network(
                widget.photo,
                height: 254,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                      width: 160,
                      child: SaveButton(
                          title: "Servicio de edición",
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (builder) => EditService(
                                          uuid: widget.uuid,
                                        )));
                          })),
                  const SizedBox(
                    width: 10,
                  ),
                  SizedBox(
                    width: 160,
                    child: SaveButton(
                        title: "Eliminar servicio",
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return DeleteServiceWidget(
                                uuid: widget.uuid,
                              );
                            },
                          );
                        }),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
