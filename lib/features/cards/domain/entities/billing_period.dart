import 'package:dynora_finance/core/constants/income_schedule.dart' as schedule;
import 'package:dynora_finance/core/utils/month_range.dart';
import 'package:equatable/equatable.dart';

/// One statement period of a credit or departmental card.
///
/// Movements dated from [start] to [end] (both days inclusive) are paid on
/// [paymentDate].
class BillingPeriod extends Equatable {
  const BillingPeriod({
    required this.start,
    required this.end,
    required this.paymentDate,
  });

  /// First day of the period (a cutoff day).
  final DateTime start;

  /// Last day of the period (the day before the next cutoff).
  final DateTime end;
  final DateTime paymentDate;

  bool contains(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    return !day.isBefore(start) && !day.isAfter(end);
  }

  /// Still accumulating movements on [now].
  bool isOpen(DateTime now) => !_today(now).isAfter(end);

  /// Cut off and waiting for its payment date.
  bool isAwaitingPayment(DateTime now) =>
      _today(now).isAfter(end) && !_today(now).isAfter(paymentDate);

  /// Whole days from [now] until [paymentDate] (negative once past).
  int daysUntilPayment(DateTime now) {
    final today = _today(now);
    return DateTime.utc(
      paymentDate.year,
      paymentDate.month,
      paymentDate.day,
    ).difference(DateTime.utc(today.year, today.month, today.day)).inDays;
  }

  /// Month whose salary pays this period: the payment month, or the previous
  /// one when the payment is due before the salary arrives
  /// ([schedule.salaryLastDay]).
  MonthRange fundingMonth({int salaryLastDay = schedule.salaryLastDay}) {
    final month = MonthRange(paymentDate);
    return paymentDate.day <= salaryLastDay ? month.previous : month;
  }

  static DateTime _today(DateTime now) =>
      DateTime(now.year, now.month, now.day);

  @override
  List<Object?> get props => [start, end, paymentDate];
}
