import 'package:flutter_test/flutter_test.dart';
import 'package:primerock_mining_companion/core/utils/mining_math.dart';

void main() {
  group('MiningMath.goldValue', () {
    test('calculates value from weight, purity and price', () {
      final value = MiningMath.goldValue(
        weightGrams: 10,
        purityFraction: 0.92,
        pricePerGram: 70,
      );
      expect(value, closeTo(644, 0.01));
    });
  });

  group('MiningMath.recoveryPercent', () {
    test('computes recovery from feed and tail', () {
      final r = MiningMath.recoveryPercent(feedGrade: 5, tailGrade: 1);
      expect(r, closeTo(80, 0.01));
    });

    test('throws when feed is zero', () {
      expect(
        () => MiningMath.recoveryPercent(feedGrade: 0, tailGrade: 0),
        throwsArgumentError,
      );
    });
  });

  group('MiningMath.oreGradeGpt', () {
    test('grams per tonne', () {
      expect(
        MiningMath.oreGradeGpt(goldGrams: 50, tonnes: 10),
        closeTo(5, 0.01),
      );
    });
  });

  group('MiningMath mass conversion', () {
    test('ounces to grams', () {
      expect(MiningMath.toGrams(1, 'oz'), closeTo(31.1034768, 0.0001));
    });

    test('kg to tonnes', () {
      final tonnes = MiningMath.convertMass(value: 1000, from: 'kg', to: 't');
      expect(tonnes, closeTo(1, 0.0001));
    });
  });

  group('MiningMath moisture', () {
    test('dry weight correction', () {
      expect(
        MiningMath.dryWeight(wetWeight: 100, moisturePercent: 10),
        closeTo(90, 0.01),
      );
    });
  });

  group('MiningMath ppm percent', () {
    test('round trip', () {
      expect(MiningMath.ppmToPercent(10000), 1);
      expect(MiningMath.percentToPpm(1), 10000);
    });
  });
}
