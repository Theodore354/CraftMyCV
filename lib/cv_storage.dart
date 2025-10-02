import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Lightweight local store for plain-text CV drafts (e.g., AI-polished text).
/// NOTE: Data is keyed by user so switching accounts won't mix drafts.
class CvStorage {
  static const _ns = 'saved_cvs_v2'; // new namespace (v2) for per-user scoping
  static const _legacyKey = 'saved_cvs_v1'; // your previous global key
  static const int _maxItems = 100;

  /// Live list of drafts for the *currently loaded user* (newest first).
  static final ValueNotifier<List<String>> savedCvs =
      ValueNotifier<List<String>>(<String>[]);

  static String _key(String? uid) => '${_ns}_${uid ?? 'anon'}';

  /// Load drafts for the given user.
  /// Call this on app start and whenever auth user changes.
  static Future<void> load({String? uid}) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _key(uid);

    // Migrate legacy global list -> current user's scoped key (once).
    if (!prefs.containsKey(key) && prefs.containsKey(_legacyKey)) {
      final legacy = prefs.getStringList(_legacyKey) ?? const <String>[];
      await prefs.setStringList(key, legacy);
      // Remove legacy to avoid double-loading in the future.
      await prefs.remove(_legacyKey);
    }

    final list = prefs.getStringList(key) ?? const <String>[];
    savedCvs.value = List<String>.from(list);
  }

  /// Add a draft (puts it at the top, removes duplicates, trims to max).
  static Future<void> add(String cvText, {String? uid}) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _key(uid);
    final existing = prefs.getStringList(key) ?? const <String>[];

    final next = <String>[cvText, ...existing.where((e) => e != cvText)];
    if (next.length > _maxItems) next.removeRange(_maxItems, next.length);

    await prefs.setStringList(key, next);
    savedCvs.value = next;
  }

  /// Remove a specific draft by value.
  static Future<void> remove(String cvText, {String? uid}) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _key(uid);
    final existing = prefs.getStringList(key) ?? const <String>[];

    final next = List<String>.from(existing)..removeWhere((e) => e == cvText);
    await prefs.setStringList(key, next);
    savedCvs.value = next;
  }

  /// Replace all drafts (keeps at most [_maxItems]).
  static Future<void> replaceAll(List<String> items, {String? uid}) async {
    final prefs = await SharedPreferences.getInstance();
    final trimmed = items.take(_maxItems).toList();
    await prefs.setStringList(_key(uid), trimmed);
    savedCvs.value = trimmed;
  }

  /// Clear drafts for this user.
  static Future<void> clear({String? uid}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key(uid));
    savedCvs.value = const <String>[];
  }
}
