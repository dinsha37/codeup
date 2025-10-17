import 'package:codeup/features/auth/view/skillqn_screen.dart';
import 'package:flutter/material.dart';

class TesticonScreen extends StatefulWidget {
  const TesticonScreen({super.key});

  @override
  State<TesticonScreen> createState() => _TesticonScreenState();
} // testicon_screen.dart

class _TesticonScreenState extends State<TesticonScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // No image, only text and button
              SizedBox(height: 40),
              Text(
                "Test your skills and we'll place you in the right level!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  height: 1.3,
                ),
              ),
              SizedBox(height: 50),
              ElevatedButton(
                onPressed: () {
                  // Handle "Let's Go" button press
                  print("Let's Go button pressed!");
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SkillqnScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 18,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 8,
                ),
                child: const Text(
                  "Let's Go",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
