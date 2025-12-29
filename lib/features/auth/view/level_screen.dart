import 'package:codeup/mcq_qustions/questions.dart';
import 'package:flutter/material.dart';

// ============================================================================
// LEVEL SCREEN - Main Entry Point
// ============================================================================
class LevelScreen extends StatefulWidget {
  const LevelScreen({super.key});

  @override
  State<LevelScreen> createState() => _LevelScreenState();
}

class _LevelScreenState extends State<LevelScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // User progress (can be fetched from API or SharedPreferences)
  int unlockedLevel = 3; // User has unlocked up to level 3
  int currentLevel = 1; // User is currently on level 1

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();
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
              _buildHeader(context),
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildLevelsList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Header with progress overview
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const Expanded(
                child: Text(
                  'Choose Your Level',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.info_outline, color: Colors.white),
                onPressed: () => _showLevelInfo(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildProgressOverview(),
        ],
      ),
    );
  }

  // Progress overview card
  Widget _buildProgressOverview() {
    final totalLevels = _getLevels().length;
    final completedLevels = currentLevel - 1;
    final progress = completedLevels / totalLevels;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha:0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha:0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Your Progress',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$completedLevels / $totalLevels Completed',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha:0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // Levels list with scrolling
  Widget _buildLevelsList() {
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
        itemCount: _getLevels().length,
        itemBuilder: (context, index) {
          final level = _getLevels()[index];
          return _buildLevelCard(level, index);
        },
      ),
    );
  }

  // Individual level card
  Widget _buildLevelCard(_LevelData level, int index) {
    final isLocked = level.levelNumber > unlockedLevel;
    final isCompleted = level.levelNumber < currentLevel;
    final isCurrent = level.levelNumber == currentLevel;

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
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isLocked ? null : () => _startLevel(level),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isLocked
                      ? [Colors.grey[300]!, Colors.grey[400]!]
                      : level.gradientColors,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: (isLocked ? Colors.grey : level.gradientColors[0])
                        .withValues(alpha:0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Background pattern
                  Positioned(
                    right: -20,
                    top: -20,
                    child: Opacity(
                      opacity: 0.1,
                      child: Icon(level.icon, size: 100, color: Colors.white),
                    ),
                  ),
                  // Content
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha:0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              isLocked
                                  ? Icons.lock
                                  : (isCompleted
                                        ? Icons.check_circle
                                        : level.icon),
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
                                    Text(
                                      level.title,
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    if (isCurrent) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          'CURRENT',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: level.gradientColors[0],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  level.subtitle,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Divider(color: Colors.white.withValues(alpha:0.2)),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildLevelStat(
                            Icons.quiz,
                            '${level.questionCount} Questions',
                          ),
                          _buildLevelStat(
                            Icons.timer_outlined,
                            '${level.timeMinutes} min',
                          ),
                          _buildLevelStat(Icons.stars, '${level.xpReward} XP'),
                        ],
                      ),
                      if (!isLocked) ...[
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _startLevel(level),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: level.gradientColors[0],
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  isCompleted
                                      ? 'Play Again'
                                      : (isCurrent ? 'Continue' : 'Start'),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.arrow_forward, size: 18),
                              ],
                            ),
                          ),
                        ),
                      ],
                      if (isLocked) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha:0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.lock_outline,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Complete Level ${level.levelNumber - 1} to unlock',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
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
          ),
        ),
      ),
    );
  }

  Widget _buildLevelStat(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 16),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // Start level action
  void _startLevel(_LevelData level) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuestionScreen(
          levelNumber: level.levelNumber,
          language: level.language,
        ),
      ),
    );
  }

  // Show level info dialog
  void _showLevelInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.info, color: Color(0xFF667eea)),
            SizedBox(width: 8),
            Text('Level Guide'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoItem(
              '🟢 Basic',
              'Perfect for beginners\n5 questions, 10 minutes',
            ),
            const SizedBox(height: 12),
            _buildInfoItem(
              '🟡 Intermediate',
              'Ready for a challenge?\n7 questions, 15 minutes',
            ),
            const SizedBox(height: 12),
            _buildInfoItem(
              '🔴 Advanced',
              'For coding masters\n10 questions, 20 minutes',
            ),
            const SizedBox(height: 12),
            _buildInfoItem(
              '🏆 Expert',
              'Ultimate challenge\n15 questions, 30 minutes',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String title, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: const TextStyle(fontSize: 13, color: Colors.grey),
        ),
      ],
    );
  }

  // Get all levels with their configurations
  List<_LevelData> _getLevels() {
    return [
      _LevelData(
        levelNumber: 1,
        title: 'Level 1 - Basic',
        subtitle: 'Python Fundamentals',
        language: 'Python',
        questionCount: 5,
        timeMinutes: 10,
        xpReward: 50,
        difficulty: 'Easy',
        icon: Icons.code,
        gradientColors: const [Color(0xFF11998e), Color(0xFF38ef7d)],
      ),
      _LevelData(
        levelNumber: 2,
        title: 'Level 2 - Intermediate',
        subtitle: 'JavaScript Basics',
        language: 'JavaScript',
        questionCount: 7,
        timeMinutes: 15,
        xpReward: 100,
        difficulty: 'Medium',
        icon: Icons.javascript,
        gradientColors: const [Color(0xFF4facfe), Color(0xFF00f2fe)],
      ),
      _LevelData(
        levelNumber: 3,
        title: 'Level 3 - Advanced',
        subtitle: 'Data Structures & Algorithms',
        language: 'Python',
        questionCount: 10,
        timeMinutes: 20,
        xpReward: 200,
        difficulty: 'Hard',
        icon: Icons.psychology,
        gradientColors: const [Color(0xFFf093fb), Color(0xFFf5576c)],
      ),
      _LevelData(
        levelNumber: 4,
        title: 'Level 4 - Expert',
        subtitle: 'Advanced Problem Solving',
        language: 'Python',
        questionCount: 12,
        timeMinutes: 25,
        xpReward: 300,
        difficulty: 'Expert',
        icon: Icons.emoji_events,
        gradientColors: const [Color(0xFFfa709a), Color(0xFFfee140)],
      ),
      _LevelData(
        levelNumber: 5,
        title: 'Level 5 - Master',
        subtitle: 'Full Stack Mastery',
        language: 'Mixed',
        questionCount: 15,
        timeMinutes: 30,
        xpReward: 500,
        difficulty: 'Master',
        icon: Icons.stars,
        gradientColors: const [Color(0xFFFFD700), Color(0xFFFF8C00)],
      ),
    ];
  }
}

// ============================================================================
// LEVEL DATA MODEL
// ============================================================================
class _LevelData {
  final int levelNumber;
  final String title;
  final String subtitle;
  final String language;
  final int questionCount;
  final int timeMinutes;
  final int xpReward;
  final String difficulty;
  final IconData icon;
  final List<Color> gradientColors;

  _LevelData({
    required this.levelNumber,
    required this.title,
    required this.subtitle,
    required this.language,
    required this.questionCount,
    required this.timeMinutes,
    required this.xpReward,
    required this.difficulty,
    required this.icon,
    required this.gradientColors,
  });
}
