
class EducationEntry {
  final String degree;
  final String institution;
  final String start; // stored as "MMM yyyy" or "Present"
  final String end; // stored as "MMM yyyy" or "Present"
  final String? description; // optional notes

  EducationEntry({
    required this.degree,
    required this.institution,
    required this.start,
    required this.end,
    this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'degree': degree,
      'institution': institution,
      'start': start,
      'end': end,
      'description': description,
    };
  }

  factory EducationEntry.fromJson(Map<String, dynamic> json) {
    return EducationEntry(
      degree: json['degree'] as String? ?? '',
      institution: json['institution'] as String? ?? '',
      start: json['start'] as String? ?? '',
      end: json['end'] as String? ?? '',
      description: json['description'] as String?,
    );
  }

  /// Helpful plain-text representation (used for preview/printing)
  String toPlainText() {
    final desc =
        (description == null || description!.isEmpty) ? '' : '\n$description';
    return '$degree — $institution\n$start — $end$desc';
  }
}
