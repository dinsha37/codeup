// question_screen.dart
// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../question/model/questin_model.dart';
import 'addquetionuderlevel_screen.dart'; // Import the new screen

class QuestionUnderSubScreen extends StatefulWidget {
  final String subLevelId;
  final String subLevelName;
  final String mainLevelName;

  const QuestionUnderSubScreen({
    super.key,
    required this.subLevelId,
    required this.subLevelName,
    required this.mainLevelName,
  });

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
                              'Q$order',
                              style: const TextStyle(
                                color: Colors.indigo,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                            onPressed: () => _navigateToEditQuestion(
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
        onPressed: _navigateToAddQuestion,
        icon: const Icon(Icons.add),
        label: const Text('Add Question'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
    );
  }

  Future<void> _navigateToAddQuestion() async {
    final result = await Navigator.push<QuestionModel>(
      context,
      MaterialPageRoute(
        builder: (context) => AddQuestionUnderLevelScreen(
          subLevelId: widget.subLevelId,
          subLevelName: widget.subLevelName,
          mainLevelName: widget.mainLevelName,
        ),
      ),
    );

    if (result != null && mounted) {
      try {
        final questionData = result.toMap();
        questionData['createdAt'] = FieldValue.serverTimestamp();
        
        await _firestore.collection('questions').add(questionData);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Question created successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error creating question: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _navigateToEditQuestion(
    String docId,
    String currentQuestion,
    List<String> currentOptions,
    int currentCorrectAnswer,
    int currentOrder,
  ) async {
    final existingQuestion = QuestionModel(
      id: docId,
      question: currentQuestion,
      options: currentOptions,
      correctAnswer: currentCorrectAnswer,
      order: currentOrder,
      subLevelId: widget.subLevelId,
    );

    final result = await Navigator.push<QuestionModel>(
      context,
      MaterialPageRoute(
        builder: (context) => AddQuestionUnderLevelScreen(
          question: existingQuestion,
          subLevelId: widget.subLevelId,
          subLevelName: widget.subLevelName,
          mainLevelName: widget.mainLevelName,
        ),
      ),
    );

    if (result != null && mounted) {
      try {
        await _firestore
            .collection('questions')
            .doc(docId)
            .update(result.toMap());
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Question updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error updating question: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _showDeleteDialog(String docId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Delete Question'),
          ],
        ),
        content: const Text(
          'Are you sure you want to delete this question? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _firestore.collection('questions').doc(docId).delete();
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Question deleted successfully!'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error deleting question: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
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