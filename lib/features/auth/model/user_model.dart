import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String? uid;
  final String? name;
  final List<String>? nameFilter;
  final String? email;
  final String? password;
  final DateTime? createdAt;
  final int? status;
  final int? userStartStage;
  final int? totalXP;

  // Profile fields
  final String? mobileNumber;
  final String? dateOfBirth;
  final String? skillLevel;

  const UserModel({
    this.uid,
    this.name,
    this.nameFilter,
    this.email,
    this.password,
    this.createdAt,
    this.status,
    this.userStartStage,
    this.totalXP,
    this.mobileNumber,
    this.dateOfBirth,
    this.skillLevel,
  });

  factory UserModel.fromJson(Map<String, dynamic>? map) {
    if (map == null) return const UserModel();

    return UserModel(
      uid: map['uid']?.toString(),
      name: map['name']?.toString(),
      nameFilter: (map['namefilter'] as List?)
          ?.map((e) => e.toString())
          .toList(),
      email: map['email']?.toString(),
      password: map['password']?.toString(),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      status: map['status'] as int?,
      userStartStage: map['userStartStage'] as int?,
      totalXP: map['totalXP'] as int?,
      mobileNumber: map['mobileNumber']?.toString(),
      dateOfBirth: map['dateOfBirth']?.toString(),
      skillLevel: map['skillLevel']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (uid != null) 'uid': uid,
      if (name != null) 'name': name,
      if (nameFilter != null) 'namefilter': nameFilter,
      if (email != null) 'email': email,
      if (password != null) 'password': password,
      if (createdAt != null)
        'createdAt': Timestamp.fromDate(createdAt!),
      if (status != null) 'status': status,
      if (userStartStage != null) 'userStartStage': userStartStage,
      if (totalXP != null) 'totalXP': totalXP,
      if (mobileNumber != null) 'mobileNumber': mobileNumber,
      if (dateOfBirth != null) 'dateOfBirth': dateOfBirth,
      if (skillLevel != null) 'skillLevel': skillLevel,
    };
  }

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
    String? mobileNumber,
    String? dateOfBirth,
    String? skillLevel,
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
      mobileNumber: mobileNumber ?? this.mobileNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      skillLevel: skillLevel ?? this.skillLevel,
    );
  }
}
