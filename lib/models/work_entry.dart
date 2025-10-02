import 'package:flutter/foundation.dart';

@immutable
class WorkEntry {
  final String jobTitle;
  final String company;
  final String start;
  final String end;
  final String? responsibilities;

  const WorkEntry({
    required this.jobTitle,
    required this.company,
    required this.start,
    required this.end,
    this.responsibilities,
  });

  factory WorkEntry.fromMap(Map<String, dynamic> map) => WorkEntry(
    jobTitle: (map['jobTitle'] ?? '').toString(),
    company: (map['company'] ?? '').toString(),
    start: (map['start'] ?? '').toString(),
    end: (map['end'] ?? '').toString(),
    responsibilities: map['responsibilities'] as String?,
  );

  Map<String, dynamic> toMap() => {
    'jobTitle': jobTitle,
    'company': company,
    'start': start,
    'end': end,
    if (responsibilities != null && responsibilities!.isNotEmpty)
      'responsibilities': responsibilities,
  };
}
