import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kelimbo/screens/main/main_dashboard.dart';
import 'package:kelimbo/utils/colors.dart';
import 'package:kelimbo/utils/image_utils.dart';
import 'package:kelimbo/widgets/save_button.dart';
import 'package:kelimbo/widgets/text_form_field.dart';

class ProfilePage1 extends StatefulWidget {
  ProfilePage1({
    super.key,
  });

  @override
  State<ProfilePage1> createState() => _ProfilePage1State();
}

class _ProfilePage1State extends State<ProfilePage1> {
  String? selectedValue;
  final List<String> spanishCities = [
    'A Coruña',
    'Alcalá de Guadaira',
    'Alcalá de Henares',
    'Alcántara',
    'Alcázar de San Juan',
    'Alcoy',
    'Albacete',
    'Algeciras',
    'Alicante',
    'Almadén',
    'Almendralejo',
    'Almería',
    'Altea',
    'Alzira',
    'Andújar',
    'Antequera',
    'Aranjuez',
    'Arcos de la Frontera',
    'Arucas',
    'Astorga',
    'Ávila',
    'Avilés',
    'Badalona',
    'Badajoz',
    'Barakaldo',
    'Barcelona',
    'Baza',
    'Benidorm',
    'Bilbao',
    'Burgos',
    'Bujalance',
    'Cabañaquinta',
    'Cabra',
    'Cádiz',
    'Cangas de Narcea',
    'Calahorra',
    'Caravaca',
    'Carballo',
    'Carmona',
    'Cartagena',
    'Castellón de la Plana',
    'Cáceres',
    'Chiclana de la Frontera',
    'Ciudad Real',
    'Ciudad Rodrigo',
    'Cieza',
    'Coín',
    'Cornellà',
    'Córdoba',
    'Covadonga',
    'Cuenca',
    'Don Benito',
    'Donostia–San Sebastián',
    'Dos Hermanas',
    'Ecija',
    'Eibar',
    'El Escorial',
    'El Puerto de Santa María',
    'Elche',
    'Elda',
    'Ferrol',
    'Funes',
    'Gandía',
    'Getafe',
    'Getxo',
    'Gijón',
    'Girona',
    'Granada',
    'Granollers',
    'Guadalupe',
    'Guadix',
    'Guadalajara',
    'Guernica',
    'Hellín',
    'Huelva',
    'Huesca',
    'Irun',
    'Jaca',
    'Jaén',
    'Jerez de la Frontera',
    'Jumilla',
    'La Línea',
    'La Orotava',
    'Las Palmas',
    'León',
    'Lebrija',
    'Linares',
    'Logroño',
    'Llívia',
    'Lleida',
    'Lorca',
    'Lora del Río',
    'Lugo',
    'Luarca',
    'Lucena',
    'L’Hospitalet de Llobregat',
    'Madrid',
    'Maó',
    'Marchena',
    'Martos',
    'Manresa',
    'Málaga',
    'Mataró',
    'Melilla',
    'Mérida',
    'Mieres',
    'Miranda de Ebro',
    'Mondoñedo',
    'Monforte de Lemos',
    'Montilla',
    'Morón de la Frontera',
    'Motril',
    'Murcia',
    'Orihuela',
    'Ortigueira',
    'Osuna',
    'Ourense',
    'Oviedo',
    'Palma',
    'Palencia',
    'Pamplona',
    'Peñarroya-Pueblonuevo',
    'Plasencia',
    'Pola de Siero',
    'Ponferrada',
    'Pontevedra',
    'Portugalete',
    'Priego de Córdoba',
    'Puente-Genil',
    'Puerto Real',
    'Puertollano',
    'Requena',
    'Reus',
    'Ribeira',
    'Ronda',
    'Roncesvalles',
    'Sabadell',
    'Sagunto',
    'Salamanca',
    'Santiago de Compostela',
    'San Fernando',
    'San Ildefonso',
    'San Martín del Rey Aurelio',
    'San Sebastián',
    'Sanlúcar de Barrameda',
    'Santander',
    'Santurtzi',
    'Santiago de Compostela',
    'Santa Coloma de Gramenet',
    'Santa Cruz de Tenerife',
    'Segovia',
    'Sevilla',
    'Sestao',
    'Simancas',
    'Soria',
    'Sueca',
    'Talavera de la Reina',
    'Tarragona',
    'Telde',
    'Terrassa',
    'Teruel',
    'Tineo',
    'Tomelloso',
    'Toledo',
    'Toro',
    'Torrent',
    'Torrelavega',
    'Tortosa',
    'Trujillo',
    'Úbeda',
    'Utrera',
    'Valencia',
    'Valladolid',
    'Valdepeñas',
    'Vigo',
    'Vic',
    'Vilalba',
    'Vilagarcía de Arousa',
    'Vilanova i la Geltrú',
    'Villarreal',
    'Villarrobledo',
    'Villanueva de la Serena',
    'Villaviciosa',
    'Villena',
    'Vitoria-Gasteiz',
    'Yecla',
    'Zamora',
    'Zaragoza'
  ];

  // Selected city
  String? selectedCity;

  TextEditingController phoneController = TextEditingController();
  TextEditingController NameController = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          "Paso 1",
          style: TextStyle(
              color: colorBlack, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Divider(
            thickness: 2,
            endIndent: MediaQuery.of(context).size.width / 2,
            color: colorBlack,
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8),
              child: TextFormInputField(
                  controller: NameController,
                  hintText: "Nombre completo",
                  IconSuffix: Icons.person,
                  textInputType: TextInputType.emailAddress),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8),
              child: TextFormInputField(
                  controller: phoneController,
                  hintText: "Teléfono",
                  IconSuffix: Icons.phone,
                  textInputType: TextInputType.phone),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownSearch<String>(
                items: spanishCities,
                popupProps: PopupProps.menu(
                  showSearchBox: true,
                ),
                dropdownButtonProps: DropdownButtonProps(
                  color: Colors.blue,
                ),
                dropdownDecoratorProps: DropDownDecoratorProps(
                  textAlignVertical: TextAlignVertical.center,
                  dropdownSearchDecoration: InputDecoration(
                      border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                  )),
                ),
                onChanged: (value) {
                  setState(() {
                    selectedValue = value.toString();
                  });
                },
                selectedItem: "Seleccionar ubicación",
              ),
            ),
          ),
          isLoading
              ? Center(child: CircularProgressIndicator())
              : SaveButton(
                  title: "Continuar",
                  onTap: () async {
                    if (NameController.text.isEmpty) {
                      showMessageBar("El nombre es requerido", context);
                    } else if (phoneController.text.isEmpty) {
                      showMessageBar("El teléfono es requerido", context);
                    } else if (selectedValue!.isEmpty) {
                      showMessageBar("La ubicación es requerida", context);
                    } else {
                      setState(() {
                        isLoading = true;
                      });
                      await FirebaseFirestore.instance
                          .collection("users")
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .update({
                        "fullName": NameController.text.trim(),
                        "phone": phoneController.text.trim(),
                        "location": selectedValue,
                      });
                      setState(() {
                        isLoading = false;
                      });

                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (builder) => MainDashboard()));
                    }
                  })
        ],
      ),
    );
  }
}
