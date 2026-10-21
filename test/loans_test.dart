import 'package:dynora_finance/core/error/failures.dart';
import 'package:dynora_finance/features/home/domain/entities/cash_flow.dart';
import 'package:dynora_finance/features/loans/domain/entities/loan_entity.dart';
import 'package:dynora_finance/features/loans/domain/entities/loan_payment_entity.dart';
import 'package:dynora_finance/features/loans/domain/entities/loan_summary.dart';
import 'package:dynora_finance/features/loans/domain/repositories/loan_repository.dart';
import 'package:dynora_finance/features/loans/domain/usecases/loan_usecases.dart';
import 'package:flutter_test/flutter_test.dart';

LoanEntity loan({
  LoanKind kind = LoanKind.institution,
  double principal = 10000,
  double? rate,
  double? installment = 1000,
  int? count = 12,
  DateTime? first,
  bool countsAsIncome = true,
}) => LoanEntity(
  id: 'l',
  name: 'Banco',
  kind: kind,
  principal: principal,
  startDate: DateTime(2026, 9, 15),
  interestRate: rate,
  installmentAmount: installment,
  installmentCount: count,
  firstPaymentDate: installment == null
      ? null
      : (first ?? DateTime(2026, 10, 5)),
  countsAsIncome: countsAsIncome,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);

LoanPaymentEntity paid(double amount, DateTime at) => LoanPaymentEntity(
  id: '$amount$at',
  loanId: 'l',
  amount: amount,
  paidAt: at,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);

class _NoRepository implements LoanRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not expected in this test');
}

void main() {
  group('Loan totals and calendar', () {
    test('institution: total is payment × payments, interest implied', () {
      final l = loan();
      expect(l.totalToPay, 12000);
      expect(l.interest, 2000);
      expect(l.schedule, hasLength(12));
      expect(l.schedule.first.dueDate, DateTime(2026, 10, 5));
      expect(l.schedule.last.dueDate, DateTime(2027, 9, 5));
    });

    test('personal without fixed payments: principal plus interest', () {
      final l = loan(
        kind: LoanKind.personal,
        principal: 5000,
        rate: 10,
        installment: null,
        count: null,
      );
      expect(l.totalToPay, 5500);
      expect(l.hasSchedule, isFalse);
      expect(l.schedule, isEmpty);
    });

    test('personal with fixed payment but no count: last one is smaller', () {
      final l = loan(
        kind: LoanKind.personal,
        principal: 5000,
        installment: 1500,
        count: null,
      );
      expect(l.schedule.map((i) => i.amount), [1500, 1500, 1500, 500]);
    });

    test('due day 31 is clamped in short months', () {
      final l = loan(first: DateTime(2027, 1, 31), count: 3);
      expect(l.schedule.map((i) => i.dueDate), [
        DateTime(2027, 1, 31),
        DateTime(2027, 2, 28),
        DateTime(2027, 3, 31),
      ]);
    });
  });

  group('Loan summary', () {
    test('payments cover installments in order', () {
      final summary = LoanSummary.of(loan(), [
        paid(2500, DateTime(2026, 11, 1)),
      ], DateTime(2026, 11, 10));
      final statuses = summary.installments.map((i) => i.status).toList();
      expect(statuses.take(4), [
        InstallmentStatus.paid,
        InstallmentStatus.paid,
        InstallmentStatus.partial,
        InstallmentStatus.pending,
      ]);
      expect(summary.nextInstallment!.installment.number, 3);
      expect(summary.nextInstallment!.missing, 500);
      expect(summary.remaining, 9500);
      expect(summary.overdueAmount, 0);
    });

    test('unpaid installments past their date are overdue', () {
      final summary = LoanSummary.of(loan(), [
        paid(1000, DateTime(2026, 10, 5)),
      ], DateTime(2026, 12, 6));
      // Oct paid; Nov 5 and Dec 5 overdue.
      expect(summary.overdueCount, 2);
      expect(summary.overdueAmount, 2000);
    });

    test('a loan is settled once the total is paid', () {
      final summary = LoanSummary.of(
        loan(kind: LoanKind.personal, installment: null, count: null),
        [paid(6000, DateTime(2026, 10, 1)), paid(4000, DateTime(2026, 11, 1))],
        DateTime(2026, 11, 2),
      );
      expect(summary.isSettled, isTrue);
      expect(summary.progress, 1);
    });

    test('ignores payments of other loans', () {
      final other = LoanPaymentEntity(
        id: 'x',
        loanId: 'other',
        amount: 999,
        paidAt: DateTime(2026, 10, 1),
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      );
      expect(LoanSummary.of(loan(), [other], DateTime(2026, 10, 2)).paid, 0);
    });
  });

  group('Validation', () {
    final save = SaveLoan(_NoRepository());

    Future<Failure?> failure(LoanEntity l) async =>
        (await save(l)).getLeft().toNullable();

    test('institution needs payment, count and first date', () async {
      expect(
        await failure(loan(installment: null, count: null)),
        isA<ValidationFailure>(),
      );
      expect(await failure(loan(count: null)), isA<ValidationFailure>());
    });

    test('total cannot be below the amount borrowed', () async {
      expect(
        await failure(loan(installment: 500, count: 12)),
        isA<ValidationFailure>(),
      );
    });

    test('future payment dates are rejected', () async {
      final result = await SaveLoanPayment(
        _NoRepository(),
        clock: () => DateTime(2026, 10, 21),
      )(paid(100, DateTime(2026, 10, 22)));
      expect(result.getLeft().toNullable(), isA<ValidationFailure>());
    });
  });

  test('cash flow: loan received is income, its payments expenses', () {
    final flow = CashFlow.of(
      movements: const [],
      cards: const [],
      payments: const [],
      loans: [loan(), loan(countsAsIncome: false)],
      loanPayments: [paid(1000, DateTime(2026, 10, 5))],
    );
    expect(flow.income, 10000);
    expect(flow.expense, 1000);
  });
}
