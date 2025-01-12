import 'package:flutter/material.dart';
import 'package:kelimbo/screens/main/custom/tab/current_job.dart';
import 'package:kelimbo/screens/main/custom/tab/custom_offer_complete.dart';
import 'package:kelimbo/screens/main/custom/tab/custom_offer_completed.dart';
import 'package:kelimbo/screens/main/custom/tab/custom_offer_declined.dart';

class RecentWorks extends StatefulWidget {
  const RecentWorks({super.key});

  @override
  State<RecentWorks> createState() => _RecentWorksState();
}

class _RecentWorksState extends State<RecentWorks> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          bottom: const TabBar(
            labelStyle: TextStyle(fontSize: 10),
            unselectedLabelStyle: TextStyle(fontSize: 10),
            tabs: [
              Tab(text: "Pendientes"),
              Tab(text: "Enviados"),
              Tab(text: 'Aceptados'),
              Tab(text: "Rechazados"),
              Tab(
                text: "Completados",
              )
            ],
          ),
          title: Text('Oferta Personalizada'),
        ),
        body: TabBarView(
          children: [
            CurrentJob(), // Accepte
            CustomOfferComplete(), // Complete
            CustomOfferCompleted(), //Recived
            CustomOfferDeclined(), // Declined
            CustomOfferDeclined(), // Declined
          ],
        ),
      ),
    );
  }
}

//     Scaffold(
//       appBar: AppBar(),
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             StreamBuilder(
//                 stream: FirebaseFirestore.instance
//                     .collection("users")
//                     .doc(FirebaseAuth.instance.currentUser!.uid)
//                     .snapshots(),
//                 builder: (context, AsyncSnapshot snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return Center(child: CircularProgressIndicator());
//                   }
//                   if (!snapshot.hasData || snapshot.data == null) {
//                     return Center(child: Text('No data available'));
//                   }
//                   var snap = snapshot.data;

//                   return Column(
//                     children: [
//                       Center(
//                         child: Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child:
//                               snap['image'] != null && snap['image'].isNotEmpty
//                                   ? CircleAvatar(
//                                       backgroundImage: NetworkImage(
//                                         snap['image'],
//                                       ),
//                                       radius: 60,
//                                     )
//                                   : CircleAvatar(
//                                       radius: 60,
//                                       child: Icon(Icons.person, size: 60),
//                                     ),
//                         ),
//                       ),
//                       Text(
//                         snap['fullName'],
//                         style: GoogleFonts.workSans(
//                             fontWeight: FontWeight.w900, fontSize: 22),
//                       ),
//                     ],
//                   );
//                 }),
//             const SizedBox(
//               height: 10,
//             ),
//             Padding(
//               padding: const EdgeInsets.only(left: 8.0, right: 8, top: 8),
//               child: Text(
//                 "Ofertas recientes",
//                 style: GoogleFonts.inter(
//                     fontWeight: FontWeight.w700, fontSize: 15),
//               ),
//             ),
//             SizedBox(
//               height: 500,
//               child: StreamBuilder(
//                   stream: FirebaseFirestore.instance
//                       .collection("offers")
//                       .where("serviceProviderId",
//                           isEqualTo: FirebaseAuth.instance.currentUser!.uid)
//                       .where("status", isEqualTo: "send")
//                       .snapshots(),
//                   builder: (context, snapshot) {
//                     if (!snapshot.hasData) {
//                       return const Center(
//                         child: CircularProgressIndicator(),
//                       );
//                     }
//                     if (snapshot.data!.docs.isEmpty) {
//                       return Center(
//                         child: Text(
//                           "No hay ofertas disponibles",
//                           style: TextStyle(color: colorBlack),
//                         ),
//                       );
//                     }
//                     return ListView.builder(
//                         itemCount: snapshot.data!.docs.length,
//                         itemBuilder: (context, index) {
//                           final List<DocumentSnapshot> documents =
//                               snapshot.data!.docs;
//                           final Map<String, dynamic> data =
//                               documents[index].data() as Map<String, dynamic>;
//                           return GestureDetector(
//                             onTap: () {
//                               Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                       builder: (builder) => OfferDetail(
//                                             clientName: data['clientName'],
//                                             clientEmail: data['clientEmail'],
//                                             clientId: data['clientId'],
//                                             clientImage: data['clientImage'],
//                                             status: data['status'],
//                                             totalRating:
//                                                 data['totalRating'].toString(),
//                                             providerEmail:
//                                                 data['providerEmail'],
//                                             providerImage:
//                                                 data['providerImage'],
//                                             providerName: data['providerName'],
//                                             priceprehr: data['pricePerHr']
//                                                 .toString()
//                                                 .toString(),
//                                             work: data['work'],
//                                             serviceDescription:
//                                                 data['serviceDescription'],
//                                             price: data['price'].toString(),
//                                             serviceProviderId:
//                                                 data['serviceProviderId'],
//                                             uuid: data['uuid'],
//                                             serviceTitle: data['serviceTitle'],
//                                           )));
//                             },
//                             child: Card(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   GestureDetector(
//                                     onTap: () {},
//                                     child: ListTile(
//                                       trailing: Text(
//                                         "${getCurrencySymbol(data['currencyType'] ?? 'Euro')}${data['price'] ?? '0.0'}",
//                                         style: GoogleFonts.inter(
//                                           fontWeight: FontWeight.bold,
//                                           fontSize: 20,
//                                         ),
//                                       ),
//                                       leading: CircleAvatar(
//                                         backgroundImage:
//                                             NetworkImage(data['clientImage']),
//                                       ),
//                                       title: Text(
//                                         data['clientName'],
//                                         style: GoogleFonts.inter(
//                                             fontWeight: FontWeight.bold,
//                                             fontSize: 16),
//                                       ),
//                                     ),
//                                   ),
//                                   Padding(
//                                     padding: const EdgeInsets.all(8.0),
//                                     child: Text(
//                                       "Descripciones de puestos de trabajo",
//                                       style: GoogleFonts.inter(
//                                           fontWeight: FontWeight.bold,
//                                           fontSize: 16),
//                                     ),
//                                   ),
//                                   Padding(
//                                     padding: const EdgeInsets.all(8.0),
//                                     child: Text(
//                                       data['work'],
//                                       style: GoogleFonts.inter(
//                                           fontWeight: FontWeight.w500,
//                                           fontSize: 13),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           );
//                         });
//                   }),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
