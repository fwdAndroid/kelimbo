import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kelimbo/screens/main/main_dashboard.dart';
import 'package:kelimbo/utils/colors.dart';
import 'package:kelimbo/widgets/save_button.dart';
import 'package:kelimbo/widgets/text_form_field.dart';
import 'package:uuid/uuid.dart';

class SendCustomOffers extends StatefulWidget {
  const SendCustomOffers({super.key});

  @override
  State<SendCustomOffers> createState() => _SendCustomOffersState();
}

class _SendCustomOffersState extends State<SendCustomOffers> {
  TextEditingController descriptionController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  String currencyType = "Euro";
  var currency = ['Euro', 'USD', 'BTC', 'ETH', 'G1'];
  bool isAdded = false;

  String? selectedUserId;
  String? selectedUserName;
  List<Map<String, dynamic>> users = [];

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('uid', isNotEqualTo: currentUser.uid)
          .get();

      setState(() {
        users = snapshot.docs.map((doc) {
          return {
            'fullName': doc['fullName'] ?? 'No Name',
            'uid': doc['uid'],
          };
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var uuid = Uuid().v1();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          "Agregar servicio",
          style: GoogleFonts.workSans(
            color: colorBlack,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("users")
                .where("uid", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                .snapshots(),
            builder: (context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: Text("Cargando..."));
              }
              if (!snapshot.hasData || snapshot.data == null) {
                return Center(child: Text('No data available'));
              }
              var snap =
                  snapshot.data!.docs.first.data() as Map<String, dynamic>;

              return Column(
                children: [
                  if (users.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: DropdownButton<String>(
                        value: selectedUserId,
                        hint: Text('Seleccionar proveedor de servicios'),
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down),
                        items: users.map((user) {
                          return DropdownMenuItem<String>(
                            value: user['uid'],
                            child: Text('${user['fullName']}'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedUserId = value;
                            selectedUserName = users.firstWhere(
                                (user) => user['uid'] == value)['fullName'];
                          });
                        },
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
                            borderRadius: BorderRadius.all(Radius.circular(22)),
                            borderSide: BorderSide(
                              color: textColor,
                            )),
                        contentPadding: EdgeInsets.all(8),
                        fillColor: Color(0xffF6F7F9),
                        hintText: "Descripción",
                        hintStyle: GoogleFonts.nunitoSans(fontSize: 16),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 8),
                    child: TextFormInputField(
                      controller: priceController,
                      hintText: "Precio",
                      textInputType: TextInputType.number,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 8),
                    child: DropdownButton(
                      value: currencyType,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down),
                      items: currency.map((String currency) {
                        return DropdownMenuItem(
                          value: currency,
                          child: Text(currency),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          currencyType = newValue!;
                        });
                      },
                    ),
                  ),
                  isAdded
                      ? Center(child: CircularProgressIndicator())
                      : SaveButton(
                          title: "Enviar Oferta Personalizada",
                          onTap: () async {
                            if (validateInputs(context)) {
                              if (selectedUserId == null ||
                                  selectedUserName == null) {
                                showMessageBar(
                                    "Debe seleccionar un proveedor de servicios",
                                    context);
                                return;
                              }

                              setState(() {
                                isAdded = true;
                              });

                              try {
                                if (descriptionController.text.isEmpty) {
                                  showMessageBar(
                                      "Descripción es obligatoria", context);
                                } else if (priceController.text.isEmpty) {
                                  showMessageBar(
                                      "Precio es obligatorio", context);
                                } else {
                                  await FirebaseFirestore.instance
                                      .collection("customOffers")
                                      .doc(uuid)
                                      .set({
                                    "description": descriptionController.text,
                                    "price": priceController.text,
                                    "currency": currencyType,
                                    "userId":
                                        FirebaseAuth.instance.currentUser!.uid,
                                    "userName": snap['fullName'],
                                    "offerId": uuid,
                                    "status": "pending",
                                    "createdAt": DateTime.now(),
                                    "serviceProviderId": selectedUserId,
                                    "serviceProviderName": selectedUserName,
                                  });
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (builder) => MainDashboard(),
                                    ),
                                  );
                                  showMessageBar(
                                      "Oferta personalizada enviada con éxito",
                                      context);
                                }
                              } catch (e) {
                                showMessageBar(e.toString(), context);
                              }
                            }
                          }),
                ],
              );
            }),
      ),
    );
  }

  bool validateInputs(BuildContext context) {
    if (descriptionController.text.isEmpty) {
      showMessageBar("La descripción es obligatoria", context);
      return false;
    } else if (priceController.text.isEmpty) {
      showMessageBar("El precio es obligatorio", context);
      return false;
    }
    return true;
  }

  void showMessageBar(String message, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
