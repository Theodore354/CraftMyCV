import 'package:flutter/foundation.dart';

@immutable
class PolishProfile {
  final String role;
  final String industry;
  final String seniority;
  final String tone;
  final List<String> options;

  const PolishProfile({
    required this.role,
    required this.industry,
    required this.seniority,
    required this.tone,
    this.options = const [],
  });

  Map<String, dynamic> toJson() => {
    'role': role,
    'industry': industry,
    'seniority': seniority,
    'tone': tone,
    'options': options,
  };
}
