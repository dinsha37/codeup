import 'package:codeup/features/auth/view/testicon_screen.dart';
import 'package:flutter/material.dart';

class ReadyforiqScreen extends StatefulWidget {
  const ReadyforiqScreen({super.key});

  @override
  State<ReadyforiqScreen> createState() => _ReadyforiqScreenState();
}

class _ReadyforiqScreenState extends State<ReadyforiqScreen> {
  String? selectedLanguage;

  final List<String> languages = ['Python', 'JavaScript', 'C++'];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Use a gradient for a more dynamic background
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white, // A vibrant primary color
              Colors.blue, // A lighter secondary color
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            // Use a card-like container for the main content
            child: Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Stylish heading with clear font weight
                  const Text(
                    "Pick a language to start coding!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600, // Semi-bold for emphasis
                      color: Color(0xFF333333), // Darker text for readability
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Stylish dropdown with a border and icon
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFFCCCCCC),
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: selectedLanguage,
                        hint: const Text(
                          '-- Select --',
                          style: TextStyle(color: Color(0xFF888888)),
                        ),
                        icon: const Icon(
                          Icons.arrow_drop_down,
                          color: Colors.black87,
                        ),
                        items: languages.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            selectedLanguage = newValue;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // A more prominent and stylish ElevatedButton
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: selectedLanguage == null
                          ? null
                          : () {
                              print("Starting with $selectedLanguage");
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TesticonScreen(),
                                ),
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selectedLanguage == null
                            ? Colors
                                  .grey // Disabled state color
                            : Colors.blueAccent, // A primary button color
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 5, // Adds a subtle shadow
                      ),
                      child: const Text(
                        "Start",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
