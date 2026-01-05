import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MainLevel {
  final String id;
  final String name;
  final String description;
  final int order;

  MainLevel({
    required this.id,
    required this.name,
    required this.description,
    required this.order,
  });

  factory MainLevel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MainLevel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      order: data['order'] ?? 0,
    );
  }

  List<Color> get gradientColors {
    switch (order) {
      case 1:
        return [const Color(0xFF11998e), const Color(0xFF38ef7d)];
      case 2:
        return [const Color(0xFF4facfe), const Color(0xFF00f2fe)];
      case 3:
        return [const Color(0xFFf093fb), const Color(0xFFf5576c)];
      default:
        return [const Color(0xFFfa709a), const Color(0xFFfee140)];
    }
  }

  IconData get icon {
    switch (order) {
      case 1:
        return Icons.code;
      case 2:
        return Icons.javascript;
      case 3:
        return Icons.psychology;
      default:
        return Icons.emoji_events;
    }
  }
}