import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../utils/variables/global_variables.dart';
import '../admin/question/model/questin_model.dart';
import 'model/mainlevel_model.dart';
import 'sucess_screen.dart';

class QuestionScreen extends StatefulWidget {
  final String mainLevelId;
  final String subLevelId;
  final String subLevelName;
  final MainLevel mainLevel;

  const QuestionScreen({
    required this.mainLevelId,
    required this.subLevelId,
    required this.subLevelName,
    required this.mainLevel,
  });

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  int _currentQuestionIndex = 0;
  List<int?> _selectedAnswers = [];
  int _score = 0;
  bool _quizCompleted = false;
  List<QuestionModel> _questions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<List<QuestionModel>> getQuestions() async {
    try {
      final snapshot = await _db
          .collection('questions')
          .where('subLevelId', isEqualTo: widget.subLevelId)
          .orderBy('order')
          .get();
      return snapshot.docs
          .map((doc) => QuestionModel.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      return [];
    }
  }

  void _loadQuestions() async {
    final questions = await getQuestions();
    setState(() {
      _questions = questions;
      _selectedAnswers = List.filled(questions.length, null);
      _isLoading = false;
    });
  }

  void _selectAnswer(int answerIndex) {
    if (_selectedAnswers[_currentQuestionIndex] != null) return;

    setState(() {
      _selectedAnswers[_currentQuestionIndex] = answerIndex;
      if (answerIndex == _questions[_currentQuestionIndex].correctAnswer) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() => _currentQuestionIndex++);
    } else {
      _completeQuiz();
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() => _currentQuestionIndex--);
    }
  }

  Future<bool> saveQuizAttempt() async {
    try {
      final userId = globalUser?.uid;
      if (userId == null) return false;

      final percentage = (_score / _questions.length) * 100;
      final isPassed = percentage >= 60;

      await _db
          .collection('userStatus')
          .doc(userId)
          .collection('quizAttempts')
          .add({
        'subLevelId': widget.subLevelId,
        'score': _score,
        'totalQuestions': _questions.length,
        'percentage': percentage,
        'isPassed': isPassed,
        'selectedAnswers': _selectedAnswers,
        'attemptedAt': FieldValue.serverTimestamp(),
      });

      if (isPassed) {
        await _db.collection('userStatus').doc(userId).set({
          'completedSubLevels': FieldValue.arrayUnion([widget.subLevelId]),
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      return isPassed;
    } catch (e) {
      return false;
    }
  }

  void _completeQuiz() async {
    await saveQuizAttempt();
    if (mounted) {
      setState(() => _quizCompleted = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.subLevelName),
          backgroundColor: widget.mainLevel.gradientColors[0],
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Handle empty questions
    if (_questions.isEmpty) {
      return WillPopScope(
        onWillPop: () async {
          // Allow back navigation when no questions
          return true;
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(widget.subLevelName),
            backgroundColor: widget.mainLevel.gradientColors[0],
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.block_outlined,
                    size: 80,
                    color: widget.mainLevel.gradientColors[0],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'No Questions Available',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Questions for this level will be added soon.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 36),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.mainLevel.gradientColors[0],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.arrow_back),
                        SizedBox(width: 8),
                        Text(
                          'Go Back',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (_quizCompleted) {
      return SuccessScreen(
        score: _score,
        totalQuestions: _questions.length,
        mainLevelId: widget.mainLevelId,
        subLevelId: widget.subLevelId,
        subLevelName: widget.subLevelName,
        mainLevel: widget.mainLevel,
        questions: _questions,
        selectedAnswers: _selectedAnswers,
      );
    }

    final currentQuestion = _questions[_currentQuestionIndex];

    return WillPopScope(
      onWillPop: () async {
        // Show dialog to confirm exit
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Exit Quiz?'),
            content: const Text(
              'Your progress will be lost. Are you sure you want to exit?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Continue Quiz'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Exit'),
              ),
            ],
          ),
        );
        return shouldPop ?? false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.subLevelName),
          backgroundColor: widget.mainLevel.gradientColors[0],
          actions: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  '${_currentQuestionIndex + 1}/${_questions.length}',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LinearProgressIndicator(
                value: (_currentQuestionIndex + 1) / _questions.length,
                minHeight: 6,
                backgroundColor: Colors.grey[300],
                color: widget.mainLevel.gradientColors[0],
              ),
              const SizedBox(height: 24),
              Text(
                'Question ${_currentQuestionIndex + 1} of ${_questions.length}',
                style: TextStyle(
                  fontSize: 14,
                  color: widget.mainLevel.gradientColors[0],
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                currentQuestion.question,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.builder(
                  itemCount: currentQuestion.options.length,
                  itemBuilder: (context, index) {
                    final isSelected =
                        _selectedAnswers[_currentQuestionIndex] == index;
                    final isCorrect = index == currentQuestion.correctAnswer;
                    final showAnswer =
                        _selectedAnswers[_currentQuestionIndex] != null;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GestureDetector(
                        onTap: () => _selectAnswer(index),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: !showAnswer
                                ? (isSelected
                                    ? widget.mainLevel.gradientColors[0]
                                    : Colors.grey[100])
                                : (isCorrect
                                    ? Colors.green[50]
                                    : (isSelected
                                        ? Colors.red[50]
                                        : Colors.grey[50])),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: !showAnswer
                                  ? (isSelected
                                      ? widget.mainLevel.gradientColors[0]
                                      : Colors.grey[300]!)
                                  : (isCorrect
                                      ? Colors.green
                                      : (isSelected
                                          ? Colors.red
                                          : Colors.grey[300]!)),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: !showAnswer
                                      ? (isSelected
                                          ? Colors.white.withValues(alpha: 0.3)
                                          : Colors.grey[300])
                                      : (isCorrect
                                          ? Colors.green[200]
                                          : (isSelected
                                              ? Colors.red[200]
                                              : Colors.grey[200])),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    String.fromCharCode(65 + index),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: !showAnswer
                                          ? (isSelected
                                              ? Colors.white
                                              : Colors.black)
                                          : (isCorrect || isSelected
                                              ? Colors.white
                                              : Colors.black),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  currentQuestion.options[index],
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: !showAnswer
                                        ? (isSelected
                                            ? Colors.white
                                            : Colors.black)
                                        : (isCorrect || isSelected
                                            ? Colors.black
                                            : Colors.black),
                                  ),
                                ),
                              ),
                              if (showAnswer && isCorrect)
                                const Icon(Icons.check_circle,
                                    color: Colors.green, size: 24),
                              if (showAnswer && isSelected && !isCorrect)
                                const Icon(Icons.cancel,
                                    color: Colors.red, size: 24),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed:
                          _currentQuestionIndex > 0 ? _previousQuestion : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
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
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _selectedAnswers[_currentQuestionIndex] != null
                          ? _nextQuestion
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            widget.mainLevel.gradientColors[0],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentQuestionIndex == _questions.length - 1
                                ? 'Submit'
                                : 'Next',
                          ),
                          const SizedBox(width: 8),
                          Icon(_currentQuestionIndex == _questions.length - 1
                              ? Icons.done_all
                              : Icons.arrow_forward),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}