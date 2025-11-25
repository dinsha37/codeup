import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CodingfocusScreen extends StatefulWidget {
  const CodingfocusScreen({super.key});

  @override
  State<CodingfocusScreen> createState() => _CodingfocusScreenState();
}

class _CodingfocusScreenState extends State<CodingfocusScreen> {
  String? selectedLanguage;

  final List<Map<String, dynamic>> languages = [
    {"name": "Java", "icon": Icons.coffee, "color": Colors.brown},
    {"name": "Python", "icon": Icons.code, "color": Colors.blue},
    {"name": "C++", "icon": Icons.memory, "color": Colors.indigo},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: const Text(
          "Coding Focus",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Choose your language",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            ),
          ),

          const SizedBox(height: 16),

          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
              ),
              itemCount: languages.length,
              itemBuilder: (context, index) {
                return _LanguageCard(
                  name: languages[index]["name"],
                  icon: languages[index]["icon"],
                  color: languages[index]["color"],
                  onTap: () {
                    setState(() {
                      selectedLanguage = languages[index]["name"];
                    });
                  },
                );
              },
            ),
          ),

          // Bottom detail section (only appears when language is selected)
          if (selectedLanguage != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black,
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    selectedLanguage!,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "Focus on improving your ${selectedLanguage!} skills.",
                    style: const TextStyle(fontSize: 16),
                  ),

                  const SizedBox(height: 16),

                  ElevatedButton(
                    onPressed: () {},
                    child: const Text("Start Learning"),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  final String name;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _LanguageCard({
    required this.name,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 10),
            Text(
              name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
