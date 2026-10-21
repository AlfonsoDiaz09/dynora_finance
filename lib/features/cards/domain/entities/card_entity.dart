import 'package:dynora_finance/features/cards/domain/entities/billing_period.dart';
import 'package:dynora_finance/features/cards/domain/entities/card_type.dart';
import 'package:equatable/equatable.dart';

class CardEntity extends Equatable {
  const CardEntity({
    required this.id,
    required this.name,
    required this.type,
    required this.lastFourDigits,
    this.cutoffDay,
    this.paymentDueDay,
    required this.colorValue,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final CardType type;
  final String lastFourDigits;

  /// Day of the month (1-31) the statement closes. `null` for debit cards.
  final int? cutoffDay;

  /// Day of the month (1-31) the statement must be paid. `null` for debit.
  final int? paymentDueDay;

  /// ARGB value of the card color.
  final int colorValue;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get hasBillingCycle =>
      type.hasBillingCycle && cutoffDay != null && paymentDueDay != null;

  /// Period that contains [date]. Only valid when [hasBillingCycle].
  ///
  /// A period starts on a cutoff day and ends the day before the next
  /// cutoff; it is paid on the first payment day on or after that next
  /// cutoff (it can be the cutoff day itself). Examples:
  /// - cutoff 29, payment 29: Sep 29 – Oct 28, paid Oct 29.
  /// - cutoff 2, payment 20: Sep 2 – Oct 1, paid Oct 20.
  ///
  /// Days past the end of a month are clamped to its last day (e.g. day 31
  /// in February).
  BillingPeriod billingPeriodFor(DateTime date) {
    assert(hasBillingCycle, 'Card $id has no billing cycle');
    final day = DateTime(date.year, date.month, date.day);
    final cutoffThisMonth = _dayIn(day.year, day.month, cutoffDay!);

    final DateTime start;
    final DateTime nextCutoff;
    if (day.isBefore(cutoffThisMonth)) {
      start = _dayIn(day.year, day.month - 1, cutoffDay!);
      nextCutoff = cutoffThisMonth;
    } else {
      start = cutoffThisMonth;
      nextCutoff = _dayIn(day.year, day.month + 1, cutoffDay!);
    }

    var payment = _dayIn(nextCutoff.year, nextCutoff.month, paymentDueDay!);
    if (payment.isBefore(nextCutoff)) {
      payment = _dayIn(nextCutoff.year, nextCutoff.month + 1, paymentDueDay!);
    }

    return BillingPeriod(
      start: start,
      end: DateTime(nextCutoff.year, nextCutoff.month, nextCutoff.day - 1),
      paymentDate: payment,
    );
  }

  /// Next payment on or after [now]: the closed period still waiting to be
  /// paid or, when there is none, the open period.
  BillingPeriod upcomingPeriod(DateTime now) {
    final open = billingPeriodFor(now);
    final previous = billingPeriodFor(
      DateTime(open.start.year, open.start.month, open.start.day - 1),
    );
    return previous.daysUntilPayment(now) >= 0 ? previous : open;
  }

  static DateTime _dayIn(int year, int month, int day) {
    final lastDay = DateTime(year, month + 1, 0).day;
    return DateTime(year, month, day > lastDay ? lastDay : day);
  }

  CardEntity copyWith({
    String? name,
    CardType? type,
    String? lastFourDigits,
    int? Function()? cutoffDay,
    int? Function()? paymentDueDay,
    int? colorValue,
  }) {
    return CardEntity(
      id: id,
      name: name ?? this.name,
      type: type ?? this.type,
      lastFourDigits: lastFourDigits ?? this.lastFourDigits,
      cutoffDay: cutoffDay != null ? cutoffDay() : this.cutoffDay,
      paymentDueDay: paymentDueDay != null
          ? paymentDueDay()
          : this.paymentDueDay,
      colorValue: colorValue ?? this.colorValue,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    type,
    lastFourDigits,
    cutoffDay,
    paymentDueDay,
    colorValue,
    createdAt,
    updatedAt,
  ];
}
