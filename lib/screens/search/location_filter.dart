import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kelimbo/screens/hiring/hiring_service.dart';

class LocationFilter extends StatefulWidget {
  const LocationFilter({Key? key}) : super(key: key);

  @override
  State<LocationFilter> createState() => _LocationFilterState();
}

class _LocationFilterState extends State<LocationFilter> {
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
  final currentUserId = FirebaseAuth.instance.currentUser!.uid;

  Stream<QuerySnapshot> _getFilteredQuery() {
    final servicesCollection =
        FirebaseFirestore.instance.collection("services");

    if (selectedValue == null || selectedValue!.trim().isEmpty) {
      // Return all results if no location is selected
      return servicesCollection.snapshots();
    }

    // Filter based on selected location
    return servicesCollection
        .where('location', isEqualTo: selectedValue!.trim())
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Filtrar por ubicación"),
      ),
      body: Column(
        children: [
          Padding(
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
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getFilteredQuery(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "No se han encontrado resultados para la ubicación introducida.",
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final DocumentSnapshot document =
                        snapshot.data!.docs[index];
                    final data = document.data() as Map<String, dynamic>;
                    final List<dynamic> favorites = data['favorite'] ?? [];

                    bool isFavorite = favorites.contains(currentUserId);

                    return GestureDetector(
                      onTap: () {
                        // Handle navigation or actions on item tap
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (builder) => HiringService(
                              serviceDescription: data['description'],
                              serviceId: data['uuid'],
                              currencyType: data['currency'],
                              price: data['price'].toString(),
                              userEmail: data['userEmail'],
                              userImage: data['userImage'],
                              userName: data['userName'],
                              category: data['category'],
                              totalReviews: data['totalReviews'].toString(),
                              uuid: data['uuid'],
                              uid: data['uid'],
                              totalRating: data['totalRate'].toString(),
                              title: data['title'],
                              perHrPrice: data['pricePerHr'].toString(),
                              photo: data['photo'],
                              description: data['description'],
                            ),
                          ),
                        );
                      },
                      child: Card(
                        child: Column(
                          children: [
                            ListTile(
                              trailing: IconButton(
                                icon: Icon(
                                  Icons.favorite,
                                  color: isFavorite ? Colors.red : Colors.grey,
                                ),
                                onPressed: () async {
                                  if (isFavorite) {
                                    await FirebaseFirestore.instance
                                        .collection('services')
                                        .doc(document.id)
                                        .update({
                                      'favorite': FieldValue.arrayRemove(
                                          [currentUserId])
                                    });
                                  } else {
                                    await FirebaseFirestore.instance
                                        .collection('services')
                                        .doc(document.id)
                                        .update({
                                      'favorite':
                                          FieldValue.arrayUnion([currentUserId])
                                    });
                                  }
                                },
                              ),
                              leading: CircleAvatar(
                                backgroundImage:
                                    NetworkImage(data['photo'] ?? ""),
                              ),
                              title: Text(
                                data['category'] ?? "No category",
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Text(
                                data['location'] ?? "No location",
                                style: GoogleFonts.inter(
                                  color: const Color(0xff9C9EA2),
                                  fontWeight: FontWeight.w300,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      "€${data['price'].toString()}",
                                      style: GoogleFonts.inter(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20),
                                    ),
                                    Text(
                                      data['priceType'] ?? "No price type",
                                      style: GoogleFonts.inter(
                                          color: const Color(0xff9C9EA2),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 19),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 16),
                                Column(
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.star,
                                            color: Colors.yellow),
                                        Text(
                                          data['ratingCount']?.toString() ??
                                              "0",
                                          style: GoogleFonts.inter(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      "${data['totalReviews']?.toString() ?? "0"} Reviews",
                                      style: GoogleFonts.inter(
                                          color: const Color(0xff9C9EA2),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 19),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
