import 'package:dynora_finance/core/enums/movement_type.dart';
import 'package:dynora_finance/core/utils/month_range.dart';
import 'package:dynora_finance/features/cards/domain/entities/card_entity.dart';
import 'package:dynora_finance/features/cards/domain/entities/card_payment_entity.dart';
import 'package:dynora_finance/features/cards/domain/entities/card_statement.dart';
import 'package:dynora_finance/features/debts/domain/entities/debt_entity.dart';
import 'package:dynora_finance/features/home/domain/entities/cash_flow.dart';
import 'package:dynora_finance/features/loans/domain/entities/loan_entity.dart';
import 'package:dynora_finance/features/loans/domain/entities/loan_payment_entity.dart';
import 'package:dynora_finance/features/movements/domain/entities/movement_entity.dart';

/// How much you can spend right now: your money minus what you already
/// owe on cards.
///
/// Card charges are deducted as soon as they are incurred (the purchase, or
/// the start of the period of each later installment) instead of when the
/// statement is paid; paying a statement then doesn't change [available],
/// because its debt was already deducted.
class SpendingOverview {
  const SpendingOverview({
    required this.cash,
    required this.cardDebt,
    required this.futureInstallments,
    required this.monthIncome,
    required this.monthExpense,
  });

  factory SpendingOverview.of({
    required Iterable<MovementEntity> movements,
    required Iterable<CardEntity> cards,
    required Iterable<CardPaymentEntity> cardPayments,
    Iterable<DebtEntity> debts = const [],
    Iterable<LoanEntity> loans = const [],
    Iterable<LoanPaymentEntity> loanPayments = const [],
    required DateTime now,
  }) {
    final today = DateTime(now.year, now.month, now.day);
    final month = MonthRange(now);

    final cashFlow = CashFlow.of(
      movements: movements,
      cards: cards,
      payments: cardPayments,
      debts: debts,
      loans: loans,
      loanPayments: loanPayments,
    );
    final monthCashFlow = CashFlow.of(
      movements: movements,
      cards: cards,
      payments: cardPayments,
      debts: debts,
      loans: loans,
      loanPayments: loanPayments,
      month: month,
    );

    var cardDebt = 0.0;
    var future = 0.0;
    var monthCardCharges = 0.0;

    for (final card in cards) {
      if (!card.type.hasBillingCycle) continue;

      if (!card.hasBillingCycle) {
        // Credit card without cutoff/payment days: no statements to pay, so
        // each purchase counts as owed (and spent) on its date.
        for (final m in movements) {
          if (m.cardId != card.id || m.date.isAfter(now)) continue;
          final amount = _signed(m, m.totalWithInterest);
          cardDebt += amount;
          if (month.contains(m.date)) monthCardCharges += amount;
        }
        continue;
      }

      for (final statement in CardStatement.build(
        card,
        movements,
        cardPayments,
        now,
      )) {
        if (statement.period.start.isAfter(today)) {
          future += statement.total;
          continue;
        }
        cardDebt += statement.remaining;
        for (final charge in statement.charges) {
          // The first charge is incurred on the purchase; later
          // installments when their period starts.
          final incurredOn = charge.installmentNumber == 1
              ? charge.movement.date
              : statement.period.start;
          if (month.contains(incurredOn) && !incurredOn.isAfter(now)) {
            monthCardCharges += charge.signedAmount;
          }
        }
      }
    }

    final monthCardPayments = cardPayments
        .where((p) => month.contains(p.paidAt))
        .fold<double>(0, (sum, p) => sum + p.amount);

    return SpendingOverview(
      cash: cashFlow.balance,
      cardDebt: cardDebt,
      futureInstallments: future,
      monthIncome: monthCashFlow.income,
      // Card payments settle debt already counted when it was incurred.
      monthExpense:
          monthCashFlow.expense - monthCardPayments + monthCardCharges,
    );
  }

  static double _signed(MovementEntity movement, double amount) =>
      movement.type == MovementType.expense ? amount : -amount;

  static const empty = SpendingOverview(
    cash: 0,
    cardDebt: 0,
    futureInstallments: 0,
    monthIncome: 0,
    monthExpense: 0,
  );

  /// Money in your accounts (incomes minus what actually left them).
  final double cash;

  /// Unpaid card charges of periods already started (interest included).
  final double cardDebt;

  /// Installments of later periods, not deducted yet.
  final double futureInstallments;

  /// What came in this month.
  final double monthIncome;

  /// What you spent this month, card purchases included when incurred.
  final double monthExpense;

  /// What you can still spend.
  double get available => cash - cardDebt;
}
