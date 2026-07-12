import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static final NumberFormat _number = NumberFormat('#,##0.##');
  static final NumberFormat _currencyUsd = NumberFormat.currency(
    symbol: '\$',
    decimalDigits: 2,
  );
  static final NumberFormat _currencyZig = NumberFormat.currency(
    symbol: 'ZiG ',
    decimalDigits: 2,
  );
  static final DateFormat _date = DateFormat('dd MMM yyyy');
  static final DateFormat _dateShort = DateFormat('dd/MM/yy');
  static final DateFormat _monthYear = DateFormat('MMMM yyyy');

  static String number(num value) => _number.format(value);
  static String usd(num value) => _currencyUsd.format(value);
  static String zig(num value) => _currencyZig.format(value);
  static String date(DateTime value) => _date.format(value);
  static String dateShort(DateTime value) => _dateShort.format(value);
  static String monthYear(DateTime value) => _monthYear.format(value);

  static String percent(num value, {int decimals = 2}) =>
      '${value.toStringAsFixed(decimals)}%';
}
