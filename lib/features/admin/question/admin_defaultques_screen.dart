import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'model/questin_model.dart';

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

  Future<void> _addQuestion(QuestionModel question) async {
    await _firestore.collection(collectionName).add(question.toMap());
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Question added successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _updateQuestion(QuestionModel question) async {
    await _firestore
        .collection(collectionName)
        .doc(question.id)
        .update(question.toMap());
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Question updated successfully!'),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _deleteQuestion(String id) async {
    await _firestore.collection(collectionName).doc(id).delete();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Question deleted successfully!'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _navigateToAddQuestion() async {
    final snapshot = await _firestore.collection(collectionName).get();

    if (snapshot.docs.length >= 10) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Maximum 10 questions allowed. Please delete a question to add new one.',
            ),
            backgroundColor: Colors.orange,
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

  void _navigateToEditQuestion(QuestionModel question) {
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
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F4F2),
      appBar: AppBar(
        title: const Text(
          'Quiz Questions',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection(collectionName).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final questions = snapshot.data!.docs
              .map(
                (doc) => QuestionModel.fromMap(
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
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: questions.length < 10
                      ? Colors.blue.shade50
                      : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: questions.length < 10
                        ? Colors.blue.shade200
                        : Colors.orange.shade200,
                  ),
                ),
                child: Text(
                  questions.length < 10
                      ? '${questions.length}/10 questions added'
                      : 'Maximum limit reached (10/10 questions)',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: questions.length < 10
                        ? Colors.blue.shade700
                        : Colors.orange.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: questions.length,
                  itemBuilder: (context, index) {
                    final question = questions[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    color: Colors.blue,
                                    size: 22,
                                  ),
                                  onPressed: () =>
                                      _navigateToEditQuestion(question),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                    size: 22,
                                  ),
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
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
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                            child: const Text(
                                              'Delete',
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
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
        backgroundColor: Colors.blue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }
}

class AddQuestionScreen extends StatefulWidget {
  final QuestionModel? question;
  final Function(QuestionModel) onSubmit;

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
  bool _isSubmitting = false;

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
      text: widget.question?.options != null &&
              widget.question!.options.length > 1
          ? widget.question!.options[1]
          : '',
    );
    _option3Controller = TextEditingController(
      text: widget.question?.options != null &&
              widget.question!.options.length > 2
          ? widget.question!.options[2]
          : '',
    );
    _option4Controller = TextEditingController(
      text: widget.question?.options != null &&
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
      setState(() {
        _isSubmitting = true;
      });

      final newQuestion = QuestionModel(
        id: widget.question?.id ?? '',
        question: _questionController.text.trim(),
        order: 0,
        subLevelId: '',
        options: [
          _option1Controller.text.trim(),
          _option2Controller.text.trim(),
          _option3Controller.text.trim(),
          _option4Controller.text.trim(),
        ],
        correctAnswer: _selectedCorrectAnswer,
      );

      widget.onSubmit(newQuestion);
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          Navigator.pop(context);
        }
      });
    }
  }

  InputDecoration _buildInputDecoration(String label, String hint, IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon),
      hintText: hint,
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Colors.blue,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.question != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F4F2),
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Question' : 'Add New Question',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Question Field
              const Text(
                'Question',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _questionController,
                decoration: _buildInputDecoration(
                  'Question',
                  'Enter your question here',
                  Icons.help_outline,
                ),
                maxLines: 3,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a question';
                  }
                  if (value.trim().length < 5) {
                    return 'Question must be at least 5 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 28),

              // Options Section
              const Text(
                'Options',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Select the radio button for the correct answer',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 16),

              // Options List
              ...List.generate(4, (index) {
                final controllers = [
                  _option1Controller,
                  _option2Controller,
                  _option3Controller,
                  _option4Controller,
                ];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: _selectedCorrectAnswer == index
                            ? Colors.blue
                            : Colors.grey[300]!,
                        width: _selectedCorrectAnswer == index ? 2 : 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
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
                            activeColor: Colors.blue,
                          ),
                          Expanded(
                            child: TextFormField(
                              controller: controllers[index],
                              decoration: InputDecoration(
                                hintText: 'Option ${index + 1}',
                                labelText: 'Option ${index + 1}',
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                contentPadding: const EdgeInsets.only(left: 8),
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
                    ),
                  ),
                );
              }),

              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    disabledBackgroundColor: Colors.blue[300],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              isEditing
                                  ? 'UPDATE QUESTION'
                                  : 'SUBMIT QUESTION',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.arrow_forward,
                              color: Colors.white,
                              size: 20,
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}