import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kelimbo/screens/main/pages/add_service_page.dart';
import 'package:kelimbo/screens/main/pages/chat_page.dart';
import 'package:kelimbo/screens/main/pages/favourite_page.dart';
import 'package:kelimbo/screens/main/pages/home_page.dart';
import 'package:kelimbo/screens/main/pages/profile_page.dart';
import 'package:kelimbo/utils/colors.dart';

class MainDashboard extends StatefulWidget {
  @override
  _MainDashboardState createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    HomePage(),
    FavouritePage(),
    AddServicePage(),
    ChatPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          final shouldPop = await _showExitDialog(context);
          return shouldPop ?? false;
        },
        child: Scaffold(
          body: _screens[_currentIndex],
          bottomNavigationBar: BottomNavigationBar(
            selectedLabelStyle: TextStyle(color: mainColor),
            unselectedLabelStyle: TextStyle(color: iconColor),
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            items: [
              BottomNavigationBarItem(
                icon: Image.asset(
                  height: 27,
                  width: 27,
                  _currentIndex == 0
                      ? "assets/home_blue.png"
                      : "assets/home_grey.png",
                ),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  height: 27,
                  width: 27,
                  _currentIndex == 1
                      ? "assets/fav_blue.png"
                      : "assets/fav_grey.png",
                ),
                label: 'Doctor',
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  height: 27,
                  width: 27,
                  _currentIndex == 2
                      ? "assets/add_blue.png"
                      : "assets/add_grey.png",
                ),
                label: 'Medicine',
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  height: 27,
                  width: 27,
                  _currentIndex == 3
                      ? "assets/chat_blue.png"
                      : "assets/chat_grey.png",
                ),
                label: 'Appointment',
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  height: 27,
                  width: 27,
                  _currentIndex == 4
                      ? "assets/person_blue.png"
                      : "assets/person_grey.png",
                ),
                label: 'History',
              ),
            ],
          ),
        ));
  }

  _showExitDialog(BuildContext context) {
    Future<bool?> _showExitDialog(BuildContext context) {
      return showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Exit App'),
          content: Text('Do you want to exit the app?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Yes'),
            ),
          ],
        ),
      );
    }
  }
}
