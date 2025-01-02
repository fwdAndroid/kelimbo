import 'package:cloud_firestore/cloud_firestore.dart';
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
        title: const Text("Filter by Location"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              hint: const Text('Seleccione una ciudad'),
              value: selectedValue,
              onChanged: (value) {
                setState(() {
                  selectedValue = value; // Update selected value
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
          ElevatedButton(
            onPressed: () {
              setState(() {}); // Trigger rebuild to filter results
            },
            child: const Text("Filter"),
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
                      "No results found for the entered location.",
                      style: TextStyle(fontSize: 16),
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
