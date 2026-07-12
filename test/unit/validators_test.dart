import 'package:flutter_test/flutter_test.dart';
import 'package:primerock_mining_companion/core/utils/validators.dart';

void main() {
  group('Validators', () {
    test('requiredNumber rejects empty', () {
      expect(Validators.requiredNumber(''), isNotNull);
      expect(Validators.requiredNumber(null), isNotNull);
    });

    test('positiveNumber rejects zero', () {
      expect(Validators.positiveNumber('0'), isNotNull);
      expect(Validators.positiveNumber('1.5'), isNull);
    });

    test('range enforces bounds', () {
      expect(Validators.range('50', min: 0, max: 100), isNull);
      expect(Validators.range('150', min: 0, max: 100), isNotNull);
    });

    test('parse handles commas', () {
      expect(Validators.parse('1,250.5'), 1250.5);
    });
  });
}
