import 'package:dynora_finance/core/utils/month_range.dart';
import 'package:dynora_finance/features/cards/domain/entities/card_entity.dart';
import 'package:dynora_finance/features/cards/domain/entities/card_payment_entity.dart';
import 'package:dynora_finance/features/cards/domain/entities/card_statement.dart';
import 'package:dynora_finance/features/movements/domain/entities/movement_entity.dart';
import 'package:equatable/equatable.dart';

/// A card statement paid with the salary of the ledger's month.
class LedgerStatement extends Equatable {
  const LedgerStatement({required this.card, required this.statement});

  final CardEntity card;
  final CardStatement statement;

  @override
  List<Object?> get props => [card, statement];
}

/// What belongs to one month, following how each payment method is paid:
///
/// - Cash, transfers and debit cards: on the day they happen ([direct]).
/// - Credit and departmental cards: in the month whose salary pays their
///   statement ([BillingPeriod.fundingMonth]), with each installment in the
///   statement it lands in ([statements]).
///
/// Cash withdrawals are money in on their day; their charges are paid with
/// their statements like any other card charge.
class MonthLedger extends Equatable {
  const MonthLedger({
    required this.month,
    required this.direct,
    required this.statements,
  });

  factory MonthLedger.build({
    required MonthRange month,
    required Iterable<MovementEntity> movements,
    required Iterable<CardEntity> cards,
    required Iterable<CardPaymentEntity> cardPayments,
  }) {
    final billed = {
      for (final card in cards)
        if (card.hasBillingCycle) card.id: card,
    };

    final direct = [
      for (final m in movements)
        if (month.contains(m.date) &&
            (m.isCashWithdrawal || !billed.containsKey(m.cardId)))
          m,
    ]..sort((a, b) => b.date.compareTo(a.date));

    final statements =
        [
          for (final card in billed.values)
            for (final statement in CardStatement.fundedIn(
              card,
              movements,
              cardPayments,
              month,
            ))
              if (statement.charges.isNotEmpty)
                LedgerStatement(card: card, statement: statement),
        ]..sort(
          (a, b) => b.statement.period.paymentDate.compareTo(
            a.statement.period.paymentDate,
          ),
        );

    return MonthLedger(month: month, direct: direct, statements: statements);
  }

  static final empty = MonthLedger(
    month: MonthRange(DateTime(2000)),
    direct: const [],
    statements: const [],
  );

  final MonthRange month;

  /// Movements counted on their own date, newest first.
  final List<MovementEntity> direct;

  /// Card statements paid this month, latest payment first.
  final List<LedgerStatement> statements;

  /// Money in: incomes and cash withdrawals of the month.
  double get income => direct
      .where((m) => !m.isExpense || m.isCashWithdrawal)
      .fold(0, (sum, m) => sum + m.amount);

  /// Money out: direct expenses plus the card statements paid this month.
  double get expense =>
      direct
          .where((m) => m.isExpense && !m.isCashWithdrawal)
          .fold<double>(0, (sum, m) => sum + m.amount) +
      statements.fold<double>(0, (sum, s) => sum + s.statement.total);

  double get balance => income - expense;

  @override
  List<Object?> get props => [month, direct, statements];
}
