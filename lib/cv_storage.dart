import 'package:shared_preferences/shared_preferences.dart';

class CvStorage {
  static const _key = 'saved_cvs';
  static List<String> savedCvs = [];

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    savedCvs = prefs.getStringList(_key) ?? [];
  }

  static Future<void> add(String cv) async {
    savedCvs.add(cv);
    await _saveAll();
  }

  static Future<void> removeAt(int index) async {
    savedCvs.removeAt(index);
    await _saveAll();
  }

  static Future<void> clear() async {
    savedCvs.clear();
    await _saveAll();
  }

  static Future<void> _saveAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, savedCvs);
  }
}
