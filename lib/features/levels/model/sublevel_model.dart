import 'package:cloud_firestore/cloud_firestore.dart';

class SubLevel {
  final String id;
  final String mainLevelId;
  final String name;
  final int order;
  final int questionCount;
  final int timeMinutes;
  final int xpReward;

  SubLevel({
    required this.id,
    required this.mainLevelId,
    required this.name,
    required this.order,
    required this.questionCount,
    required this.timeMinutes,
    required this.xpReward,
  });

  factory SubLevel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SubLevel(
      id: doc.id,
      mainLevelId: data['mainLevelId'] ?? '',
      name: data['name'] ?? '',
      order: data['order'] ?? 0,
      questionCount: data['questionCount'] ?? 5,
      timeMinutes: data['timeMinutes'] ?? 10,
      xpReward: data['xpReward'] ?? 50,
    );
  }
}