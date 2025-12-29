import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final List<String> nameFilter;
  final String email;
  final String password;
  final DateTime createdAt;
  final int status;
  final int? userStartStage; // Quiz score (null if not attempted)
  final int totalXP; // Total XP available for the current level

  const UserModel({
    required this.uid,
    required this.name,
    required this.nameFilter,
    required this.email,
    required this.password,
    required this.createdAt,
    required this.status,
    this.userStartStage,
    this.totalXP = 10, // Default value
  });

  factory UserModel.fromJson(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String,
      name: map['name'] as String,
      nameFilter: List<String>.from(map['namefilter'] ?? []),
      email: map['email'] as String,
      password: map['password'] as String,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      status: map['status'] as int,
      userStartStage: map['userStartStage'] as int?,
      totalXP: map['totalXP'] as int? ?? 10,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'namefilter': nameFilter,
      'email': email,
      'password': password,
      'createdAt': Timestamp.fromDate(createdAt),
      'status': status,
      'userStartStage': userStartStage,
      'totalXP': totalXP,
    };
  }

  /// Create a copy of UserModel with updated fields
  UserModel copyWith({
    String? uid,
    String? name,
    List<String>? nameFilter,
    String? email,
    String? password,
    DateTime? createdAt,
    int? status,
    int? userStartStage,
    int? totalXP,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      nameFilter: nameFilter ?? this.nameFilter,
      email: email ?? this.email,
      password: password ?? this.password,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      userStartStage: userStartStage ?? this.userStartStage,
      totalXP: totalXP ?? this.totalXP,
    );
  }
}