import 'package:dynora_finance/core/utils/month_range.dart';
import 'package:dynora_finance/features/cards/domain/entities/card_entity.dart';
import 'package:dynora_finance/features/cards/domain/entities/card_payment_entity.dart';
import 'package:dynora_finance/features/cards/domain/entities/card_statement.dart';
import 'package:dynora_finance/features/loans/domain/entities/loan_entity.dart';
import 'package:dynora_finance/features/loans/domain/entities/loan_payment_entity.dart';
import 'package:dynora_finance/features/loans/domain/entities/loan_summary.dart';
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

/// A loan payment due this month: one you make or one you collect.
class LedgerLoanInstallment extends Equatable {
  const LedgerLoanInstallment({
    required this.loan,
    required this.installment,
    required this.installmentCount,
  });

  final LoanEntity loan;

  /// The installment and how much of it is already covered.
  final InstallmentState installment;
  final int installmentCount;

  /// Money that comes in (a loan you made) instead of going out.
  bool get isIncome => loan.isLent;
  double get amount => installment.installment.amount;
  DateTime get dueDate => installment.installment.dueDate;

  @override
  List<Object?> get props => [loan, installment, installmentCount];
}

/// What belongs to one month, following how each payment method is paid:
///
/// - Cash, transfers and debit cards: on the day they happen ([direct]).
/// - Credit and departmental cards: in the month whose salary pays their
///   statement ([BillingPeriod.fundingMonth]), with each installment in the
///   statement it lands in ([statements]).
///
/// - Loans with a payment calendar: each installment on its due date
///   ([loanInstallments]); money out when you owe it, in when you lent it.
///
/// Cash withdrawals are money in on their day; their charges are paid with
/// their statements like any other card charge.
class MonthLedger extends Equatable {
  const MonthLedger({
    required this.month,
    required this.direct,
    required this.statements,
    this.loanInstallments = const [],
  });

  factory MonthLedger.build({
    required MonthRange month,
    required Iterable<MovementEntity> movements,
    required Iterable<CardEntity> cards,
    required Iterable<CardPaymentEntity> cardPayments,
    Iterable<LoanEntity> loans = const [],
    Iterable<LoanPaymentEntity> loanPayments = const [],
    DateTime? now,
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

    final loanInstallments = [
      for (final loan in loans)
        if (loan.hasSchedule)
          for (final summary in [
            LoanSummary.of(loan, loanPayments, now ?? DateTime.now()),
          ])
            for (final state in summary.installments)
              if (month.contains(state.installment.dueDate))
                LedgerLoanInstallment(
                  loan: loan,
                  installment: state,
                  installmentCount: summary.installments.length,
                ),
    ]..sort((a, b) => b.dueDate.compareTo(a.dueDate));

    return MonthLedger(
      month: month,
      direct: direct,
      statements: statements,
      loanInstallments: loanInstallments,
    );
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

  /// Loan installments due this month, latest first.
  final List<LedgerLoanInstallment> loanInstallments;

  /// Money in: incomes, cash withdrawals and collections of loans you made.
  double get income =>
      direct
          .where((m) => !m.isExpense || m.isCashWithdrawal)
          .fold<double>(0, (sum, m) => sum + m.amount) +
      _loans(income: true);

  /// Money out: direct expenses, card statements paid this month and the
  /// installments of loans you owe.
  double get expense =>
      direct
          .where((m) => m.isExpense && !m.isCashWithdrawal)
          .fold<double>(0, (sum, m) => sum + m.amount) +
      statements.fold<double>(0, (sum, s) => sum + s.statement.total) +
      _loans(income: false);

  double _loans({required bool income}) => loanInstallments
      .where((l) => l.isIncome == income)
      .fold(0, (sum, l) => sum + l.amount);

  double get balance => income - expense;

  @override
  List<Object?> get props => [month, direct, statements, loanInstallments];
}
