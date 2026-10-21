import 'package:dynora_finance/core/enums/movement_type.dart';
import 'package:dynora_finance/core/utils/month_range.dart';
import 'package:dynora_finance/features/cards/domain/entities/billing_period.dart';
import 'package:dynora_finance/features/cards/domain/entities/card_entity.dart';
import 'package:dynora_finance/features/cards/domain/entities/card_payment_entity.dart';
import 'package:dynora_finance/features/movements/domain/entities/movement_entity.dart';
import 'package:equatable/equatable.dart';

enum StatementStatus {
  /// Starts after today; only holds upcoming installments.
  future,

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

/// What one movement adds to one statement: the full amount, or one
/// installment of a purchase in monthly installments.
class StatementCharge extends Equatable {
  const StatementCharge({
    required this.movement,
    required this.amount,
    this.installmentNumber = 1,
  });

  final MovementEntity movement;

  /// Charged amount (positive); refunds and credits subtract from totals.
  final double amount;

  /// 1-based number of the installment; 1 for single charges.
  final int installmentNumber;

  bool get isInstallment => movement.hasInstallments;

  /// Signed contribution to the statement total.
  double get signedAmount =>
      movement.type == MovementType.expense ? amount : -amount;

  @override
  List<Object?> get props => [movement, amount, installmentNumber];
}

/// Charges of one billing period, the amount to pay and its payment.
class CardStatement extends Equatable {
  const CardStatement({
    required this.period,
    required this.charges,
    this.payment,
  });

  /// Amounts below this are treated as zero (rounding of cents).
  static const double _epsilon = 0.005;

  final BillingPeriod period;

  /// Sorted by purchase date, newest first.
  final List<StatementCharge> charges;

  /// Registered payment of this statement, if any.
  final CardPaymentEntity? payment;

  /// Charges minus refunds/credits made with the card in the period.
  double get total => charges.fold(0, (sum, c) => sum + c.signedAmount);

  double get paidAmount => payment?.amount ?? 0;

  /// Amount still to pay (never negative).
  double get remaining {
    final value = total - paidAmount;
    return value > _epsilon ? value : 0;
  }

  StatementStatus status(DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    if (period.start.isAfter(today)) return StatementStatus.future;
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

  /// Statements of [card], newest period first, attaching the matching
  /// entry of [payments].
  ///
  /// Covers every period from the oldest charge up to the open period
  /// (containing [now]) or the last pending installment, including periods
  /// without charges, so they can be browsed as a continuous filter.
  /// Requires [CardEntity.hasBillingCycle].
  static List<CardStatement> build(
    CardEntity card,
    Iterable<MovementEntity> movements,
    Iterable<CardPaymentEntity> payments,
    DateTime now,
  ) {
    final byPeriod = _chargesByPeriod(card, movements);

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
      period = _next(card, period)
    ) {
      statements.add(
        CardStatement(
          period: period,
          charges: byPeriod[period] ?? const [],
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
      charges: _chargesByPeriod(card, movements)[period] ?? const [],
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
    final byPeriod = _chargesByPeriod(card, movements);
    final statements = <CardStatement>[];
    // A payment lands up to ~2 months after its period starts, so walk the
    // periods from two months before [month] until the month after it.
    var period = card.billingPeriodFor(month.previous.previous.start);
    final last = month.next.end;
    while (!period.start.isAfter(last)) {
      if (period.fundingMonth() == month) {
        statements.add(
          CardStatement(
            period: period,
            charges: byPeriod[period] ?? const [],
            payment: _paymentFor(card, period, payments),
          ),
        );
      }
      period = _next(card, period);
    }
    return statements;
  }

  /// Charges of every movement of [card] grouped by the period they land
  /// in; installments spread over consecutive periods starting with the one
  /// of the purchase.
  static Map<BillingPeriod, List<StatementCharge>> _chargesByPeriod(
    CardEntity card,
    Iterable<MovementEntity> movements,
  ) {
    final byPeriod = <BillingPeriod, List<StatementCharge>>{};
    for (final movement in movements) {
      if (movement.cardId != card.id) continue;
      var period = card.billingPeriodFor(movement.date);
      final amounts = movement.installmentAmounts;
      for (var i = 0; i < amounts.length; i++) {
        byPeriod
            .putIfAbsent(period, () => [])
            .add(
              StatementCharge(
                movement: movement,
                amount: amounts[i],
                installmentNumber: i + 1,
              ),
            );
        period = _next(card, period);
      }
    }
    for (final charges in byPeriod.values) {
      charges.sort((a, b) => b.movement.date.compareTo(a.movement.date));
    }
    return byPeriod;
  }

  static BillingPeriod _next(CardEntity card, BillingPeriod period) =>
      card.billingPeriodFor(
        DateTime(period.end.year, period.end.month, period.end.day + 1),
      );

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
  List<Object?> get props => [period, charges, payment];
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
