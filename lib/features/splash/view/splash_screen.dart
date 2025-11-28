import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codeup/features/admin/admin_dashboard.dart';
import 'package:codeup/features/bottomnav/view/bottomnav_screen.dart';
import 'package:flutter/material.dart';
import 'package:codeup/features/auth/view/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../utils/variables/global_variables.dart';
import '../../auth/model/user_model.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // Wait for 3 seconds to show splash screen
    await Future.delayed(Duration(seconds: 3));

    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Check if user is logged in
      final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      final uid = prefs.getString('uid');
      final email = prefs.getString('email');

      if (!isLoggedIn || uid == null || email == null) {
        // User not logged in, navigate to Login Screen
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
            (route) => false,
          );
        }
        return;
      }

      // User is logged in, verify account status in Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(uid)
          .get();
          

      if (!userDoc.exists) {
        // User document doesn't exist, clear preferences and go to login
        await prefs.clear();
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
            (route) => false,
          );
        }
        return;
      }

      // Check user status
      final userData = userDoc.data()!;
      final status = userData['status'] as int;

      if (status == 0) {
        // Account is blocked, clear preferences and show message
        await prefs.clear();
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
            (route) => false,
          );
          
          // Show blocked message after navigation
          Future.delayed(Duration(milliseconds: 500), () {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Your account has been blocked. Please contact support.'),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 4),
                ),
              );
            }
          });
        }
        return;
      } else if (status == -1) {
        // Account was deleted, clear preferences and show message
        await prefs.clear();
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
            (route) => false,
          );
          
          // Show deleted account message after navigation
          Future.delayed(Duration(milliseconds: 500), () {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Your account was deleted. Please sign up again.'),
                  backgroundColor: Colors.orange,
                  duration: Duration(seconds: 4),
                ),
              );
            }
          });
        }
        return;
      }

      // Status is 1 (Active), navigate based on user type
      if (mounted) {
        final userModel = UserModel.fromJson(userDoc.data()!);
         globalUser = userModel;
        if (email == 'admin@gmail.com') {
          
         
          // Navigate to Admin Dashboard
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => AdminDashboard()),
            (route) => false,
          );
        } else {

          // Navigate to User Home Screen
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => BottomnavScreen()),
            (route) => false,
          );
        }
      }
    } catch (e) {
      // If any error occurs, clear preferences and go to login
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(color: Colors.white),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/codeup.png', width: 200, height: 200),
            SizedBox(height: 30),
            // Loading indicator
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ],
        ),
      ),
    );
  }
}