// question_screen.dart
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QuestionUnderSubScreen extends StatefulWidget {
  final String subLevelId;
  final String subLevelName;
  final String mainLevelName;

  const QuestionUnderSubScreen({
    Key? key,
    required this.subLevelId,
    required this.subLevelName,
    required this.mainLevelName,
  }) : super(key: key);

  @override
  State<QuestionUnderSubScreen> createState() => _QuestionUnderSubScreenState();
}

class _QuestionUnderSubScreenState extends State<QuestionUnderSubScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Questions', style: TextStyle(fontSize: 18)),
            Text(
              '${widget.mainLevelName} - ${widget.subLevelName}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
            ),
          ],
        ),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('questions')
            .where('subLevelId', isEqualTo: widget.subLevelId)
            .orderBy('order')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            log('${snapshot.error}');
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final questions = snapshot.data?.docs ?? [];

          if (questions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.quiz_outlined, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No Questions Yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + button to add questions',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: questions.length,
            itemBuilder: (context, index) {
              final doc = questions[index];
              final data = doc.data() as Map<String, dynamic>;
              final question = data['question'] ?? 'No question';
              final options = List<String>.from(data['options'] ?? []);
              final correctAnswer = data['correctAnswer'] ?? 0;
              final order = data['order'] ?? 0;

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.indigo.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Q${order}',
                              style: const TextStyle(
                                color: Colors.indigo,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                            onPressed: () => _showEditDialog(
                              doc.id,
                              question,
                              options,
                              correctAnswer,
                              order,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                            onPressed: () => _showDeleteDialog(doc.id),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        question,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...List.generate(options.length, (optIndex) {
                        final isCorrect = optIndex == correctAnswer;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isCorrect
                                ? Colors.green.withValues(alpha: 0.1)
                                : Colors.grey.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isCorrect
                                  ? Colors.green
                                  : Colors.grey.withValues(alpha: 0.2),
                              width: isCorrect ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: isCorrect
                                      ? Colors.green
                                      : Colors.grey[300],
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  String.fromCharCode(65 + optIndex),
                                  style: TextStyle(
                                    color: isCorrect
                                        ? Colors.white
                                        : Colors.black87,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  options[optIndex],
                                  style: TextStyle(
                                    color: isCorrect
                                        ? Colors.green[900]
                                        : Colors.black87,
                                    fontWeight: isCorrect
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                              if (isCorrect)
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 20,
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
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Question'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
    );
  }

  void _showAddDialog() {
    _showQuestionDialog();
  }

  void _showEditDialog(
    String docId,
    String currentQuestion,
    List<String> currentOptions,
    int currentCorrectAnswer,
    int currentOrder,
  ) {
    _showQuestionDialog(
      docId: docId,
      initialQuestion: currentQuestion,
      initialOptions: currentOptions,
      initialCorrectAnswer: currentCorrectAnswer,
      initialOrder: currentOrder,
    );
  }

  void _showQuestionDialog({
    String? docId,
    String? initialQuestion,
    List<String>? initialOptions,
    int? initialCorrectAnswer,
    int? initialOrder,
  }) {
    final questionController = TextEditingController(text: initialQuestion ?? '');
    final option1Controller = TextEditingController(
      text: initialOptions != null && initialOptions.isNotEmpty
          ? initialOptions[0]
          : '',
    );
    final option2Controller = TextEditingController(
      text: initialOptions != null && initialOptions.length > 1
          ? initialOptions[1]
          : '',
    );
    final option3Controller = TextEditingController(
      text: initialOptions != null && initialOptions.length > 2
          ? initialOptions[2]
          : '',
    );
    final option4Controller = TextEditingController(
      text: initialOptions != null && initialOptions.length > 3
          ? initialOptions[3]
          : '',
    );
    final orderController = TextEditingController(
      text: initialOrder?.toString() ?? '1',
    );

    int selectedCorrectAnswer = initialCorrectAnswer ?? 0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(docId == null ? 'Add Question' : 'Edit Question'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: questionController,
                  decoration: const InputDecoration(
                    labelText: 'Question',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Options',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                const SizedBox(height: 8),
                _buildOptionField(option1Controller, 'Option A', 0,
                    selectedCorrectAnswer, setState, (val) {
                  setState(() => selectedCorrectAnswer = val);
                }),
                const SizedBox(height: 8),
                _buildOptionField(option2Controller, 'Option B', 1,
                    selectedCorrectAnswer, setState, (val) {
                  setState(() => selectedCorrectAnswer = val);
                }),
                const SizedBox(height: 8),
                _buildOptionField(option3Controller, 'Option C', 2,
                    selectedCorrectAnswer, setState, (val) {
                  setState(() => selectedCorrectAnswer = val);
                }),
                const SizedBox(height: 8),
                _buildOptionField(option4Controller, 'Option D', 3,
                    selectedCorrectAnswer, setState, (val) {
                  setState(() => selectedCorrectAnswer = val);
                }),
                const SizedBox(height: 16),
                TextField(
                  controller: orderController,
                  decoration: const InputDecoration(
                    labelText: 'Question Order (1, 2, 3...)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (questionController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a question')),
                  );
                  return;
                }

                final options = [
                  option1Controller.text.trim(),
                  option2Controller.text.trim(),
                  option3Controller.text.trim(),
                  option4Controller.text.trim(),
                ];

                if (options.any((opt) => opt.isEmpty)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all options')),
                  );
                  return;
                }

                final questionData = {
                  'subLevelId': widget.subLevelId,
                  'question': questionController.text.trim(),
                  'options': options,
                  'correctAnswer': selectedCorrectAnswer,
                  'order': int.tryParse(orderController.text) ?? 1,
                };

                if (docId == null) {
                  // Create new question
                  questionData['createdAt'] = FieldValue.serverTimestamp();
                  await _firestore.collection('questions').add(questionData);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Question created!')),
                  );
                } else {
                  // Update existing question
                  await _firestore
                      .collection('questions')
                      .doc(docId)
                      .update(questionData);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Question updated!')),
                  );
                }

                Navigator.pop(context);
              },
              child: Text(docId == null ? 'Add' : 'Update'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionField(
    TextEditingController controller,
    String label,
    int optionIndex,
    int selectedCorrectAnswer,
    StateSetter setState,
    Function(int) onSelect,
  ) {
    final isSelected = selectedCorrectAnswer == optionIndex;

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: label,
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  color: isSelected ? Colors.green : Colors.grey,
                  width: isSelected ? 2 : 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: isSelected ? Colors.green : Colors.grey,
                  width: isSelected ? 2 : 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: isSelected ? Colors.green : Colors.blue,
                  width: 2,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        InkWell(
          onTap: () => onSelect(optionIndex),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected ? Colors.green : Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: Icon(
              isSelected ? Icons.check : Icons.circle_outlined,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  void _showDeleteDialog(String docId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Question'),
        content: const Text('Are you sure you want to delete this question?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _firestore.collection('questions').doc(docId).delete();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Question deleted!')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}