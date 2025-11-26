import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TermsScreen extends StatefulWidget {
  const TermsScreen({super.key});

  @override
  State<TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
        title: const Text("Terms of Service"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "Terms of Service",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),

            Text(
              "By using this app, you agree to the following terms:\n\n"

              "1. Usage Rules:\n"
              "   • You must use the app responsibly.\n"
              "   • Do not engage in illegal or abusive behavior.\n\n"

              "2. Content Ownership:\n"
              "   • All challenges, UI elements, and learning materials belong to the app creators.\n\n"

              "3. Account Responsibilities:\n"
              "   • Keep your login information safe.\n"
              "   • You are responsible for activities under your account.\n\n"

              "4. Liability:\n"
              "   • We are not responsible for data loss due to device issues.\n\n"

              "5. Updates:\n"
              "   • App features may change in future versions.\n\n"

              "6. Termination:\n"
              "   • Accounts may be suspended if terms are violated.\n\n"

              "Thank you for using our app.",
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
