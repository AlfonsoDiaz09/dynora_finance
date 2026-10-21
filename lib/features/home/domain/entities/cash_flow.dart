import 'package:dynora_finance/core/enums/movement_type.dart';
import 'package:dynora_finance/core/utils/month_range.dart';
import 'package:dynora_finance/features/cards/domain/entities/card_entity.dart';
import 'package:dynora_finance/features/cards/domain/entities/card_payment_entity.dart';
import 'package:dynora_finance/features/debts/domain/entities/debt_entity.dart';
import 'package:dynora_finance/features/loans/domain/entities/loan_entity.dart';
import 'package:dynora_finance/features/loans/domain/entities/loan_payment_entity.dart';
import 'package:dynora_finance/features/movements/domain/entities/movement_entity.dart';

/// Money that actually entered and left your accounts.
///
/// Purchases with credit or departmental cards don't move cash when made,
/// so they are excluded; the cash leaves when the card is paid, through the
/// registered [CardPaymentEntity]s. Cash, transfer and debit movements count
/// on their date, money people pay you back ([DebtEntity]) counts as income
/// on the day they paid, loans you receive count as income ([LoanEntity],
/// when the money entered your accounts) and their payments as expenses.
class CashFlow {
  const CashFlow({required this.income, required this.expense});

  factory CashFlow.of({
    required Iterable<MovementEntity> movements,
    required Iterable<CardEntity> cards,
    required Iterable<CardPaymentEntity> payments,
    Iterable<DebtEntity> debts = const [],
    Iterable<LoanEntity> loans = const [],
    Iterable<LoanPaymentEntity> loanPayments = const [],
    MonthRange? month,
  }) {
    final creditCardIds = {
      for (final card in cards)
        if (card.type.hasBillingCycle) card.id,
    };
    bool inRange(DateTime date) => month == null || month.contains(date);

    var income = 0.0;
    var expense = 0.0;
    for (final movement in movements) {
      if (!inRange(movement.date)) continue;
      if (creditCardIds.contains(movement.cardId)) continue;
      if (movement.type == MovementType.income) {
        income += movement.amount;
      } else {
        expense += movement.amount;
      }
    }
    for (final payment in payments) {
      if (inRange(payment.paidAt)) expense += payment.amount;
    }
    for (final debt in debts) {
      final paidAt = debt.paidAt;
      if (paidAt != null && inRange(paidAt)) income += debt.amount;
    }
    for (final loan in loans) {
      if (loan.countsAsIncome && inRange(loan.startDate)) {
        income += loan.principal;
      }
    }
    for (final payment in loanPayments) {
      if (inRange(payment.paidAt)) expense += payment.amount;
    }

    return CashFlow(income: income, expense: expense);
  }

  static const empty = CashFlow(income: 0, expense: 0);

  /// Incomes plus debts paid back to you.
  final double income;

  /// Cash and debit expenses plus card and loan payments.
  final double expense;

  double get balance => income - expense;
}
