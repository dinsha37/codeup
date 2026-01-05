import 'package:cloud_firestore/cloud_firestore.dart';

class UserProgress {
  final List<String> completedSubLevels;

  UserProgress({required this.completedSubLevels});

  factory UserProgress.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProgress(
      completedSubLevels: List<String>.from(data['completedSubLevels'] ?? []),
    );
  }
}