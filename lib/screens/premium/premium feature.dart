import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class PremiumFeature extends StatefulWidget {
  @override
  _PremiumFeatureState createState() => _PremiumFeatureState();
}

class _PremiumFeatureState extends State<PremiumFeature> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String userId = FirebaseAuth.instance.currentUser!.uid;
  String subscription = "basic";
  DateTime? subscriptionExpiry;
  int shareCount = 0;

  @override
  void initState() {
    super.initState();
    fetchSubscriptionData();
  }

  // Fetch user subscription data from Firestore
  Future<void> fetchSubscriptionData() async {
    var userDoc = await _firestore.collection('users').doc(userId).get();
    var data = userDoc.data();
    setState(() {
      subscription = data?['subscription'] ?? "basic";
      subscriptionExpiry = data?['subscriptionExpiry'] != null
          ? DateTime.parse(data?['subscriptionExpiry'])
          : null;
      shareCount = data?['shareCount'] ?? 0;
    });

    checkSubscriptionExpiration();
  }

  // Check if subscription has expired
  void checkSubscriptionExpiration() async {
    if (subscriptionExpiry != null &&
        DateTime.now().isAfter(subscriptionExpiry!)) {
      // Downgrade to basic if subscription has expired
      await _firestore.collection('users').doc(userId).update({
        'subscription': 'basic',
      });
      setState(() {
        subscription = 'basic';
      });
    }
  }

  // Share message on WhatsApp to unlock PRO
  Future<void> shareOnWhatsApp() async {
    String message =
        "Estoy usando una nueva aplicación que te va a interesar, se llama Kelimbo. Descárgatela aquí (enlace de descarga de la aplicación) o encuentra más información aquí (enlace a la página web)";
    String whatsappUrl = "whatsapp://send?text=${Uri.encodeComponent(message)}";

    if (await canLaunch(whatsappUrl)) {
      await launch(whatsappUrl);
      // After sharing on WhatsApp, update share count
      updateShareCount();
    } else {
      // Redirect to Play Store or App Store if WhatsApp is not installed
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                "WhatsApp no está instalado en este dispositivo. Redireccionamiento a la instalación.")),
      );

      String playStoreUrl =
          "https://play.google.com/store/apps/details?id=com.whatsapp";
      if (await canLaunch(playStoreUrl)) {
        await launch(playStoreUrl);
      }
    }
  }

  // Update share count in Firestore
  Future<void> updateShareCount() async {
    setState(() {
      shareCount += 5; // WhatsApp limits to 5 shares per action
    });

    await _firestore.collection('users').doc(userId).update({
      'shareCount': shareCount,
    });

    // Check if 20 shares (4 rounds) are completed for PRO unlock
    if (shareCount >= 20) {
      unlockProSubscription();
    }
  }

  // Unlock PRO subscription for 2 months
  Future<void> unlockProSubscription() async {
    DateTime expiryDate = DateTime.now().add(Duration(days: 60)); // 2 months
    await _firestore.collection('users').doc(userId).update({
      'subscription': 'pro',
      'subscriptionExpiry': expiryDate.toIso8601String(),
    });

    setState(() {
      subscription = 'pro';
      subscriptionExpiry = expiryDate;
    });
  }

  // Show upgrade message when user attempts to access premium feature
  void showUpgradeMessage() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Actualizar a Premium"),
          content: Text(
              "Esta función requiere una suscripción premium. Comparte la aplicación para desbloquear el nivel PRO."),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                shareOnWhatsApp();
              },
              child: Text("Compartir en WhatsApp"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancelar"),
            ),
          ],
        );
      },
    );
  }

  // Build UI
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
              Image.asset("assets/logo.png"),
              Text("Subscription: $subscription"),
              if (subscriptionExpiry != null)
                Text("Expires on: ${subscriptionExpiry!.toLocal()}"),
              SizedBox(height: 10),
              buildSubscriptionBenefits(),
              ElevatedButton(
                onPressed: subscription == "basic" ? showUpgradeMessage : null,
                child: Text("Usar la función Premium"),
              ),
              if (shareCount >= 20)
                Text(
                    "¡Has desbloqueado el nivel PRO! Disfruta de funciones premium."),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSubscriptionBenefits() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Beneficios de la suscripción",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Text(
          "BÁSICO (Gratis):",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text("- Puede publicar hasta 1 anuncio al año.."),
        Text("- Los anuncios serán visibles."),
        Text(
            "- en el básico pueden leer los mensajes que reciben, pero no pueden contestar "),
        Text("- El acceso al botón Trabajo completado está inactivo."),
        Text(
            "- Puede recibir solicitudes de servicios, pero no puede enviar presupuestos."),
        SizedBox(height: 10),
        Text(
          "PREMIUM (Compartiendo):",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text("- Puede publicar anuncios ilimitados al año."),
        Text("- Experiencia sin anuncios."),
        Text(
            "- Capacidad para ver los mensajes recibidos y chatear con los clientes."),
        Text(
            "- Puede ver y recibir valoraciones y comentarios de los usuarios."),
        Text(
            "- El acceso al botón Trabajo completado está completamente habilitado'"),
        Text(
            "- Puede proporcionar presupuestos y enviar respuestas detalladas a las solicitudes de servicios."),
      ],
    );
  }
}
