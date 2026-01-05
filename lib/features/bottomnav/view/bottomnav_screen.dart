import 'package:codeup/features/auth/view/certificates_screen.dart';
import 'package:codeup/features/auth/view/freelance_screen.dart';
import 'package:codeup/features/levels/level_screen.dart';
import 'package:codeup/features/auth/view/settings_screen.dart';
import 'package:flutter/material.dart';

import '../../home/view/home_screen.dart';

class BottomnavScreen extends StatefulWidget {
  const BottomnavScreen({super.key});

  @override
  State<BottomnavScreen> createState() => _BottomnavScreenState();
}

class _BottomnavScreenState extends State<BottomnavScreen> {
  int selectedindex = 0;
  List pages =[];
  @override
  void initState() {
     pages = [
    HomeScreen(onnavigateCerti: () {
      selectedindex = 2;
      setState(() {
        
      });
    },onnavigateLevels: () {
      selectedindex = 1;
      setState(() {
        
      });
    },),
    UserLevelScreen(),
    CertificatesScreen(),
    FreelanceScreen(),
    SettingsScreen(),
  ];
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages.elementAt(selectedindex),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white.withValues(alpha:0.95),
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.blueGrey,
        currentIndex: selectedindex,
        onTap: (index) {
          selectedindex = index;
          setState(() {});
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timer_outlined),
            activeIcon: Icon(Icons.timer_rounded),
            label: 'Levels',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.badge_outlined),
            activeIcon: Icon(Icons.badge),
            label: 'Certificates',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work_outlined),
            activeIcon: Icon(Icons.work),
            label: 'freelance',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'settings',
          ),
        ],
      ),
    );
  }
}
