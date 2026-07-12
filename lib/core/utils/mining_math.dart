class MiningMath {
  MiningMath._();

  /// Gold value from weight, purity fraction (0–1), and price per gram.
  static double goldValue({
    required double weightGrams,
    required double purityFraction,
    required double pricePerGram,
  }) =>
      weightGrams * purityFraction * pricePerGram;

  /// Recovery % = (feed − tail) / feed × 100
  static double recoveryPercent({
    required double feedGrade,
    required double tailGrade,
  }) {
    if (feedGrade <= 0) throw ArgumentError('Feed grade must be > 0');
    return ((feedGrade - tailGrade) / feedGrade) * 100;
  }

  /// Ore grade in g/t from gold grams and tonnes processed.
  static double oreGradeGpt({
    required double goldGrams,
    required double tonnes,
  }) {
    if (tonnes <= 0) throw ArgumentError('Tonnes must be > 0');
    return goldGrams / tonnes;
  }

  /// Simple cyanide dosage (kg NaCN / t ore) from target concentration & pulp.
  static double cyanideDosageKgPerTonne({
    required double targetPpm,
    required double moistureFraction,
  }) {
    // Approximation used in plant labs: dosage ≈ ppm × solution factor
    final solutionFactor = 1 + moistureFraction;
    return (targetPpm / 1000) * solutionFactor;
  }

  /// Slurry % solids from dry mass and total slurry mass.
  static double slurryPercentSolids({
    required double dryMass,
    required double totalMass,
  }) {
    if (totalMass <= 0) throw ArgumentError('Total mass must be > 0');
    return (dryMass / totalMass) * 100;
  }

  /// Acid/base volume estimate for pH adjustment (simplified plant formula).
  static double phAdjustmentVolumeLitres({
    required double currentPh,
    required double targetPh,
    required double slurryVolumeM3,
    required double strengthFactor,
  }) {
    final delta = (targetPh - currentPh).abs();
    return delta * slurryVolumeM3 * strengthFactor;
  }

  /// Moisture-corrected dry weight.
  static double dryWeight({
    required double wetWeight,
    required double moisturePercent,
  }) {
    return wetWeight * (1 - (moisturePercent / 100));
  }

  static double convertMass({
    required double value,
    required String from,
    required String to,
  }) {
    final grams = toGrams(value, from);
    return fromGrams(grams, to);
  }

  static double toGrams(double value, String unit) {
    switch (unit.toLowerCase()) {
      case 'g':
      case 'gram':
      case 'grams':
        return value;
      case 'kg':
      case 'kilogram':
      case 'kilograms':
        return value * 1000;
      case 't':
      case 'tonne':
      case 'tonnes':
        return value * 1e6;
      case 'oz':
      case 'ounce':
      case 'ounces':
        return value * 31.1034768;
      default:
        throw ArgumentError('Unsupported mass unit: $unit');
    }
  }

  static double fromGrams(double grams, String unit) {
    switch (unit.toLowerCase()) {
      case 'g':
      case 'gram':
      case 'grams':
        return grams;
      case 'kg':
      case 'kilogram':
      case 'kilograms':
        return grams / 1000;
      case 't':
      case 'tonne':
      case 'tonnes':
        return grams / 1e6;
      case 'oz':
      case 'ounce':
      case 'ounces':
        return grams / 31.1034768;
      default:
        throw ArgumentError('Unsupported mass unit: $unit');
    }
  }

  /// ppm ↔ %
  static double ppmToPercent(double ppm) => ppm / 10000;
  static double percentToPpm(double percent) => percent * 10000;
}
