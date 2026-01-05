import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../utils/variables/global_variables.dart';
import '../admin/question/model/questin_model.dart';
import 'model/mainlevel_model.dart';
import 'user_questions_screen.dart';

class SuccessScreen extends StatefulWidget {
  final int score;
  final int totalQuestions;
  final String mainLevelId;
  final String subLevelId;
  final MainLevel mainLevel;
  final List<QuestionModel> questions;
  final List<int?> selectedAnswers;
  final String subLevelName;

  const SuccessScreen({
    required this.score,
    required this.totalQuestions,
    required this.mainLevelId,
    required this.subLevelId,
    required this.mainLevel,
    required this.questions,
    required this.selectedAnswers,
    required this.subLevelName,
  });

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  bool _certificateIssued = false;

  @override
  void initState() {
    super.initState();
    _checkAndIssueCertificate();
  }

  Future<bool> canIssueCertificate() async {
    try {
      final userId = globalUser?.uid;
      if (userId == null) return false;

      final subLevelsDocs = await _db
          .collection('subLevels')
          .where('mainLevelId', isEqualTo: widget.mainLevelId)
          .get();

      final userDoc = await _db.collection('userStatus').doc(userId).get();
      final completedSubLevels =
          List<String>.from(userDoc.data()?['completedSubLevels'] ?? []);

      final mainLevelSubLevels =
          subLevelsDocs.docs.map((doc) => doc.id).toList();

      return mainLevelSubLevels.isNotEmpty &&
          mainLevelSubLevels.every((id) => completedSubLevels.contains(id));
    } catch (e) {
      return false;
    }
  }

  Future<bool> issueCertificate() async {
    try {
      final userId = globalUser?.uid;
      if (userId == null) return false;

      final eligible = await canIssueCertificate();
      if (!eligible) return false;

      await _db
          .collection('userStatus')
          .doc(userId)
          .collection('certificates')
          .add({
        'mainLevelId': widget.mainLevelId,
        'issuedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  void _checkAndIssueCertificate() async {
    final issued = await issueCertificate();
    if (mounted) {
      setState(() => _certificateIssued = issued);
    }
  }

  void _retakeQuiz() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => QuestionScreen(
          mainLevelId: widget.mainLevelId,
          subLevelId: widget.subLevelId,
          subLevelName: widget.subLevelName,
          mainLevel: widget.mainLevel,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final percentage = (widget.score / widget.totalQuestions) * 100;
    final isPassed = percentage >= 60;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isPassed
                  ? [Colors.green[400]!, Colors.green[600]!]
                  : [Colors.orange[400]!, Colors.orange[600]!],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      const SizedBox(height: 20),
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.elasticOut,
                        builder: (context, value, child) {
                          return Transform.scale(scale: value, child: child);
                        },
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 4,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${widget.score}/${widget.totalQuestions}',
                                style: const TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${percentage.toStringAsFixed(1)}%',
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Text(
                        isPassed ? '🎉 Excellent!' : '💪 Good Effort!',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        isPassed
                            ? 'You passed the quiz! Great job!'
                            : 'You need 60% to pass. Keep practicing!',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                      if (_certificateIssued) ...[
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.card_giftcard,
                                color: Colors.white,
                                size: 28,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Certificate Earned!',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'You completed ${widget.mainLevel.name}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (!isPassed) ...[
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                            ),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.white,
                                size: 24,
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Complete this level to unlock the next one',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  Column(
                    children: [
                      if (!isPassed)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _retakeQuiz,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: widget.mainLevel.gradientColors[0],
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.replay),
                                SizedBox(width: 8),
                                Text(
                                  'Retake Quiz',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (!isPassed) const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: isPassed
                            ? ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).popUntil(
                                    (route) => route.isFirst,
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor:
                                      widget.mainLevel.gradientColors[0],
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
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
                              )
                            : OutlinedButton(
                                onPressed: () {
                                  Navigator.of(context).popUntil(
                                    (route) => route.isFirst,
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  side: const BorderSide(color: Colors.white),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
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
                      if (isPassed) ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Try Another Level',
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}