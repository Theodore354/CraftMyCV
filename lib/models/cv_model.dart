import 'package:cv_helper_app/models/index.dart';

class CvModel {
  /// Always required now (prevents null/empty bugs in Firestore).
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String location;
  final List<WorkEntry> workExperience;
  final List<EducationEntry> education;
  final List<String> skills;

  /// Optional timestamps (epoch ms)
  final int? createdAt;
  final int? updatedAt;

  CvModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.location,
    required this.workExperience,
    required this.education,
    required this.skills,
    this.createdAt,
    this.updatedAt,
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
    int? createdAt,
    int? updatedAt,
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
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'location': location,
      'workExperience': workExperience.map((w) => w.toJson()).toList(),
      'education': education.map((e) => e.toJson()).toList(),
      'skills': skills,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory CvModel.fromJson(Map<String, dynamic> json) {
    final workList =
        (json['workExperience'] as List<dynamic>?)
            ?.map((e) => WorkEntry.fromJson(e as Map<String, dynamic>))
            .toList() ??
        <WorkEntry>[];

    final eduList =
        (json['education'] as List<dynamic>?)
            ?.map((e) => EducationEntry.fromJson(e as Map<String, dynamic>))
            .toList() ??
        <EducationEntry>[];

    return CvModel(
      id: (json['id'] as String?) ?? _newId(), // fallback for old saves
      fullName: json['fullName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      location: json['location'] as String? ?? '',
      workExperience: workList,
      education: eduList,
      skills:
          (json['skills'] as List<dynamic>?)
              ?.map((s) => s.toString())
              .toList() ??
          <String>[],
      createdAt: json['createdAt'] as int?,
      updatedAt: json['updatedAt'] as int?,
    );
  }

  /// Fallback ID generator
  static String _newId() => DateTime.now().microsecondsSinceEpoch.toString();

  /// Helper: Create a new CV with auto-generated ID
  factory CvModel.ensureId({
    String? id,
    required String fullName,
    required String email,
    required String phone,
    required String location,
    required List<WorkEntry> workExperience,
    required List<EducationEntry> education,
    required List<String> skills,
    int? createdAt,
    int? updatedAt,
  }) {
    return CvModel(
      id: id ?? _newId(),
      fullName: fullName,
      email: email,
      phone: phone,
      location: location,
      workExperience: workExperience,
      education: education,
      skills: skills,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Plain text representation
  String toPlainText() {
    final buf = StringBuffer();
    buf.writeln('Name: $fullName');
    buf.writeln('Email: $email');
    buf.writeln('Phone: $phone');
    buf.writeln('Location: $location\n');

    if (workExperience.isNotEmpty) {
      buf.writeln('Work Experience');
      for (final w in workExperience) {
        buf.writeln(w.toPlainText());
        buf.writeln('');
      }
    }

    if (education.isNotEmpty) {
      buf.writeln('Education');
      for (final e in education) {
        buf.writeln(e.toPlainText());
        buf.writeln('');
      }
    }

    if (skills.isNotEmpty) {
      buf.writeln('Skills: ${skills.join(', ')}');
    }

    return buf.toString().trim();
  }
}
