import 'dart:io';
import 'package:azkar_admin/screens/main/azkar_page.dart';
import 'package:azkar_admin/screens/main/dua_page.dart';
import 'package:azkar_admin/screens/main/setting_page.dart';
import 'package:azkar_admin/widget/arabic_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MainDashboard extends StatefulWidget {
  final int initialPageIndex; // new

  const MainDashboard({super.key, this.initialPageIndex = 0});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    AzkarPage(), // Replace with your screen widgets
    DuaPage(),
    SettingPage(),
  ];
  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialPageIndex;
  }

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
          backgroundColor: Color(0xff097132),
          selectedItemColor: Colors.white,
          selectedLabelStyle: TextStyle(color: Colors.white),
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: _currentIndex == 0
                  ? Image.asset(
                      "assets/moon_14181732.png",
                      width: 25,
                      height: 25,
                    )
                  : Image.asset(
                      "assets/moon_14181732.png",
                      width: 25,
                      height: 25,
                    ),
              label: 'Azkar',
            ),

            BottomNavigationBarItem(
              label: "Dua's",
              icon: _currentIndex == 1
                  ? Image.asset(
                      "assets/prayer_12477451.png",
                      width: 25,
                      height: 25,
                    )
                  : Image.asset(
                      "assets/prayer_12477451.png",
                      width: 25,
                      height: 25,
                    ),
            ),

            BottomNavigationBarItem(
              label: "Settings",
              icon: _currentIndex == 2
                  ? Image.asset("assets/setting.png", width: 25, height: 25)
                  : Image.asset("assets/setting.png", width: 25, height: 25),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _showExitDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: ArabicText('Exit App'),
        content: ArabicText('Do you want to exit the app?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('No'),
          ),
          TextButton(
            onPressed: () {
              if (Platform.isAndroid) {
                SystemNavigator.pop(); // For Android
              } else if (Platform.isIOS) {
                exit(0); // For iOS
              }
            },
            child: ArabicText('Yes'),
          ),
        ],
      ),
    );
  }
}
