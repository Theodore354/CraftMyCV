class DateValidator {
  /// Validates a date string (e.g. "Jan 2020", "2020", "Present").
  /// Returns null if valid, or error message.
  static String? validateDate(String? value) {
    if (value == null || value.trim().isEmpty) return 'Required';
    final v = value.trim().toLowerCase();
    if (v == 'present' || v == 'current') return null;

    // Extract year
    final yearRegExp = RegExp(r'\b(19|20)\d{2}\b');
    final match = yearRegExp.firstMatch(v);

    if (match == null) {
      return 'Please include a valid year (e.g. 2020)';
    }

    final year = int.parse(match.group(0)!);
    final currentYear = DateTime.now().year;

    // Rule: Date cannot be more than 7 years in future
    if (year > currentYear + 7) {
      return 'Date is too far in the future';
    }

    // Rule: Date cannot be ancient
    if (year < 1960) {
      return 'Year seems invalid';
    }

    return null;
  }

  /// Validates that end date is after start date
  static String? validateDateRange(String? start, String? end) {
    final startErr = validateDate(start);
    final endErr = validateDate(end);
    if (startErr != null) return null; // Let start validator handle it
    if (endErr != null) return endErr;

    if (end!.toLowerCase().contains('present')) return null;

    final yearRegExp = RegExp(r'\b(19|20)\d{2}\b');
    final startMatch = yearRegExp.firstMatch(start!);
    final endMatch = yearRegExp.firstMatch(end);

    if (startMatch != null && endMatch != null) {
      final sYear = int.parse(startMatch.group(0)!);
      final eYear = int.parse(endMatch.group(0)!);
      if (sYear > eYear) return 'End year cannot be before start';
    }
    return null;
  }
}
