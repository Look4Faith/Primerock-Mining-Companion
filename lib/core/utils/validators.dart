class Validators {
  Validators._();

  static String? requiredNumber(String? value, {String field = 'Value'}) {
    if (value == null || value.trim().isEmpty) {
      return '$field is required';
    }
    final parsed = double.tryParse(value.replaceAll(',', ''));
    if (parsed == null) return 'Enter a valid number';
    return null;
  }

  static String? positiveNumber(String? value, {String field = 'Value'}) {
    final base = requiredNumber(value, field: field);
    if (base != null) return base;
    final parsed = double.parse(value!.replaceAll(',', ''));
    if (parsed <= 0) return '$field must be greater than zero';
    return null;
  }

  static String? nonNegativeNumber(String? value, {String field = 'Value'}) {
    final base = requiredNumber(value, field: field);
    if (base != null) return base;
    final parsed = double.parse(value!.replaceAll(',', ''));
    if (parsed < 0) return '$field cannot be negative';
    return null;
  }

  static String? range(
    String? value, {
    required double min,
    required double max,
    String field = 'Value',
  }) {
    final base = requiredNumber(value, field: field);
    if (base != null) return base;
    final parsed = double.parse(value!.replaceAll(',', ''));
    if (parsed < min || parsed > max) {
      return '$field must be between $min and $max';
    }
    return null;
  }

  static double parse(String value) =>
      double.parse(value.trim().replaceAll(',', ''));
}
