import 'package:flutter/foundation.dart';
import 'work_entry.dart';
import 'education_entry.dart';

@immutable
class CvModel {
  final String id; // Firestore doc id
  final String fullName;
  final String email;
  final String phone;
  final String location;
  final List<WorkEntry> workExperience;
  final List<EducationEntry> education;
  final List<String> skills;

  const CvModel({
    this.id = '',
    required this.fullName,
    required this.email,
    required this.phone,
    required this.location,
    required this.workExperience,
    required this.education,
    required this.skills,
  });

  CvModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phone,
    String? location,
    List<WorkEntry>? workExperience,
    List<EducationEntry>? education,
    List<String>? skills,
  }) {
    return CvModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      workExperience: workExperience ?? this.workExperience,
      education: education ?? this.education,
      skills: skills ?? this.skills,
    );
  }

  factory CvModel.fromMap(Map<String, dynamic> map, {String id = ''}) {
    return CvModel(
      id: id,
      fullName: (map['fullName'] ?? '').toString(),
      email: (map['email'] ?? '').toString(),
      phone: (map['phone'] ?? '').toString(),
      location: (map['location'] ?? '').toString(),
      workExperience:
          (map['workExperience'] as List<dynamic>? ?? [])
              .map(
                (e) => WorkEntry.fromMap(Map<String, dynamic>.from(e as Map)),
              )
              .toList(),
      education:
          (map['education'] as List<dynamic>? ?? [])
              .map(
                (e) =>
                    EducationEntry.fromMap(Map<String, dynamic>.from(e as Map)),
              )
              .toList(),
      skills:
          (map['skills'] as List<dynamic>? ?? [])
              .map((e) => e.toString())
              .toList(),
    );
  }

  /// Note: timestamps (createdAt/updatedAt) are set by the Firestore service
  /// using serverTimestamp(). We intentionally omit them here to avoid type
  /// mismatches.
  Map<String, dynamic> toMap() => {
    'fullName': fullName,
    'email': email,
    'phone': phone,
    'location': location,
    'workExperience': workExperience.map((e) => e.toMap()).toList(),
    'education': education.map((e) => e.toMap()).toList(),
    'skills': skills,
  };
}
