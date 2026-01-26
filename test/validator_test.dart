import 'package:flutter_test/flutter_test.dart';
import 'package:cv_helper_app/utils/date_validator.dart';

void main() {
  group('DateValidator', () {
    test('validates simple years', () {
      expect(DateValidator.validateDate('2020'), null);
      expect(DateValidator.validateDate('Jan 2023'), null);
      expect(DateValidator.validateDate('Present'), null);
    });

    test('rejects far future dates', () {
      final farFuture = DateTime.now().year + 10;
      expect(DateValidator.validateDate('Jan $farFuture'), contains('too far'));
    });

    test('rejects invalid inputs', () {
      expect(DateValidator.validateDate(''), 'Required');
      expect(
        DateValidator.validateDate('No year here'),
        contains('valid year'),
      );
    });

    test('validates ranges', () {
      expect(DateValidator.validateDateRange('2020', '2022'), null);
      expect(
        DateValidator.validateDateRange('2022', '2020'),
        contains('before start'),
      );
      expect(DateValidator.validateDateRange('2020', 'Present'), null);
    });
  });
}
