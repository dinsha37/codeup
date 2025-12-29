import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Question {
  String id;
  String question;
  List<String> options;
  int correctAnswer;

  Question({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswer,
  });

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'options': options,
      'correctAnswer': correctAnswer,
    };
  }

  factory Question.fromMap(String id, Map<String, dynamic> map) {
    return Question(
      id: id,
      question: map['question'] ?? '',
      options: List<String>.from(map['options'] ?? []),
      correctAnswer: map['correctAnswer'] ?? 0,
    );
  }
}

class DefaultquesScreen extends StatefulWidget {
  const DefaultquesScreen({super.key});

  @override
  State<DefaultquesScreen> createState() => _DefaultquesScreenState();
}

class _DefaultquesScreenState extends State<DefaultquesScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionName = 'DQuiz';
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeDefaultQuestions();
  }

  Future<void> _initializeDefaultQuestions() async {
    setState(() {
      _isInitialized = true;
    });
  }

  Future<void> _addQuestion(Question question) async {
    await _firestore.collection(collectionName).add(question.toMap());
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Question added successfully!')),
      );
    }
  }

  Future<void> _updateQuestion(Question question) async {
    await _firestore
        .collection(collectionName)
        .doc(question.id)
        .update(question.toMap());
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Question updated successfully!')),
      );
    }
  }

  Future<void> _deleteQuestion(String id) async {
    await _firestore.collection(collectionName).doc(id).delete();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Question deleted successfully!')),
      );
    }
  }

  void _navigateToAddQuestion() async {
    // Check current question count
    final snapshot = await _firestore.collection(collectionName).get();

    if (snapshot.docs.length >= 10) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Maximum 10 questions allowed. Please delete a question to add new one.',
            ),
            duration: Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddQuestionScreen(onSubmit: _addQuestion),
        ),
      );
    }
  }

  void _navigateToEditQuestion(Question question) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AddQuestionScreen(question: question, onSubmit: _updateQuestion),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Quiz Questions')),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection(collectionName).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final questions = snapshot.data!.docs
              .map(
                (doc) => Question.fromMap(
                  doc.id,
                  doc.data() as Map<String, dynamic>,
                ),
              )
              .toList();

          if (questions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.quiz_outlined, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No questions yet',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the + button to create your first question',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              if (questions.length < 10)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: Colors.blue.shade50,
                  child: Text(
                    '${questions.length}/10 questions added',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: Colors.orange.shade50,
                  child: Text(
                    'Maximum limit reached (10/10 questions)',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.orange.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: questions.length,
                  itemBuilder: (context, index) {
                    final question = questions[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Q${index + 1}: ${question.question}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () =>
                                      _navigateToEditQuestion(question),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Delete Question'),
                                        content: const Text(
                                          'Are you sure you want to delete this question?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, false),
                                            child: const Text('Cancel'),
                                          ),
                                          ElevatedButton(
                                            onPressed: () =>
                                                Navigator.pop(context, true),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                            ),
                                            child: const Text('Delete'),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (confirm == true) {
                                      _deleteQuestion(question.id);
                                    }
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ...List.generate(question.options.length, (
                              optionIndex,
                            ) {
                              final isCorrect =
                                  optionIndex == question.correctAnswer;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    Icon(
                                      isCorrect
                                          ? Icons.check_circle
                                          : Icons.circle_outlined,
                                      color: isCorrect
                                          ? Colors.green
                                          : Colors.grey,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        question.options[optionIndex],
                                        style: TextStyle(
                                          fontWeight: isCorrect
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          color: isCorrect
                                              ? Colors.green
                                              : Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddQuestion,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddQuestionScreen extends StatefulWidget {
  final Question? question;
  final Function(Question) onSubmit;

  const AddQuestionScreen({super.key, this.question, required this.onSubmit});

  @override
  State<AddQuestionScreen> createState() => _AddQuestionScreenState();
}

class _AddQuestionScreenState extends State<AddQuestionScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _questionController;
  late TextEditingController _option1Controller;
  late TextEditingController _option2Controller;
  late TextEditingController _option3Controller;
  late TextEditingController _option4Controller;
  int _selectedCorrectAnswer = 0;

  @override
  void initState() {
    super.initState();
    _questionController = TextEditingController(
      text: widget.question?.question ?? '',
    );
    _option1Controller = TextEditingController(
      text: widget.question?.options.isNotEmpty == true
          ? widget.question!.options[0]
          : '',
    );
    _option2Controller = TextEditingController(
      text:
          widget.question?.options != null &&
              widget.question!.options.length > 1
          ? widget.question!.options[1]
          : '',
    );
    _option3Controller = TextEditingController(
      text:
          widget.question?.options != null &&
              widget.question!.options.length > 2
          ? widget.question!.options[2]
          : '',
    );
    _option4Controller = TextEditingController(
      text:
          widget.question?.options != null &&
              widget.question!.options.length > 3
          ? widget.question!.options[3]
          : '',
    );
    _selectedCorrectAnswer = widget.question?.correctAnswer ?? 0;
  }

  @override
  void dispose() {
    _questionController.dispose();
    _option1Controller.dispose();
    _option2Controller.dispose();
    _option3Controller.dispose();
    _option4Controller.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final newQuestion = Question(
        id: widget.question?.id ?? '',
        question: _questionController.text.trim(),
        options: [
          _option1Controller.text.trim(),
          _option2Controller.text.trim(),
          _option3Controller.text.trim(),
          _option4Controller.text.trim(),
        ],
        correctAnswer: _selectedCorrectAnswer,
      );

      widget.onSubmit(newQuestion);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.question != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Question' : 'Add Question')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _questionController,
              decoration: const InputDecoration(
                labelText: 'Question',
                border: OutlineInputBorder(),
                hintText: 'Enter your question here',
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a question';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'Options',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Select the radio button for the correct answer',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 16),
            ...List.generate(4, (index) {
              final controllers = [
                _option1Controller,
                _option2Controller,
                _option3Controller,
                _option4Controller,
              ];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Radio<int>(
                      value: index,
                      groupValue: _selectedCorrectAnswer,
                      onChanged: (value) {
                        setState(() {
                          _selectedCorrectAnswer = value!;
                        });
                      },
                    ),
                    Expanded(
                      child: TextFormField(
                        controller: controllers[index],
                        decoration: InputDecoration(
                          labelText: 'Option ${index + 1}',
                          border: const OutlineInputBorder(),
                          hintText: 'Enter option ${index + 1}',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter option ${index + 1}';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _handleSubmit,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                textStyle: const TextStyle(fontSize: 16),
              ),
              child: Text(isEditing ? 'Update Question' : 'Submit Question'),
            ),
          ],
        ),
      ),
    );
  }
}
