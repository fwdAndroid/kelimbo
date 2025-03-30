import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kelimbo/utils/colors.dart';
import 'package:url_launcher/url_launcher.dart';

class PremiumFeature extends StatefulWidget {
  @override
  _PremiumFeatureState createState() => _PremiumFeatureState();
}

class _PremiumFeatureState extends State<PremiumFeature> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String userId = FirebaseAuth.instance.currentUser!.uid;
  String membership = "basic"; // Changed from subscription to membership
  DateTime? membershipExpiry; // Changed from subscriptionExpiry
  int shareCount = 0;
  bool isSharing = false;

  @override
  void initState() {
    super.initState();
    fetchMembershipData();
  }

  Future<void> fetchMembershipData() async {
    try {
      var userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        var data = userDoc.data();
        setState(() {
          membership =
              data?['membership'] ?? "basic"; // Using your existing field
          membershipExpiry = data?['membershipExpiry'] != null
              ? DateTime.parse(data?['membershipExpiry'])
              : null;
          shareCount = data?['shareCount'] ?? 0;
        });
        checkMembershipExpiration();
      }
    } catch (e) {
      print("Error fetching membership data: $e");
    }
  }

  void checkMembershipExpiration() async {
    if (membershipExpiry != null && DateTime.now().isAfter(membershipExpiry!)) {
      await _firestore.collection('users').doc(userId).update({
        'membership': 'basic', // Using your existing field
        'membershipExpiry': null,
      });
      setState(() {
        membership = 'basic';
        membershipExpiry = null;
      });
    }
  }

  Future<void> shareOnWhatsApp() async {
    setState(() {
      isSharing = true;
    });

    String message =
        "Estoy usando una nueva aplicación que te va a interesar, se llama Kelimbo. Descárgatela aquí (enlace de descarga de la aplicación) o encuentra más información aquí: https://play.google.com/store  https://www.apple.com/app-store/";

    String whatsappUrl = "whatsapp://send?text=${Uri.encodeComponent(message)}";

    try {
      if (await canLaunch(whatsappUrl)) {
        await launch(whatsappUrl);
        // Assume user shared with 20 contacts
        await updateShareCount(20);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("WhatsApp no está instalado en este dispositivo.")),
        );
      }
    } catch (e) {
      print("Error sharing: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al compartir")),
      );
    } finally {
      setState(() {
        isSharing = false;
      });
    }
  }

  Future<void> updateShareCount(int count) async {
    int newShareCount = shareCount + count;

    await _firestore.collection('users').doc(userId).update({
      'shareCount': newShareCount,
    });

    setState(() {
      shareCount = newShareCount;
    });

    if (newShareCount >= 20) {
      await unlockPremiumMembership();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("¡Felicidades! Has desbloqueado el nivel PREMIUM")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                "Compartido con $count contactos. Necesitas compartir con ${20 - newShareCount} más para desbloquear PREMIUM.")),
      );
    }
  }

  Future<void> unlockPremiumMembership() async {
    DateTime expiryDate = DateTime.now().add(Duration(days: 60));
    await _firestore.collection('users').doc(userId).update({
      'membership': 'premium', // Using your existing field
      'membershipExpiry': expiryDate.toIso8601String(),
    });

    setState(() {
      membership = 'premium';
      membershipExpiry = expiryDate;
    });
  }

  void showUpgradeMessage() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Actualizar a Premium"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  "Para desbloquear PREMIUM, comparte la aplicación con 20 contactos en WhatsApp."),
              SizedBox(height: 10),
              if (shareCount > 0) Text("Progreso: $shareCount/20"),
              SizedBox(height: 10),
              if (shareCount > 0)
                LinearProgressIndicator(
                  value: shareCount / 20,
                ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                shareOnWhatsApp();
              },
              child: isSharing
                  ? CircularProgressIndicator()
                  : Text("Compartir con 20 contactos"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Suscripción a Kelimbo"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset("assets/logo.png", height: 100),
              SizedBox(height: 20),
              Text(
                "Tu plan actual: ${membership.toUpperCase()}",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              if (membershipExpiry != null)
                Text(
                  "Válido hasta: ${membershipExpiry!.toLocal().toString().split(' ')[0]}",
                  style: TextStyle(fontSize: 16),
                ),
              SizedBox(height: 20),
              buildMembershipBenefits(),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: membership == 'premium' ? null : showUpgradeMessage,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  backgroundColor: membership == 'premium'
                      ? Colors.grey
                      : Theme.of(context).primaryColor,
                ),
                child: Text(
                  membership == 'premium'
                      ? "PREMIUM DESBLOQUEADO"
                      : "USAR FUNCIÓN PREMIUM",
                  style: TextStyle(fontSize: 16, color: colorWhite),
                ),
              ),
              SizedBox(height: 20),
              if (shareCount > 0 && shareCount < 20)
                Column(
                  children: [
                    Text("Progreso hacia PREMIUM: $shareCount/20"),
                    SizedBox(height: 10),
                    LinearProgressIndicator(
                      value: shareCount / 20,
                    ),
                  ],
                ),
              if (membership == 'premium')
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "¡Disfruta de todas las funciones premium!",
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildMembershipBenefits() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Table(
          columnWidths: {
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(1),
            2: FlexColumnWidth(1),
          },
          children: [
            TableRow(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey)),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text('¿Qué incluye?',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'BASIC',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'PREMIUM',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            buildTableRow(
              'Publica todos los anuncios que quieras',
              'Sólo 1 anuncio',
              true,
            ),
            buildTableRow(
              'Disfruta de la experiencia sin publicidad',
              false,
              true,
            ),
            buildTableRow(
              'Contesta a los mensajes en el chat',
              false,
              true,
            ),
            buildTableRow(
              'Responde a las solicitudes de presupuesto',
              false,
              true,
            ),
            buildTableRow(
              'Recibe valoraciones de tus clientes',
              false,
              true,
            ),
            buildTableRow(
              'Tus clientes podrán marcar tus trabajos como completados',
              false,
              true,
            ),
          ],
        ),
      ),
    );
  }

  TableRow buildTableRow(
      String feature, dynamic basicValue, dynamic premiumValue) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(feature),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: basicValue is bool
                ? Icon(basicValue ? Icons.check : Icons.close,
                    color: basicValue ? Colors.green : Colors.red)
                : Text(basicValue.toString()),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: premiumValue is bool
                ? Icon(premiumValue ? Icons.check : Icons.close,
                    color: premiumValue ? Colors.green : Colors.red)
                : Text(premiumValue.toString()),
          ),
        ),
      ],
    );
  }
}
