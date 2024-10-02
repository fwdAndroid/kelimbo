import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kelimbo/screens/profile_pages/completed_jobs.dart';
import 'package:kelimbo/screens/profile_pages/edit_profile.dart';
import 'package:kelimbo/screens/profile_pages/jobs_hired.dart';
import 'package:kelimbo/screens/profile_pages/recent_works.dart';
import 'package:kelimbo/screens/services/my_services.dart';
import 'package:kelimbo/utils/colors.dart';
import 'package:kelimbo/widgets/delete_widgets.dart';
import 'package:kelimbo/widgets/logout_widget.dart';
import 'package:kelimbo/widgets/save_button.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("users")
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .snapshots(),
                  builder: (context, AsyncSnapshot snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data == null) {
                      return Center(child: Text('No data available'));
                    }
                    var snap = snapshot.data;

                    return Column(
                      children: [
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: snap['image'] != null &&
                                    snap['image'].isNotEmpty
                                ? CircleAvatar(
                                    backgroundImage: NetworkImage(
                                      snap['image'],
                                    ),
                                    radius: 60,
                                  )
                                : CircleAvatar(
                                    radius: 60,
                                    child: Icon(Icons.person, size: 60),
                                  ),
                          ),
                        ),
                        Text(
                          snap['fullName'],
                          style: GoogleFonts.workSans(
                              fontWeight: FontWeight.w900, fontSize: 22),
                        ),
                      ],
                    );
                  }),
              const SizedBox(
                height: 8,
              ),
              ListTile(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (builder) => EditProfile()));
                },
                title: Text(
                  "Ver perfil",
                  style: GoogleFonts.workSans(
                      fontWeight: FontWeight.w500, fontSize: 16),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  color: colorBlack,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8),
                child: Divider(
                  color: iconColor,
                ),
              ),
              ListTile(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (builder) => MyServices()));
                },
                title: Text(
                  "Mis servicios",
                  style: GoogleFonts.workSans(
                      fontWeight: FontWeight.w500, fontSize: 16),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  color: colorBlack,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8),
                child: Divider(
                  color: iconColor,
                ),
              ),
              ListTile(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (builder) => RecentWorks()));
                },
                title: Text(
                  "Realiza una oferta",
                  style: GoogleFonts.workSans(
                      fontWeight: FontWeight.w500, fontSize: 16),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  color: colorBlack,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8),
                child: Divider(
                  color: iconColor,
                ),
              ),
              // ListTile(
              //   onTap: () {
              //     Navigator.push(context,
              //         MaterialPageRoute(builder: (builder) => JobsBudget()));
              //   },
              //   title: Text(
              //     "Jobs to be Budgeted",
              //     style: GoogleFonts.workSans(
              //         fontWeight: FontWeight.w500, fontSize: 16),
              //   ),
              //   trailing: Icon(
              //     Icons.arrow_forward_ios,
              //     color: colorBlack,
              //   ),
              // ),
              // Padding(
              //   padding: const EdgeInsets.only(left: 8.0, right: 8),
              //   child: Divider(
              //     color: iconColor,
              //   ),
              // ),
              ListTile(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (builder) => JobsHired()));
                },
                title: Text(
                  "Trabajos contratados por mí",
                  style: GoogleFonts.workSans(
                      fontWeight: FontWeight.w500, fontSize: 16),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  color: colorBlack,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8),
                child: Divider(
                  color: iconColor,
                ),
              ),
              ListTile(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (builder) => CompletedJobs()));
                },
                title: Text(
                  "Trabajos completados",
                  style: GoogleFonts.workSans(
                      fontWeight: FontWeight.w500, fontSize: 16),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  color: colorBlack,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8),
                child: Divider(
                  color: iconColor,
                ),
              ),
              ListTile(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return DeleteAlertWidget();
                    },
                  );
                },
                title: Text(
                  "Eliminar cuenta",
                  style: GoogleFonts.workSans(
                      fontWeight: FontWeight.w500, fontSize: 16),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  color: colorBlack,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8),
                child: Divider(
                  color: iconColor,
                ),
              ),
              ListTile(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return LogoutWidget();
                    },
                  );
                },
                title: Text(
                  "Salir ",
                  style: GoogleFonts.workSans(
                      fontWeight: FontWeight.w500, fontSize: 16),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  color: colorBlack,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8),
                child: Divider(
                  color: iconColor,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SaveButton(
                    title: "Cerrar sesión",
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return LogoutWidget();
                        },
                      );
                    }),
              )
            ],
          ),
        ),
      ),
    );
  }
}
