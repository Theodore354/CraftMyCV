// lib/cv_storage.dart
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CvStorage {
  static const String _prefsKey = 'saved_cvs';

  /// ValueNotifier so UI can react to changes automatically
  static final ValueNotifier<List<String>> savedCvs =
      ValueNotifier<List<String>>([]);

  /// Load saved CVs from SharedPreferences (call once at app startup)
  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(_prefsKey) ?? <String>[];
    savedCvs.value = stored;
  }

  /// Persist current list to SharedPreferences
  static Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsKey, savedCvs.value);
  }

  /// Add a CV (updates ValueNotifier and persists)
  static Future<void> add(String cv) async {
    savedCvs.value = List<String>.from(savedCvs.value)..add(cv);
    await _save();
  }

  /// Update an existing CV (by index)
  static Future<void> update(int index, String cv) async {
    if (index < 0 || index >= savedCvs.value.length) return;
    final updated = List<String>.from(savedCvs.value)..[index] = cv;
    savedCvs.value = updated;
    await _save();
  }

  /// Delete CV by index (updates ValueNotifier and persists)
  static Future<void> delete(int index) async {
    if (index < 0 || index >= savedCvs.value.length) return;
    final updated = List<String>.from(savedCvs.value)..removeAt(index);
    savedCvs.value = updated;
    await _save();
  }

  /// Clear all CVs (updates ValueNotifier and removes the key)
  static Future<void> clear() async {
    savedCvs.value = [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
  }
}
