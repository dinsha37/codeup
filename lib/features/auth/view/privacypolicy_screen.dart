import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PrivacypolicyScreen extends StatefulWidget {
  const PrivacypolicyScreen({super.key});

  @override
  State<PrivacypolicyScreen> createState() => _PrivacypolicyScreenState();
}

class _PrivacypolicyScreenState extends State<PrivacypolicyScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        title: const Text("Privacy Policy"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "Privacy Policy",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),

            Text(
              "We are committed to protecting your personal information. "
              "This Privacy Policy explains how your data is collected, used, and kept secure.\n\n"

              "1. Information We Collect:\n"
              "   • Basic profile info\n"
              "   • App usage details\n"
              "   • Challenge progress\n\n"

              "2. How We Use It:\n"
              "   • Improve learning suggestions\n"
              "   • Track your progress\n"
              "   • Provide a personalized experience\n\n"

              "3. Data Sharing:\n"
              "   • We do NOT sell or share your data with third parties.\n\n"

              "4. Security:\n"
              "   • Your data is stored securely using encryption.\n\n"

              "5. Your Choices:\n"
              "   • You can request deletion of your data at any time.\n\n"

              "For any concerns, contact our support team.",
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}