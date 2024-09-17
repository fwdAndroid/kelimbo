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
                icon: Icon(
                  Icons.home,
                  color: _currentIndex == 0 ? mainColor : iconColor,
                ),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.favorite,
                  color: _currentIndex == 1 ? mainColor : iconColor,
                ),
                label: 'Doctor',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.add_circle_outline_outlined,
                  color: _currentIndex == 2 ? mainColor : iconColor,
                ),
                label: 'Medicine',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.chat_bubble,
                  color: _currentIndex == 3 ? mainColor : iconColor,
                ),
                label: 'Appointment',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.person_outline,
                  color: _currentIndex == 4 ? mainColor : iconColor,
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
