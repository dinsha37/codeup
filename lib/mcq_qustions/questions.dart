import 'package:flutter/material.dart';

class QuestionScreen extends StatefulWidget {
  final int levelNumber;
  final String language;

  const QuestionScreen({
    super.key,
    required this.levelNumber,
    required this.language,
  });

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  int _currentQuestionIndex = 0;
  List<int?> _selectedAnswers = [];
  int _score = 0;
  bool _quizCompleted = false;

  // Sample questions database - In real app, this would come from API/Firebase
  final Map<String, Map<int, List<Question>>> _questionsDatabase = {
    'Python': {
      1: [
        Question(
          question: 'What is the output of: print(2 + 3 * 2)',
          options: ['10', '8', '7', '12'],
          correctAnswerIndex: 1,
          explanation: 'Multiplication has higher precedence than addition.',
        ),
        Question(
          question: 'Which keyword is used to define a function in Python?',
          options: ['function', 'def', 'define', 'func'],
          correctAnswerIndex: 1,
          explanation: 'The "def" keyword is used to define functions in Python.',
        ),
        Question(
          question: 'What does len() function do?',
          options: [
            'Returns the length of a string',
            'Returns the type of variable',
            'Converts to lowercase',
            'Prints the value'
          ],
          correctAnswerIndex: 0,
          explanation: 'len() returns the number of items in an object.',
        ),
        Question(
          question: 'How do you create a list in Python?',
          options: [
            'list = (1, 2, 3)',
            'list = [1, 2, 3]',
            'list = {1, 2, 3}',
            'list = <1, 2, 3>'
          ],
          correctAnswerIndex: 1,
          explanation: 'Lists are created using square brackets [].',
        ),
        Question(
          question: 'What is the correct way to comment in Python?',
          options: [
            '// This is a comment',
            '/* This is a comment */',
            '# This is a comment',
            '-- This is a comment'
          ],
          correctAnswerIndex: 2,
          explanation: 'Python uses # for single-line comments.',
        ),
      ],
      2: [
        Question(
          question: 'What does the "self" parameter represent in Python class methods?',
          options: [
            'The class itself',
            'The instance of the class',
            'A static method',
            'A private variable'
          ],
          correctAnswerIndex: 1,
          explanation: 'self refers to the instance of the class.',
        ),
        Question(
          question: 'How do you handle exceptions in Python?',
          options: [
            'try-catch block',
            'try-except block',
            'error-handle block',
            'exception block'
          ],
          correctAnswerIndex: 1,
          explanation: 'Python uses try-except for exception handling.',
        ),
        Question(
          question: 'What is a lambda function in Python?',
          options: [
            'A large function with multiple parameters',
            'An anonymous function',
            'A function that returns lambda',
            'A built-in function'
          ],
          correctAnswerIndex: 1,
          explanation: 'Lambda functions are small anonymous functions.',
        ),
        Question(
          question: 'How do you read a file in Python?',
          options: [
            'file.read()',
            'open(file).read()',
            'read_file(file)',
            'file.open().read()'
          ],
          correctAnswerIndex: 1,
          explanation: 'Files are opened using open() function and then read.',
        ),
        Question(
          question: 'What is list comprehension?',
          options: [
            'A way to comment lists',
            'A method to compress lists',
            'A concise way to create lists',
            'A list sorting technique'
          ],
          correctAnswerIndex: 2,
          explanation: 'List comprehension provides a compact way to create lists.',
        ),
      ],
      3: [
        Question(
          question: 'What is the purpose of __init__ method in Python?',
          options: [
            'To initialize the class',
            'To create instances',
            'Constructor for class initialization',
            'All of the above'
          ],
          correctAnswerIndex: 3,
          explanation: '__init__ is the constructor method for classes.',
        ),
        Question(
          question: 'What are decorators in Python?',
          options: [
            'Functions that modify other functions',
            'Special comments',
            'Type declarations',
            'Variable modifiers'
          ],
          correctAnswerIndex: 0,
          explanation: 'Decorators are functions that modify the behavior of other functions.',
        ),
        Question(
          question: 'How do you create a virtual environment in Python?',
          options: [
            'python create venv',
            'python -m venv myenv',
            'virtualenv create',
            'env python create'
          ],
          correctAnswerIndex: 1,
          explanation: 'python -m venv is the standard way to create virtual environments.',
        ),
        Question(
          question: 'What is the difference between == and is in Python?',
          options: [
            'No difference',
            '== checks value, is checks identity',
            'is checks value, == checks identity',
            'Both check identity'
          ],
          correctAnswerIndex: 1,
          explanation: '== compares values, is checks if they are the same object.',
        ),
        Question(
          question: 'What are Python generators?',
          options: [
            'Functions that generate code',
            'Functions that return iterators',
            'Special type of loops',
            'Code optimization tools'
          ],
          correctAnswerIndex: 1,
          explanation: 'Generators are functions that return an iterator object.',
        ),
      ],
    },
    'JavaScript': {
      1: [
        Question(
          question: 'How do you declare a variable in JavaScript?',
          options: ['var', 'let', 'const', 'All of the above'],
          correctAnswerIndex: 3,
          explanation: 'JavaScript has var, let, and const for variable declaration.',
        ),
        Question(
          question: 'What is the result of: "5" + 3',
          options: ['8', '53', 'Error', 'undefined'],
          correctAnswerIndex: 1,
          explanation: 'The + operator concatenates strings.',
        ),
      ],
      // Add more JavaScript questions...
    },
  };

