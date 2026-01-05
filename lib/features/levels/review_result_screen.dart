import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codeup/features/levels/user_questions_screen.dart';
import 'package:flutter/material.dart';

import '../../utils/variables/global_variables.dart';
import 'model/mainlevel_model.dart';
import 'model/sublevel_model.dart';
import 'model/user_progress.dart';
import 'review_screen.dart';

class SubLevelScreen extends StatefulWidget {
  final String mainLevelId;
  final MainLevel mainLevel;

  const SubLevelScreen({
    required this.mainLevelId,
    required this.mainLevel,
  });

  @override
  State<SubLevelScreen> createState() => _SubLevelScreenState();
}

class _SubLevelScreenState extends State<SubLevelScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<SubLevel>> getSubLevels() async {
    try {
      final snapshot = await _db
          .collection('subLevels')
          .where('mainLevelId', isEqualTo: widget.mainLevelId)
          .orderBy('order')
          .get();
      return snapshot.docs.map((doc) => SubLevel.fromFirestore(doc)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<UserProgress> getUserProgress() async {
    try {
      final userId = globalUser?.uid;
      if (userId == null) return UserProgress(completedSubLevels: []);

      final doc = await _db.collection('userStatus').doc(userId).get();
      return doc.exists
          ? UserProgress.fromFirestore(doc)
          : UserProgress(completedSubLevels: []);
    } catch (e) {
      return UserProgress(completedSubLevels: []);
    }
  }

  bool isSubLevelUnlocked(List<SubLevel> subLevels, int index, UserProgress userProgress) {
    // First sublevel is always unlocked
    if (index == 0) return true;
    
    // Check if previous sublevel is completed
    final previousSubLevel = subLevels[index - 1];
    return userProgress.completedSubLevels.contains(previousSubLevel.id);
  }

  void _handleSubLevelTap(SubLevel subLevel, bool isCompleted, bool isUnlocked) async {
    if (!isUnlocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Complete the previous level first!'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (isCompleted) {
      // Show last attempt results
      final userId = globalUser?.uid;
      if (userId == null) return;

      try {
        final attemptsSnapshot = await _db
            .collection('userStatus')
            .doc(userId)
            .collection('quizAttempts')
            .where('subLevelId', isEqualTo: subLevel.id)
            .orderBy('attemptedAt', descending: true)
            .limit(1)
            .get();

        if (attemptsSnapshot.docs.isNotEmpty) {
          final attemptData = attemptsSnapshot.docs.first.data();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReviewResultScreen(
                subLevelId: subLevel.id,
                subLevelName: subLevel.name,
                mainLevel: widget.mainLevel,
                attemptData: attemptData,
              ),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error loading results')),
        );
      }
    } else {
      // Start quiz
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QuestionScreen(
            mainLevelId: widget.mainLevelId,
            subLevelId: subLevel.id,
            subLevelName: subLevel.name,
            mainLevel: widget.mainLevel,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.mainLevel.name),
        backgroundColor: widget.mainLevel.gradientColors[0],
        elevation: 0,
      ),
      body: FutureBuilder<List<SubLevel>>(
        future: getSubLevels(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No sub-levels available'));
          }

          return FutureBuilder<UserProgress>(
            future: getUserProgress(),
            builder: (context, progressSnapshot) {
              final userProgress = progressSnapshot.data ??
                  UserProgress(completedSubLevels: []);

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final subLevel = snapshot.data![index];
                  final isCompleted = userProgress.completedSubLevels
                      .contains(subLevel.id);
                  final isUnlocked = isSubLevelUnlocked(
                      snapshot.data!, index, userProgress);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GestureDetector(
                      onTap: () => _handleSubLevelTap(
                          subLevel, isCompleted, isUnlocked),
                      child: _buildSubLevelCard(
                        subLevel,
                        isCompleted,
                        isUnlocked,
                        widget.mainLevel,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSubLevelCard(
      SubLevel subLevel, bool isCompleted, bool isUnlocked, MainLevel mainLevel) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: !isUnlocked
              ? [Colors.grey[400]!, Colors.grey[500]!]
              : isCompleted
                  ? [Colors.green[300]!, Colors.green[500]!]
                  : mainLevel.gradientColors,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: mainLevel.gradientColors[0].withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Icon(
                        !isUnlocked
                            ? Icons.lock
                            : isCompleted
                                ? Icons.check_circle
                                : Icons.quiz,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                subLevel.name,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  decoration: !isUnlocked
                                      ? TextDecoration.none
                                      : null,
                                ),
                              ),
                            ),
                            if (isCompleted)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'Completed',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                            if (!isUnlocked)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'Locked',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Level ${subLevel.order}',
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
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStat(
                      Icons.quiz, '${subLevel.questionCount}', 'Questions'),
                  _buildStat(Icons.timer_outlined,
                      '${subLevel.timeMinutes}', 'Min'),
                  _buildStat(Icons.stars, '${subLevel.xpReward}', 'XP'),
                ],
              ),
            ],
          ),
          if (isCompleted)
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.visibility, color: Colors.white, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'View Results',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStat(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 10),
        ),
      ],
    );
  }
}