import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../utils/variables/global_variables.dart';
import 'model/mainlevel_model.dart';
import 'review_result_screen.dart';

class UserLevelScreen extends StatefulWidget {
  const UserLevelScreen({super.key});

  @override
  State<UserLevelScreen> createState() => _UserLevelScreenState();
}

class _UserLevelScreenState extends State<UserLevelScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<MainLevel>> getMainLevels() async {
    try {
      final snapshot = await _db.collection('mainLevels').orderBy('order').get();
      return snapshot.docs.map((doc) => MainLevel.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  Future<Map<String, bool>> getMainLevelCompletionStatus(List<MainLevel> mainLevels) async {
    try {
      final userId = globalUser?.uid;
      if (userId == null) return {};

      final userDoc = await _db.collection('userStatus').doc(userId).get();
      final completedSubLevels = List<String>.from(userDoc.data()?['completedSubLevels'] ?? []);

      Map<String, bool> completionStatus = {};

      for (var mainLevel in mainLevels) {
        final subLevelsSnapshot = await _db
            .collection('subLevels')
            .where('mainLevelId', isEqualTo: mainLevel.id)
            .get();

        final allSubLevelIds = subLevelsSnapshot.docs.map((doc) => doc.id).toList();
        final isCompleted = allSubLevelIds.isNotEmpty &&
            allSubLevelIds.every((id) => completedSubLevels.contains(id));

        completionStatus[mainLevel.id] = isCompleted;
      }

      return completionStatus;
    } catch (e) {
      return {};
    }
  }

  bool isMainLevelUnlocked(List<MainLevel> mainLevels, int index, Map<String, bool> completionStatus) {
    // First main level is always unlocked
    if (index == 0) return true;

    // Check if previous main level is completed
    final previousMainLevel = mainLevels[index - 1];
    return completionStatus[previousMainLevel.id] ?? false;
  }

  void _handleMainLevelTap(MainLevel level, bool isUnlocked, bool isCompleted) {
    if (!isUnlocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('🔒 Complete the previous level first!'),
          backgroundColor: Colors.orange[700],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubLevelScreen(
          mainLevelId: level.id,
          mainLevel: level,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      'Select Your Level',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Complete levels to unlock new ones',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: FutureBuilder<List<MainLevel>>(
                  future: getMainLevels(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text(
                          'No levels available',
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }

                    final mainLevels = snapshot.data!;

                    return FutureBuilder<Map<String, bool>>(
                      future: getMainLevelCompletionStatus(mainLevels),
                      builder: (context, completionSnapshot) {
                        final completionStatus = completionSnapshot.data ?? {};

                        return Container(
                          decoration: const BoxDecoration(
                            color: Color(0xFFF5F7FA),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30),
                            ),
                          ),
                          child: ListView.builder(
                            padding: const EdgeInsets.all(20),
                            itemCount: mainLevels.length,
                            itemBuilder: (context, index) {
                              final level = mainLevels[index];
                              final isCompleted = completionStatus[level.id] ?? false;
                              final isUnlocked = isMainLevelUnlocked(mainLevels, index, completionStatus);

                              return TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0.0, end: 1.0),
                                duration: Duration(milliseconds: 400 + (index * 100)),
                                curve: Curves.easeOut,
                                builder: (context, value, child) {
                                  return Transform.translate(
                                    offset: Offset(0, 20 * (1 - value)),
                                    child: Opacity(opacity: value, child: child),
                                  );
                                },
                                child: GestureDetector(
                                  onTap: () => _handleMainLevelTap(level, isUnlocked, isCompleted),
                                  child: _buildLevelCard(level, isCompleted, isUnlocked),
                                ),
                              );
                            },
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

  Widget _buildLevelCard(MainLevel level, bool isCompleted, bool isUnlocked) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: !isUnlocked
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.grey[400]!, Colors.grey[500]!],
                )
              : isCompleted
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.green[400]!, Colors.green[600]!],
                    )
                  : LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: level.gradientColors,
                    ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: !isUnlocked
                  ? Colors.grey.withValues(alpha: 0.2)
                  : isCompleted
                      ? Colors.green.withValues(alpha: 0.3)
                      : level.gradientColors[0].withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background icon
            Positioned(
              right: -20,
              top: -20,
              child: Opacity(
                opacity: 0.1,
                child: Icon(
                  !isUnlocked
                      ? Icons.lock
                      : isCompleted
                          ? Icons.emoji_events
                          : level.icon,
                  size: 100,
                  color: Colors.white,
                ),
              ),
            ),
            // Main content
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        !isUnlocked
                            ? Icons.lock
                            : isCompleted
                                ? Icons.emoji_events
                                : level.icon,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  level.name,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              if (isCompleted)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                        size: 16,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Done',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              if (!isUnlocked)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.lock,
                                        color: Colors.grey,
                                        size: 16,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Locked',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            !isUnlocked
                                ? 'Complete previous level to unlock'
                                : level.description,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.white70,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (!isUnlocked) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.white,
                          size: 16,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Finish the previous level first',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (isCompleted) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.emoji_events,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Level Completed! Tap to review',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}