import 'package:dynora_finance/core/enums/movement_type.dart';
import 'package:dynora_finance/core/utils/month_range.dart';
import 'package:dynora_finance/features/cards/domain/entities/billing_period.dart';
import 'package:dynora_finance/features/cards/domain/entities/card_entity.dart';
import 'package:dynora_finance/features/cards/domain/entities/card_payment_entity.dart';
import 'package:dynora_finance/features/movements/domain/entities/movement_entity.dart';
import 'package:equatable/equatable.dart';

enum StatementStatus {
  /// Still accumulating movements.
  open,

  /// Cut off, unpaid and the payment date has not passed.
  pending,

  /// Unpaid (or partially paid) after its payment date.
  overdue,

  /// Fully paid.
  paid,

  /// Closed without anything to pay.
  nothingToPay,
}

/// Movements of one billing period, the amount to pay and its payment.
class CardStatement extends Equatable {
  const CardStatement({
    required this.period,
    required this.movements,
    this.payment,
  });

  /// Amounts below this are treated as zero (rounding of cents).
  static const double _epsilon = 0.005;

  final BillingPeriod period;

  /// Sorted by date, newest first.
  final List<MovementEntity> movements;

  /// Registered payment of this statement, if any.
  final CardPaymentEntity? payment;

  /// Expenses minus refunds/credits made with the card in the period.
  double get total => movements.fold(
    0,
    (sum, m) =>
        m.type == MovementType.expense ? sum + m.amount : sum - m.amount,
  );

  double get paidAmount => payment?.amount ?? 0;

  /// Amount still to pay (never negative).
  double get remaining {
    final value = total - paidAmount;
    return value > _epsilon ? value : 0;
  }

  StatementStatus status(DateTime now) {
    if (payment == null && total <= _epsilon) {
      return period.isOpen(now)
          ? StatementStatus.open
          : StatementStatus.nothingToPay;
    }
    if (remaining == 0) return StatementStatus.paid;
    if (period.isOpen(now)) return StatementStatus.open;
    if (period.daysUntilPayment(now) >= 0) return StatementStatus.pending;
    return StatementStatus.overdue;
  }

  /// Groups [movements] of [card] by billing period, newest period first,
  /// attaching the matching entry of [payments].
  ///
  /// Covers every period from the oldest movement up to the open period
  /// (containing [now]) or the newest movement, including periods without
  /// movements, so they can be browsed as a continuous filter. Requires
  /// [CardEntity.hasBillingCycle].
  static List<CardStatement> build(
    CardEntity card,
    Iterable<MovementEntity> movements,
    Iterable<CardPaymentEntity> payments,
    DateTime now,
  ) {
    final byPeriod = <BillingPeriod, List<MovementEntity>>{};
    for (final movement in movements) {
      if (movement.cardId != card.id) continue;
      byPeriod
          .putIfAbsent(card.billingPeriodFor(movement.date), () => [])
          .add(movement);
    }

    final open = card.billingPeriodFor(now);
    var first = open;
    var last = open;
    for (final period in byPeriod.keys) {
      if (period.start.isBefore(first.start)) first = period;
      if (period.start.isAfter(last.start)) last = period;
    }

    final statements = <CardStatement>[];
    for (
      var period = first;
      !period.start.isAfter(last.start);
      period = card.billingPeriodFor(
        DateTime(period.end.year, period.end.month, period.end.day + 1),
      )
    ) {
      statements.add(
        CardStatement(
          period: period,
          movements: (byPeriod[period] ?? [])
            ..sort((a, b) => b.date.compareTo(a.date)),
          payment: _paymentFor(card, period, payments),
        ),
      );
    }
    return statements.reversed.toList();
  }

  /// Statement of [period] of [card].
  static CardStatement of(
    CardEntity card,
    BillingPeriod period,
    Iterable<MovementEntity> movements,
    Iterable<CardPaymentEntity> payments,
  ) {
    return CardStatement(
      period: period,
      movements: [
        for (final m in movements)
          if (m.cardId == card.id && period.contains(m.date)) m,
      ]..sort((a, b) => b.date.compareTo(a.date)),
      payment: _paymentFor(card, period, payments),
    );
  }

  /// Statements of [card] paid with the salary of [month] (see
  /// [BillingPeriod.fundingMonth]); usually one, since cycles are monthly.
  static List<CardStatement> fundedIn(
    CardEntity card,
    Iterable<MovementEntity> movements,
    Iterable<CardPaymentEntity> payments,
    MonthRange month,
  ) {
    final statements = <CardStatement>[];
    // A payment lands up to ~2 months after its period starts, so walk the
    // periods from two months before [month] until the month after it.
    var period = card.billingPeriodFor(month.previous.previous.start);
    final last = month.next.end;
    while (!period.start.isAfter(last)) {
      if (period.fundingMonth() == month) {
        statements.add(of(card, period, movements, payments));
      }
      period = card.billingPeriodFor(
        DateTime(period.end.year, period.end.month, period.end.day + 1),
      );
    }
    return statements;
  }

  static CardPaymentEntity? _paymentFor(
    CardEntity card,
    BillingPeriod period,
    Iterable<CardPaymentEntity> payments,
  ) {
    for (final payment in payments) {
      if (payment.cardId == card.id && payment.periodStart == period.start) {
        return payment;
      }
    }
    return null;
  }

  @override
  List<Object?> get props => [period, movements, payment];
}

/// A statement of a credit or departmental card that still needs paying.
class UpcomingCardPayment extends Equatable {
  const UpcomingCardPayment({required this.card, required this.statement});

  final CardEntity card;
  final CardStatement statement;

  DateTime get dueDate => statement.period.paymentDate;

  /// Amount still to pay.
  double get amount => statement.remaining;

  /// Statements to pay across [cards]: every overdue one plus the next
  /// payment of each card ([CardEntity.upcomingPeriod]), skipping those
  /// already paid or with nothing to pay. Overdue first, then by due date.
  static List<UpcomingCardPayment> pending(
    Iterable<CardEntity> cards,
    Iterable<MovementEntity> movements,
    Iterable<CardPaymentEntity> payments,
    DateTime now,
  ) {
    final result = <UpcomingCardPayment>[];
    for (final card in cards) {
      if (!card.hasBillingCycle) continue;
      final upcoming = card.upcomingPeriod(now);
      for (final statement in CardStatement.build(
        card,
        movements,
        payments,
        now,
      )) {
        if (statement.remaining == 0) continue;
        final status = statement.status(now);
        if (status == StatementStatus.overdue || statement.period == upcoming) {
          result.add(UpcomingCardPayment(card: card, statement: statement));
        }
      }
    }
    return result..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  @override
  List<Object?> get props => [card, statement];
}
