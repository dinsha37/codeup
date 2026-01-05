import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../admin/question/model/questin_model.dart';
import 'model/mainlevel_model.dart';

class ReviewResultScreen extends StatefulWidget {
  final String subLevelId;
  final String subLevelName;
  final MainLevel mainLevel;
  final Map<String, dynamic> attemptData;

  const ReviewResultScreen({
    required this.subLevelId,
    required this.subLevelName,
    required this.mainLevel,
    required this.attemptData,
  });

  @override
  State<ReviewResultScreen> createState() => _ReviewResultScreenState();
}

class _ReviewResultScreenState extends State<ReviewResultScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  List<QuestionModel> _questions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final snapshot = await _db
          .collection('questions')
          .where('subLevelId', isEqualTo: widget.subLevelId)
          .orderBy('order')
          .get();
      
      setState(() {
        _questions = snapshot.docs
            .map((doc) => QuestionModel.fromMap(doc.id, doc.data()))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final score = widget.attemptData['score'] ?? 0;
    final totalQuestions = widget.attemptData['totalQuestions'] ?? 0;
    final percentage = widget.attemptData['percentage'] ?? 0.0;
    final isPassed = widget.attemptData['isPassed'] ?? false;
    final selectedAnswers = List<int?>.from(widget.attemptData['selectedAnswers'] ?? []);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subLevelName),
        backgroundColor: widget.mainLevel.gradientColors[0],
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Score Summary Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isPassed
                            ? [Colors.green[400]!, Colors.green[600]!]
                            : [Colors.orange[400]!, Colors.orange[600]!],
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '$score/$totalQuestions',
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                '${percentage.toStringAsFixed(1)}%',
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          isPassed ? '✅ Passed' : '📚 Keep Practicing',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Review your answers below',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Questions Review
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Answer Review',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _questions.length,
                          itemBuilder: (context, index) {
                            final question = _questions[index];
                            final selectedAnswer = selectedAnswers[index];
                            final isCorrect = selectedAnswer == question.correctAnswer;

                            return Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: isCorrect ? Colors.green : Colors.red,
                                  width: 2,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: isCorrect
                                                ? Colors.green[50]
                                                : Colors.red[50],
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Icon(
                                            isCorrect
                                                ? Icons.check_circle
                                                : Icons.cancel,
                                            color: isCorrect
                                                ? Colors.green
                                                : Colors.red,
                                            size: 24,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            'Question ${index + 1}',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: isCorrect
                                                  ? Colors.green[700]
                                                  : Colors.red[700],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      question.question,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    ...List.generate(
                                      question.options.length,
                                      (optionIndex) {
                                        final isSelected = selectedAnswer == optionIndex;
                                        final isCorrectAnswer = optionIndex == question.correctAnswer;

                                        return Container(
                                          margin: const EdgeInsets.only(bottom: 8),
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: isCorrectAnswer
                                                ? Colors.green[50]
                                                : (isSelected
                                                    ? Colors.red[50]
                                                    : Colors.grey[50]),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(
                                              color: isCorrectAnswer
                                                  ? Colors.green
                                                  : (isSelected
                                                      ? Colors.red
                                                      : Colors.grey[300]!),
                                              width: isCorrectAnswer || isSelected ? 2 : 1,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 28,
                                                height: 28,
                                                decoration: BoxDecoration(
                                                  color: isCorrectAnswer
                                                      ? Colors.green[200]
                                                      : (isSelected
                                                          ? Colors.red[200]
                                                          : Colors.grey[200]),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    String.fromCharCode(65 + optionIndex),
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      color: isCorrectAnswer || isSelected
                                                          ? Colors.white
                                                          : Colors.black,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Text(
                                                  question.options[optionIndex],
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: isCorrectAnswer || isSelected
                                                        ? FontWeight.w600
                                                        : FontWeight.normal,
                                                  ),
                                                ),
                                              ),
                                              if (isCorrectAnswer)
                                                const Icon(
                                                  Icons.check_circle,
                                                  color: Colors.green,
                                                  size: 20,
                                                ),
                                              if (isSelected && !isCorrectAnswer)
                                                const Icon(
                                                  Icons.cancel,
                                                  color: Colors.red,
                                                  size: 20,
                                                ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  // Action Buttons
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: widget.mainLevel.gradientColors[0],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Back to Levels',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        if (!isPassed) ...[
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () {
                                // Retake quiz - pop and let them start fresh
                                Navigator.pop(context);
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: widget.mainLevel.gradientColors[0],
                                side: BorderSide(
                                  color: widget.mainLevel.gradientColors[0],
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Try Again',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}