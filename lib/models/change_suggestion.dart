import 'package:flutter/foundation.dart';

@immutable
class ChangeSuggestion {
  final String id;
  final String scope; // e.g. "experience[0].bullets[2]"
  final String before;
  final String after;
  final String rationale;
  final bool accepted;

  const ChangeSuggestion({
    required this.id,
    required this.scope,
    required this.before,
    required this.after,
    required this.rationale,
    this.accepted = true,
  });

  ChangeSuggestion copyWith({bool? accepted}) => ChangeSuggestion(
    id: id,
    scope: scope,
    before: before,
    after: after,
    rationale: rationale,
    accepted: accepted ?? this.accepted,
  );

  factory ChangeSuggestion.fromJson(Map<String, dynamic> m) => ChangeSuggestion(
    id: m['id'] ?? '',
    scope: m['scope'] ?? '',
    before: m['before'] ?? '',
    after: m['after'] ?? '',
    rationale: m['rationale'] ?? '',
    accepted: (m['accepted'] as bool?) ?? true,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'scope': scope,
    'before': before,
    'after': after,
    'rationale': rationale,
    'accepted': accepted,
  };
}
