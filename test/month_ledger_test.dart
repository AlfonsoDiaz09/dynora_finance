import 'package:dynora_finance/core/enums/movement_type.dart';
import 'package:dynora_finance/core/utils/month_range.dart';
import 'package:dynora_finance/features/cards/domain/entities/card_entity.dart';
import 'package:dynora_finance/features/cards/domain/entities/card_type.dart';
import 'package:dynora_finance/features/loans/domain/entities/loan_entity.dart';
import 'package:dynora_finance/features/loans/domain/entities/loan_payment_entity.dart';
import 'package:dynora_finance/features/loans/domain/entities/loan_summary.dart';
import 'package:dynora_finance/features/movements/domain/entities/month_ledger.dart';
import 'package:dynora_finance/features/movements/domain/entities/movement_entity.dart';
import 'package:flutter_test/flutter_test.dart';

CardEntity card(String id, CardType type, {int? cutoff, int? payment}) =>
    CardEntity(
      id: id,
      name: id,
      type: type,
      lastFourDigits: '0000',
      cutoffDay: cutoff,
      paymentDueDay: payment,
      colorValue: 0,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );

MovementEntity movement(
  String id,
  double amount,
  DateTime date, {
  String? cardId,
  MovementType type = MovementType.expense,
  int? installments,
  bool withdrawal = false,
}) => MovementEntity(
  id: id,
  title: id,
  amount: amount,
  type: type,
  categoryId: withdrawal ? MovementEntity.cashWithdrawalCategoryId : 'food',
  date: date,
  cardId: cardId,
  installmentCount: installments,
  isCashWithdrawal: withdrawal,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);

/// Cutoff 2, payment 20: Sep 2 – Oct 1 is paid Oct 20.
final bbva = card('bbva', CardType.credit, cutoff: 2, payment: 20);

/// Cutoff 15, payment 3: Oct 15 – Nov 14 is paid Dec 3, with November's
/// salary.
final early = card('early', CardType.credit, cutoff: 15, payment: 3);
final debit = card('debit', CardType.debit);

MonthLedger ledger(int month, List<MovementEntity> movements) =>
    MonthLedger.build(
      month: MonthRange(DateTime(2026, month)),
      movements: movements,
      cards: [bbva, early, debit],
      cardPayments: const [],
    );

void main() {
  test('credit purchases count in the month their statement is paid', () {
    final movements = [
      movement('sep', 2000, DateTime(2026, 9, 25), cardId: 'bbva'),
      movement('oct', 800, DateTime(2026, 10, 5), cardId: 'bbva'),
    ];

    final october = ledger(10, movements);
    expect(october.direct, isEmpty);
    expect(october.statements, hasLength(1));
    expect(
      october.statements.single.statement.period.paymentDate,
      DateTime(2026, 10, 20),
    );
    expect(october.expense, 2000);

    expect(ledger(11, movements).expense, 800);
    expect(ledger(9, movements).expense, 0);
  });

  test('installments land one per month', () {
    final movements = [
      movement(
        'tv',
        1200,
        DateTime(2026, 9, 25),
        cardId: 'bbva',
        installments: 3,
      ),
    ];
    for (final month in [10, 11, 12]) {
      expect(ledger(month, movements).expense, 400, reason: 'month $month');
    }
    expect(ledger(9, movements).expense, 0);
  });

  test('debit, transfer and cash count on their own date', () {
    final movements = [
      movement('debit', 300, DateTime(2026, 10, 10), cardId: 'debit'),
      movement('transfer', 150, DateTime(2026, 10, 3)),
      movement(
        'salary',
        15000,
        DateTime(2026, 10, 1),
        type: MovementType.income,
      ),
      movement('november', 99, DateTime(2026, 11, 1)),
    ];

    final october = ledger(10, movements);
    expect(october.statements, isEmpty);
    expect(october.direct.map((m) => m.id), ['debit', 'transfer', 'salary']);
    expect(october.income, 15000);
    expect(october.expense, 450);
    expect(october.balance, 14550);
  });

  test('a payment on days 1–4 is funded by the previous month', () {
    final movements = [
      movement('early', 500, DateTime(2026, 10, 20), cardId: 'early'),
    ];
    expect(ledger(11, movements).expense, 500);
    expect(ledger(12, movements).expense, 0);
  });

  test(
    'withdrawals are income on their day and charged with the statement',
    () {
      final movements = [
        movement(
          'cash',
          5000,
          DateTime(2026, 10, 10),
          cardId: 'bbva',
          withdrawal: true,
        ),
      ];

      final october = ledger(10, movements);
      expect(october.direct.single.id, 'cash');
      expect(october.income, 5000);
      expect(october.expense, 0);

      final november = ledger(11, movements);
      expect(november.income, 0);
      expect(november.expense, 5000);
    },
  );

  group('loans with a payment calendar', () {
    LoanEntity loan(String id, LoanDirection direction, {DateTime? first}) =>
        LoanEntity(
          id: id,
          name: id,
          kind: LoanKind.personal,
          direction: direction,
          principal: 3000,
          startDate: DateTime(2026, 9, 1),
          installmentAmount: 1000,
          installmentCount: 3,
          firstPaymentDate: first,
          createdAt: DateTime(2026),
          updatedAt: DateTime(2026),
        );

    final loans = [
      loan('bank', LoanDirection.borrowed, first: DateTime(2026, 10, 15)),
      loan('ana', LoanDirection.lent, first: DateTime(2026, 11, 5)),
      // No calendar: nothing to place in a month.
      loan('open', LoanDirection.borrowed),
    ];
    final payments = [
      LoanPaymentEntity(
        id: 'p1',
        loanId: 'bank',
        amount: 1000,
        paidAt: DateTime(2026, 10, 14),
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      ),
    ];

    MonthLedger month(int m) => MonthLedger.build(
      month: MonthRange(DateTime(2026, m)),
      movements: const [],
      cards: const [],
      cardPayments: const [],
      loans: loans,
      loanPayments: payments,
      now: DateTime(2026, 10, 22),
    );

    test('installments land in the month they are due', () {
      final october = month(10);
      expect(october.loanInstallments, hasLength(1));
      final bank = october.loanInstallments.single;
      expect(bank.loan.id, 'bank');
      expect(bank.installment.installment.number, 1);
      expect(bank.installmentCount, 3);
      expect(bank.installment.status, InstallmentStatus.paid);
      expect(october.expense, 1000);
      expect(october.income, 0);

      final november = month(11);
      expect(november.loanInstallments.map((l) => l.loan.id), ['bank', 'ana']);
      expect(november.expense, 1000);
      expect(november.income, 1000);

      expect(month(2).loanInstallments, isEmpty);
    });
  });
}
