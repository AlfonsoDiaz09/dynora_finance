import 'package:intl/intl.dart';

class Formatters {
  const Formatters._();

  static final NumberFormat _currency = NumberFormat.currency(
    locale: 'es_MX',
    symbol: '\$',
  );

  static final NumberFormat _currencyNoDecimals = NumberFormat.currency(
    locale: 'es_MX',
    symbol: '\$',
    decimalDigits: 0,
  );

  static const List<String> _months = [
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre',
  ];

  /// `$24,580.00`
  static String currency(double value) => _currency.format(value);

  /// `$24,580`
  static String currencyNoDecimals(double value) =>
      _currencyNoDecimals.format(value);

  /// `Febrero 2026`
  static String monthYear(DateTime date) =>
      '${_months[date.month - 1]} ${date.year}';

  /// `18 Feb`, adding the year when it is not the current one.
  static String shortDate(DateTime date, {DateTime? now}) {
    final current = now ?? DateTime.now();
    final label = '${date.day} ${_months[date.month - 1].substring(0, 3)}';
    return date.year == current.year ? label : '$label ${date.year}';
  }

  /// `Hoy`, `Ayer` or [shortDate].
  static String relativeDay(DateTime date, {DateTime? now}) {
    final current = now ?? DateTime.now();
    final today = DateTime(current.year, current.month, current.day);
    final day = DateTime(date.year, date.month, date.day);
    final difference = today.difference(day).inDays;
    if (difference == 0) return 'Hoy';
    if (difference == 1) return 'Ayer';
    return shortDate(date, now: current);
  }
}
