
class WorkEntry {
  final String jobTitle;
  final String company;
  final String start;
  final String end;
  final String? responsibilities; 

  WorkEntry({
    required this.jobTitle,
    required this.company,
    required this.start,
    required this.end,
    this.responsibilities,
  });

  Map<String, dynamic> toJson() {
    return {
      'jobTitle': jobTitle,
      'company': company,
      'start': start,
      'end': end,
      'responsibilities': responsibilities,
    };
  }

  factory WorkEntry.fromJson(Map<String, dynamic> json) {
    return WorkEntry(
      jobTitle: json['jobTitle'] as String? ?? '',
      company: json['company'] as String? ?? '',
      start: json['start'] as String? ?? '',
      end: json['end'] as String? ?? '',
      responsibilities: json['responsibilities'] as String?,
    );
  }

  String toPlainText() {
    final resp =
        (responsibilities == null || responsibilities!.isEmpty)
            ? ''
            : '\n$responsibilities';
    return '$jobTitle — $company\n$start — $end$resp';
  }
}