  List<Question> get _currentQuestions {
    return _questionsDatabase[widget.language]?[widget.levelNumber] ?? [];
  }

  @override
  void initState() {
    super.initState();
    _selectedAnswers = List.filled(_currentQuestions.length, null);
  }

  void _selectAnswer(int answerIndex) {
    setState(() {
      _selectedAnswers[_currentQuestionIndex] = answerIndex;
      
      // Check if answer is correct
      if (answerIndex == _currentQuestions[_currentQuestionIndex].correctAnswerIndex) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _currentQuestions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      setState(() {
        _quizCompleted = true;
      });
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
    }
  }

  void _restartQuiz() {
    setState(() {
      _currentQuestionIndex = 0;
      _selectedAnswers = List.filled(_currentQuestions.length, null);
      _score = 0;
      _quizCompleted = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_quizCompleted) {
      return _buildResultsScreen();
    }

    if (_currentQuestions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Level ${widget.levelNumber} - ${widget.language}'),
        ),
        body: const Center(
          child: Text('No questions available for this level.'),
        ),
      );
    }

    final currentQuestion = _currentQuestions[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('Level ${widget.levelNumber} - ${widget.language}'),
        backgroundColor: _getLevelColor(widget.levelNumber),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Chip(
              label: Text('${_currentQuestionIndex + 1}/${_currentQuestions.length}'),
              backgroundColor: Colors.white,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress bar
            LinearProgressIndicator(
              value: (_currentQuestionIndex + 1) / _currentQuestions.length,
              backgroundColor: Colors.grey[300],
              color: _getLevelColor(widget.levelNumber),
            ),
            const SizedBox(height: 20),
            
            // Question
            Text(
              'Question ${_currentQuestionIndex + 1}:',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              currentQuestion.question,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            
            // Options
            Expanded(
              child: ListView.builder(
                itemCount: currentQuestion.options.length,
                itemBuilder: (context, index) {
                  return _buildOptionButton(
                    option: currentQuestion.options[index],
                    index: index,
                    isSelected: _selectedAnswers[_currentQuestionIndex] == index,
                    isCorrect: index == currentQuestion.correctAnswerIndex,
                    showAnswer: _selectedAnswers[_currentQuestionIndex] != null,
                  );
                },
              ),
            ),
            
            // Navigation buttons
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton({
    required String option,
    required int index,
    required bool isSelected,
    required bool isCorrect,
    required bool showAnswer,
  }) {
    Color getButtonColor() {
      if (!showAnswer) {
        return isSelected ? Colors.blue : Colors.grey[200]!;
      }
      if (isCorrect) {
        return Colors.green;
      }
      if (isSelected && !isCorrect) {
        return Colors.red;
      }
      return Colors.grey[200]!;
    }

    Color getTextColor() {
      if (!showAnswer) {
        return isSelected ? Colors.white : Colors.black;
      }
      if (isCorrect || isSelected) {
        return Colors.white;
      }
      return Colors.black;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: ElevatedButton(
        onPressed: () {
          if (_selectedAnswers[_currentQuestionIndex] == null) {
            _selectAnswer(index);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: getButtonColor(),
          foregroundColor: getTextColor(),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: getTextColor().withValues(alpha:0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  String.fromCharCode(65 + index), // A, B, C, D
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: getTextColor(),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                option,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            if (showAnswer && isCorrect)
              const Icon(Icons.check_circle, color: Colors.white),
            if (showAnswer && isSelected && !isCorrect)
              const Icon(Icons.cancel, color: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: _currentQuestionIndex > 0 ? _previousQuestion : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[300],
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.arrow_back),
                SizedBox(width: 8),
                Text('Previous'),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _selectedAnswers[_currentQuestionIndex] != null ? _nextQuestion : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _getLevelColor(widget.levelNumber),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _currentQuestionIndex == _currentQuestions.length - 1 
                      ? 'Finish' 
                      : 'Next',
                ),
                const SizedBox(width: 8),
                Icon(
                  _currentQuestionIndex == _currentQuestions.length - 1
                      ? Icons.done_all
                      : Icons.arrow_forward,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultsScreen() {
  final percentage = (_score / _currentQuestions.length) * 100;
  String getPerformanceText() {
    if (percentage >= 80) return 'Excellent! 🎉';
    if (percentage >= 60) return 'Good Job! 👍';
    if (percentage >= 40) return 'Not Bad! 💪';
    return 'Keep Practicing! 📚';
  }

  Color getPerformanceColor() {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 60) return Colors.blue;
    if (percentage >= 40) return Colors.orange;
    return Colors.red;
  }

  return Scaffold(
    appBar: AppBar(
      title: Text('Quiz Results - Level ${widget.levelNumber}'),
      backgroundColor: _getLevelColor(widget.levelNumber),
    ),
    body: Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Score Circle
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: getPerformanceColor().withValues(alpha:0.1),
              shape: BoxShape.circle,
              border: Border.all(color: getPerformanceColor(), width: 4),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$_score/${_currentQuestions.length}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 16,
                    color: getPerformanceColor(),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          
          // Performance Text
          Text(
            getPerformanceText(),
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: getPerformanceColor(),
            ),
          ),
          const SizedBox(height: 20),
          
          // Review Section - FIXED VERSION
          Expanded(
            child: ListView.builder(
              itemCount: _currentQuestions.length,
              itemBuilder: (context, index) {
                final question = _currentQuestions[index];
                final userAnswer = _selectedAnswers[index];
                final isCorrect = userAnswer == question.correctAnswerIndex;
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // FIXED: Use Column instead of Row for better text wrapping
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  isCorrect ? Icons.check_circle : Icons.cancel,
                                  color: isCorrect ? Colors.green : Colors.red,
                                ),
                                const SizedBox(width: 8),
                                Expanded( // ADDED: Expanded to prevent overflow
                                  child: Text(
                                    'Q${index + 1}: ${question.question}',
                                    style: const TextStyle(fontWeight: FontWeight.w500),
                                    maxLines: 3, // ADDED: Limit lines
                                    overflow: TextOverflow.ellipsis, // ADDED: Handle overflow
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            if (!isCorrect && userAnswer != null)
                              Text(
                                'Your answer: ${question.options[userAnswer]}',
                                style: TextStyle(
                                  color: Colors.red[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            Text(
                              'Correct answer: ${question.options[question.correctAnswerIndex]}',
                              style: TextStyle(
                                color: Colors.green[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Explanation: ${question.explanation}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _restartQuiz,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Try Again'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LevelScreen(language: widget.language),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getLevelColor(widget.levelNumber),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Back to Levels'),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

  Color _getLevelColor(int level) {
    switch (level) {
      case 1: return Colors.green;
      case 2: return Colors.orange;
      case 3: return Colors.red;
      default: return Colors.blue;
    }
  }
}

class Question {
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final String explanation;

  const Question({
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    required this.explanation,
  });
}

// Updated LevelScreen to include language
class LevelScreen extends StatefulWidget {
  final String language;

  const LevelScreen({super.key, required this.language});

  @override
  State<LevelScreen> createState() => _LevelScreenState();
}

class _LevelScreenState extends State<LevelScreen> {
  final List<Map<String, dynamic>> levels = const [
    {'levelNumber': 1, 'levelName': 'Beginner', 'questionCount': 5},
    {'levelNumber': 2, 'levelName': 'Intermediate', 'questionCount': 5},
    {'levelNumber': 3, 'levelName': 'Advanced', 'questionCount': 5},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.language} - Select Level 🏆'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose your ${widget.language} challenge:',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: levels.length,
                itemBuilder: (context, index) {
                  final level = levels[index];
                  return LevelCard(
                    levelNumber: level['levelNumber'] as int,
                    levelName: level['levelName'] as String,
                    questionCount: level['questionCount'] as int,
                    language: widget.language,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => QuestionScreen(
                            levelNumber: level['levelNumber'] as int,
                            language: widget.language,
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
    );
  }
}

class LevelCard extends StatelessWidget {
  final int levelNumber;
  final String levelName;
  final int questionCount;
  final String language;
  final VoidCallback onTap;

  const LevelCard({
    super.key,
    required this.levelNumber,
    required this.levelName,
    required this.questionCount,
    required this.language,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        margin: const EdgeInsets.only(bottom: 16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              colors: _getLevelGradient(levelNumber),
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha:0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$levelNumber',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        levelName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.quiz, color: Colors.white, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '$questionCount Questions',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        language,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Color> _getLevelGradient(int level) {
    switch (level) {
      case 1:
        return [Colors.green[400]!, Colors.green[600]!];
      case 2:
        return [Colors.orange[400]!, Colors.orange[600]!];
      case 3:
        return [Colors.red[400]!, Colors.red[600]!];
      default:
        return [Colors.blue[400]!, Colors.blue[600]!];
    }
  }
}