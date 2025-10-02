import 'package:flutter/foundation.dart';

@immutable
class EducationEntry {
  final String degree;
  final String institution;
  final String start;
  final String end;
  final String? description;

  const EducationEntry({
    required this.degree,
    required this.institution,
    required this.start,
    required this.end,
    this.description,
  });

  factory EducationEntry.fromMap(Map<String, dynamic> map) => EducationEntry(
    degree: (map['degree'] ?? '').toString(),
    institution: (map['institution'] ?? '').toString(),
    start: (map['start'] ?? '').toString(),
    end: (map['end'] ?? '').toString(),
    description: (map['description'] as String?),
  );

  Map<String, dynamic> toMap() => {
    'degree': degree,
    'institution': institution,
    'start': start,
    'end': end,
    if (description != null && description!.isNotEmpty)
      'description': description,
  };
}
