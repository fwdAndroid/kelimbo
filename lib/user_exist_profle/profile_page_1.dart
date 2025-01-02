import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kelimbo/user_exist_profle/profile_page_2.dart';
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
    'Almería',
    'Algeciras',
    'Arcos de la Frontera',
    'Cádiz',
    'Chiclana de la Frontera',
    'El Puerto de Santa María',
    'Jerez de la Frontera',
    'La Línea',
    'Puerto Real',
    'San Fernando',
    'Sanlúcar de Barrameda',
    'Bujalance',
    'Cabra',
    'Córdoba',
    'Lucena',
    'Montilla',
    'Peñarroya-Pueblonuevo',
    'Priego de Córdoba',
    'Puente-Genil',
    'Andújar',
    'Baza',
    'Granada',
    'Guadix',
    'Motril',
    'Huelva',
    'Jaén',
    'Linares',
    'Úbeda',
    'Antequera',
    'Coín',
    'Málaga',
    'Melilla',
    'Ronda',
    'Alcalá de Guadaira',
    'Carmona',
    'Dos Hermanas',
    'Ecija',
    'Lebrija',
    'Lora del Río',
    'Marchena',
    'Morón de la Frontera',
    'Utrera',
    'Sevilla',
    'Osuna',
    'Huesca',
    'Jaca',
    'Teruel',
    'Zaragoza',
    'Avilés',
    'Cabañaquinta',
    'Cangas de Narcea',
    'Covadonga',
    'Gijón',
    'Luarca',
    'Mieres',
    'Oviedo',
    'Pola de Siero',
    'San Martín del Rey Aurelio',
    'Tineo',
    'Villaviciosa',
    'Palma',
    'Maó',
    'Vitoria-Gasteiz',
    'Donostia–San Sebastián',
    'Eibar',
    'Irun',
    'Barakaldo',
    'Bilbao',
    'Getxo',
    'Guernica',
    'Portugalete',
    'Santurtzi',
    'Sestao',
    'Arucas',
    'Las Palmas',
    'Telde',
    'La Orotava',
    'Santa Cruz de Tenerife',
    'Santander',
    'Torrelavega',
    'Albacete',
    'Hellín',
    'Villarrobledo',
    'Alcázar de San Juan',
    'Almadén',
    'Ciudad Real',
    'Puertollano',
    'Tomelloso',
    'Valdepeñas',
    'Cuenca',
    'Guadalajara',
    'Talavera de la Reina',
    'Toledo',
    'Ávila',
    'Burgos',
    'Miranda de Ebro',
    'Astorga',
    'León',
    'Ponferrada',
    'Palencia',
    'Ciudad Rodrigo',
    'Salamanca',
    'San Ildefonso',
    'Segovia',
    'Soria',
    'Simancas',
    'Valladolid',
    'Toro',
    'Zamora',
    'Badalona',
    'Barcelona',
    'Cornellà',
    'Granollers',
    'L’Hospitalet de Llobregat',
    'Manresa',
    'Mataró',
    'Reus',
    'Sabadell',
    'Santa Coloma de Gramenet',
    'Terrassa',
    'Vic',
    'Vilanova i la Geltrú',
    'Girona',
    'Llívia',
    'Lleida',
    'Tarragona',
    'Tortosa',
    'Almendralejo',
    'Badajoz',
    'Don Benito',
    'Mérida',
    'Villanueva de la Serena',
    'Alcántara',
    'Cáceres',
    'Guadalupe',
    'Plasencia',
    'Trujillo',
    'A Coruña',
    'Carballo',
    'Ferrol',
    'Ortigueira',
    'Ribeira',
    'Santiago de Compostela',
    'Lugo',
    'Mondoñedo',
    'Monforte de Lemos',
    'Vilalba',
    'Ourense',
    'Vigo',
    'Vilagarcía de Arousa',
    'Pontevedra',
    'Alcalá de Henares',
    'Aranjuez',
    'El Escorial',
    'Getafe',
    'Madrid',
    'Caravaca',
    'Cartagena',
    'Cieza',
    'Jumilla',
    'Lorca',
    'Murcia',
    'Yecla',
    'Funes',
    'Pamplona',
    'Roncesvalles',
    'Calahorra',
    'Logroño',
    'Alcoy',
    'Alicante',
    'Elche',
    'Elda',
    'Orihuela',
    'Villena',
    'Castellón de la Plana',
    'Villarreal',
    'Alzira',
    'Gandía',
    'Requena',
    'Sagunto',
    'Sueca',
    'Torrent',
    'Valencia'
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
              padding: const EdgeInsets.only(left: 8.0, right: 8),
              child: DropdownButton<String>(
                isExpanded: true,
                hint: Text('Seleccione una ciudad'),
                value: selectedValue,
                onChanged: (value) {
                  setState(() {
                    selectedValue = value!;
                  });
                },
                items: spanishCities.map((String item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
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
                              builder: (builder) => ProfilePage2()));
                    }
                  })
        ],
      ),
    );
  }
}
