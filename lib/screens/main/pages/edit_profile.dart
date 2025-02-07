import 'dart:typed_data';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kelimbo/screens/main/main_dashboard.dart';
import 'package:kelimbo/utils/colors.dart';
import 'package:kelimbo/utils/image_utils.dart';
import 'package:kelimbo/widgets/save_button.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  TextEditingController addressController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  bool _isLoading = false;
  Uint8List? _image;
  String? imageUrl;
  String? selectedValue;

  final List<String> spanishCities = [
    'A Coruña',
    'Alava',
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
    'Asturias',
    'Avila',
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
    'Castellón',
    'Castellón de la Plana',
    'Cáceres',
    'Ceuta',
    'Chiclana de la Frontera',
    'Ciudad Real',
    'Ciudad Rodrigo',
    'Cieza',
    'Cantabria',
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
    'El Hierro',
    'El Escorial',
    'El Puerto de Santa María',
    'Elche',
    'Elda',
    'Ferrol',
    'Formentera',
    'Fuerteventura',
    'Funes',
    'Gandía',
    'Getafe',
    'Getxo',
    'Gijón',
    'Girona',
    'Granada',
    'Granollers',
    'Gran Canaria',
    'Guadalupe',
    'Guadix',
    'Guadalajara',
    'Guernica',
    'Guipuzcoa',
    'Hellín',
    'Huelva',
    'Huesca',
    'Ibiza',
    'Irun',
    'Jaca',
    'Jaén',
    'Jerez de la Frontera',
    'Jumilla',
    'La Gomera',
    'La Línea',
    'La Nucía',
    'Lanzarote',
    'La Orotava',
    'Las Palma',
    'Las Palmas de Gran Canaria',
    'La Rioja',
    'León',
    'Lebrija',
    'Lérida',
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
    'Mallorca',
    'Maó',
    'Marchena',
    'Martos',
    'Manresa',
    'Málaga',
    'Mataró',
    'Melilla',
    'Menorca',
    'Mérida',
    'Mieres',
    'Miranda de Ebro',
    'Mondoñedo',
    'Monforte de Lemos',
    'Montilla',
    'Morón de la Frontera',
    'Motril',
    'Murcia',
    'Navarra',
    'Orense',
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
    'Tenerife',
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
    'Vizcaya',
    'Zamora',
    'Zaragoza'
  ];

  // Selected city
  String? selectedCity;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    // Fetch data from Firestore
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // Update the controllers with the fetched data
    setState(() {
      addressController.text = data['location'] ?? '';
      phoneController.text = (data['phone'] ?? ''); // Convert int to string
      nameController.text = data['fullName'] ?? ''; // Convert int to string
      imageUrl = data['image'];
      selectedValue = data['location'] ?? '';
    });
  }

  Future<void> selectImage() async {
    Uint8List ui = await pickImage(ImageSource.gallery);
    setState(() {
      _image = ui;
    });
  }

  Future<String> uploadImageToStorage(Uint8List image) async {
    Reference ref = FirebaseStorage.instance
        .ref()
        .child('users')
        .child('${FirebaseAuth.instance.currentUser!.uid}.jpg');
    UploadTask uploadTask = ref.putData(image);
    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("Editar perfil"),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () => selectImage(),
                child: _image != null
                    ? CircleAvatar(
                        radius: 59, backgroundImage: MemoryImage(_image!))
                    : imageUrl != null
                        ? CircleAvatar(
                            radius: 59,
                            backgroundImage: NetworkImage(imageUrl!))
                        : Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.asset("assets/profilephoto.png"),
                          ),
              ),
            ),
            Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8, bottom: 8),
                child: TextFormField(
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(8),
                    fillColor: textColor,
                    filled: true,
                    hintStyle: GoogleFonts.nunitoSans(fontSize: 16),
                    hintText: "Nombre y apellido",
                  ),
                  controller: nameController,
                )),
            Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8, bottom: 8),
                child: TextFormField(
                  readOnly: true,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(8),
                    fillColor: textColor,
                    filled: true,
                    hintStyle: GoogleFonts.nunitoSans(fontSize: 16),
                    hintText: "Domicilio",
                  ),
                  controller: addressController,
                )),
            Padding(
                padding: const EdgeInsets.only(
                    left: 8.0, right: 8, top: 8, bottom: 8),
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(8),
                    fillColor: textColor,
                    filled: true,
                    hintStyle: GoogleFonts.nunitoSans(fontSize: 16),
                    hintText: "Telefono",
                  ),
                  controller: phoneController,
                )),
            Text("Cambiar Ubicación"),
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
            Spacer(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: mainColor,
                      ),
                    )
                  : SaveButton(
                      title: "Editar Perfil",
                      onTap: () async {
                        setState(() {
                          _isLoading = true;
                        });

                        String? downloadUrl;
                        if (_image != null) {
                          downloadUrl = await uploadImageToStorage(_image!);
                        } else {
                          downloadUrl = imageUrl;
                        }

                        try {
                          await FirebaseFirestore.instance
                              .collection("users")
                              .doc(FirebaseAuth.instance.currentUser!
                                  .uid) // Use widget.uuid here
                              .update({
                            "fullName": nameController.text,
                            "phone":
                                phoneController.text, // Convert string to int
                            "location": selectedValue, // Convert string to int
                            "image": downloadUrl,
                          });
                          showMessageBar(
                              "Perfil actualizado con éxito ", context);
                        } catch (e) {
                          // Handle errors here
                          print("Error updating service: $e");
                          showMessageBar(
                              "No se pudo actualizar el servicio", context);
                        } finally {
                          setState(() {
                            _isLoading = false;
                          });
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (builder) => MainDashboard()));
                        }
                      }),
            ),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}
