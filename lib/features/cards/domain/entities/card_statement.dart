import 'package:dynora_finance/core/enums/movement_type.dart';
import 'package:dynora_finance/core/utils/month_range.dart';
import 'package:dynora_finance/features/cards/domain/entities/billing_period.dart';
import 'package:dynora_finance/features/cards/domain/entities/card_entity.dart';
import 'package:dynora_finance/features/movements/domain/entities/movement_entity.dart';
import 'package:equatable/equatable.dart';

/// Movements of one billing period and the amount to pay for them.
class CardStatement extends Equatable {
  const CardStatement({required this.period, required this.movements});

  final BillingPeriod period;

  /// Sorted by date, newest first.
  final List<MovementEntity> movements;

  /// Expenses minus refunds/credits made with the card in the period.
  double get total => movements.fold(
    0,
    (sum, m) =>
        m.type == MovementType.expense ? sum + m.amount : sum - m.amount,
  );

  /// Groups [movements] of [card] by billing period, newest period first.
  ///
  /// The open period (containing [now]) is always included so the current
  /// balance is visible even before any purchase. Requires
  /// [CardEntity.hasBillingCycle].
  static List<CardStatement> build(
    CardEntity card,
    Iterable<MovementEntity> movements,
    DateTime now,
  ) {
    final byPeriod = <BillingPeriod, List<MovementEntity>>{
      card.billingPeriodFor(now): [],
    };
    for (final movement in movements) {
      if (movement.cardId != card.id) continue;
      byPeriod
          .putIfAbsent(card.billingPeriodFor(movement.date), () => [])
          .add(movement);
    }

    final statements = [
      for (final entry in byPeriod.entries)
        CardStatement(
          period: entry.key,
          movements: entry.value..sort((a, b) => b.date.compareTo(a.date)),
        ),
    ]..sort((a, b) => b.period.end.compareTo(a.period.end));
    return statements;
  }

  /// Statement of the next payment of [card] (see
  /// [CardEntity.upcomingPeriod]).
  static CardStatement upcoming(
    CardEntity card,
    Iterable<MovementEntity> movements,
    DateTime now,
  ) {
    final period = card.upcomingPeriod(now);
    return CardStatement(
      period: period,
      movements: [
        for (final m in movements)
          if (m.cardId == card.id && period.contains(m.date)) m,
      ],
    );
  }

  /// Statements of [card] paid with the salary of [month] (see
  /// [BillingPeriod.fundingMonth]); usually one, since cycles are monthly.
  static List<CardStatement> fundedIn(
    CardEntity card,
    Iterable<MovementEntity> movements,
    MonthRange month,
  ) {
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
            movements: [
              for (final m in movements)
                if (m.cardId == card.id && period.contains(m.date)) m,
            ],
          ),
        );
      }
      period = card.billingPeriodFor(
        DateTime(period.end.year, period.end.month, period.end.day + 1),
      );
    }
    return statements;
  }

  @override
  List<Object?> get props => [period, movements];
}

/// Next statement to pay of a credit or departmental card.
class UpcomingCardPayment extends Equatable {
  const UpcomingCardPayment({required this.card, required this.statement});

  final CardEntity card;
  final CardStatement statement;

  DateTime get dueDate => statement.period.paymentDate;

  double get amount => statement.total;

  /// Upcoming payment of every card with a billing cycle, soonest first.
  static List<UpcomingCardPayment> forCards(
    Iterable<CardEntity> cards,
    Iterable<MovementEntity> movements,
    DateTime now,
  ) {
    return [
      for (final card in cards)
        if (card.hasBillingCycle)
          UpcomingCardPayment(
            card: card,
            statement: CardStatement.upcoming(card, movements, now),
          ),
    ]..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  @override
  List<Object?> get props => [card, statement];
}
