import 'package:codeup/mcq_qustions/questions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LevelScreen extends StatefulWidget {
  const LevelScreen({super.key});

  @override
  State<LevelScreen> createState() => _LevelScreenState();

  // Data structure for the levels
  final List<Map<String, dynamic>> levels = const [
    {'levelNumber': 1, 'questionCount': 5},
    {'levelNumber': 2, 'questionCount': 5},
    {'levelNumber': 3, 'questionCount': 5},
  ];
}

class _LevelScreenState extends State<LevelScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select a Level 🏆'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            // Use Column to center the content or add other elements
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Choose your challenge:',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              // GridView for a more engaging, spaced-out layout
              Expanded(
                child: ListView.builder(
                  // Prevent the GridView from scrolling independently
                  itemCount: widget.levels.length,
                  itemBuilder: (context, index) {
                    final level = widget.levels[index];
                    final levelNumber = level['levelNumber'] as int;
                    final levelName = 'Level $levelNumber';
                    return LevelCard(
                      levelNumber: levelNumber,
                      levelName: levelName,
                      questionCount: level['questionCount'] as int,
                      onTap: () {
                        // Action to perform when a level is tapped
                        // _navigateToLevel(context, levelNumber, levelName);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QuestionScreen(
                              levelNumber: 1,
                              language: 'Python',
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToLevel(
    BuildContext context,
    int levelNumber,
    String levelName,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Starting Level $levelNumber: $levelName Quiz...'),
        duration: const Duration(seconds: 1),
      ),
    );
    // In a real app, you would use Navigator.push() here
    // Navigator.push(context, MaterialPageRoute(builder: (context) => QuizScreen(level: levelNumber)));
  }
}

// Custom widget for a single level button/card
class LevelCard extends StatelessWidget {
  final int levelNumber;
  final String levelName;
  final int questionCount;
  final VoidCallback onTap;

  const LevelCard({
    super.key,
    required this.levelNumber,
    required this.levelName,
    required this.questionCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        // Rounded corners and elevation for a nice look
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        color:
            Colors.lightBlue[100 * levelNumber], // Different shades for levels
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              colors: [Colors.blue[200]!, Colors.blue[400]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'LEVEL $levelNumber',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          blurRadius: 3,
                          color: Colors.black45,
                          offset: Offset(1, 1),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.quiz, color: Colors.white, size: 18),
                      const SizedBox(width: 5),
                      Text(
                        '$questionCount Questions',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ],
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
