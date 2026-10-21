/// A calendar month, used to query movements of one month.
class MonthRange {
  MonthRange(DateTime date) : start = DateTime(date.year, date.month);

  /// First instant of the month.
  final DateTime start;

  /// Last instant of the month (inclusive bound for queries).
  DateTime get end => DateTime(
    start.year,
    start.month + 1,
  ).subtract(const Duration(microseconds: 1));

  MonthRange get previous => MonthRange(DateTime(start.year, start.month - 1));

  MonthRange get next => MonthRange(DateTime(start.year, start.month + 1));

  bool contains(DateTime date) => !date.isBefore(start) && !date.isAfter(end);

  @override
  bool operator ==(Object other) => other is MonthRange && other.start == start;

  @override
  int get hashCode => start.hashCode;
}
