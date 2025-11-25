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

  // ✅ NEW: templateId saved from templates flow
  final String templateId;

  const CvModel({
    this.id = '',
    required this.fullName,
    required this.email,
    required this.phone,
    required this.location,
    required this.workExperience,
    required this.education,
    required this.skills,
    this.templateId = 'default', // safe default
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
    String? templateId,
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
      templateId: templateId ?? this.templateId,
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

      // ✅ NEW: read templateId from firestore (if missing -> default)
      templateId: (map['templateId'] ?? 'default').toString(),
    );
  }

  /// Note: timestamps (createdAt/updatedAt) are set by Firestore service
  Map<String, dynamic> toMap() => {
    'fullName': fullName,
    'email': email,
    'phone': phone,
    'location': location,
    'workExperience': workExperience.map((e) => e.toMap()).toList(),
    'education': education.map((e) => e.toMap()).toList(),
    'skills': skills,

    // ✅ NEW: write templateId
    'templateId': templateId,
  };
}
