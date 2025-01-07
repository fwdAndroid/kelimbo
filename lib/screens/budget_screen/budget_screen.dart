import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kelimbo/screens/main/main_dashboard.dart';
import 'package:kelimbo/utils/colors.dart';
import 'package:kelimbo/utils/image_utils.dart';
import 'package:kelimbo/widgets/save_button.dart';
import 'package:kelimbo/widgets/text_form_field.dart';

class BudgetScreen extends StatefulWidget {
  final providerEmail,
      providerImage,
      providerName,
      serviceDescription,
      serviceProviderId,
      serviceTitle,
      status,
      uuid,
      work;
  final price;
  final priceprehr;
  final totalRating;
  final clientEmail, clientId, clientImage, clientName;
  BudgetScreen(
      {super.key,
      required this.price,
      required this.priceprehr,
      required this.providerEmail,
      required this.clientName,
      required this.providerImage,
      required this.providerName,
      required this.serviceDescription,
      required this.serviceProviderId,
      required this.serviceTitle,
      required this.clientEmail,
      required this.clientId,
      required this.clientImage,
      required this.status,
      required this.totalRating,
      required this.uuid,
      required this.work});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(widget.price);
  }

  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    TextEditingController _priceController = TextEditingController();
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Center(
            child: Text(
              "Solictar a: ${widget.clientName}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: colorBlack,
                fontSize: 22,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          TextFormInputField(
              controller: _priceController,
              hintText: "\$1000",
              textInputType: TextInputType.number),
          Spacer(),
          isLoading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SaveButton(
                      title: "Finalizar",
                      onTap: () async {
                        if (_priceController.text.isEmpty) {
                          showMessageBar("El precio es obligatorio", context);
                        } else {
                          setState(() {
                            isLoading = true;
                          });
                          await FirebaseFirestore.instance
                              .collection("offers")
                              .doc(widget.uuid)
                              .update({
                            "status": "counterOffer",
                            "price": int.parse(_priceController.text)
                          });
                          showMessageBar("Oferta Enviar Al Cliente", context);
                          setState(() {
                            isLoading = true;
                          });
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (builder) => MainDashboard()));
                        }
                      }),
                )
        ],
      ),
    );
  }
}
