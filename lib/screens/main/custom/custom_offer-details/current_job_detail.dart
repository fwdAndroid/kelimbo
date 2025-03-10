import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kelimbo/screens/main/main_dashboard.dart';
import 'package:kelimbo/screens/main/pages/favourite_page.dart';

class CurrentJobDetail extends StatefulWidget {
  String uuid;
  String description;
  String price;
  var currency;
  String status;
  CurrentJobDetail(
      {super.key,
      required this.status,
      required this.uuid,
      required this.description,
      required this.currency,
      required this.price});

  @override
  State<CurrentJobDetail> createState() => _CurrentJobDetailState();
}

class _CurrentJobDetailState extends State<CurrentJobDetail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus(); // Hide keyboard on button
          },
          child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Descripción: ",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(
                    height: 300,
                    child: Text(
                      widget.description,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  Text(
                    "Precio: ",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    widget.price +
                        " " +
                        getCurrencySymbol(widget.currency ?? 'Euro'),
                    style: TextStyle(fontSize: 16),
                  ),
                  TextButton(
                      onPressed: () async {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text("Confirmar"),
                                content: Text(
                                    "¿Está seguro de que desea marcar este trabajo como completado?"),
                                actions: [
                                  TextButton(
                                    child: Text("Cancelar"),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  TextButton(
                                    child: Text("Sí"),
                                    onPressed: () async {
                                      await FirebaseFirestore.instance
                                          .collection('customOffers')
                                          .doc(widget.uuid)
                                          .update({
                                        'status': 'completed',
                                      });
                                      Navigator.of(context).pop();
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  MainDashboard()));
                                    },
                                  ),
                                ],
                              );
                            });
                      },
                      child: Text(
                        "Marcar como completado",
                        style: TextStyle(color: Colors.green),
                      ))
                ],
              )),
        ));
  }
}
