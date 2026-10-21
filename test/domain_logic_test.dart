import 'package:dynora_finance/core/enums/movement_type.dart';
import 'package:dynora_finance/core/utils/month_range.dart';
import 'package:dynora_finance/core/error/failures.dart';
import 'package:dynora_finance/features/cards/domain/entities/billing_period.dart';
import 'package:dynora_finance/features/cards/domain/entities/card_entity.dart';
import 'package:dynora_finance/features/cards/domain/entities/card_statement.dart';
import 'package:dynora_finance/features/cards/domain/entities/card_type.dart';
import 'package:dynora_finance/features/cards/domain/usecases/card_validator.dart';
import 'package:dynora_finance/features/movements/domain/entities/movement_entity.dart';
import 'package:dynora_finance/features/movements/domain/entities/movement_summary.dart';
import 'package:dynora_finance/shared/utils/formatters.dart';
import 'package:flutter_test/flutter_test.dart';

CardEntity card({
  int? cutoff = 25,
  int? payment = 5,
  CardType type = CardType.credit,
}) => CardEntity(
  id: 'c',
  name: 'Nu',
  type: type,
  lastFourDigits: '1234',
  cutoffDay: cutoff,
  paymentDueDay: payment,
  colorValue: 0,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);

MovementEntity cardMovement(DateTime date, double amount, {String? cardId}) =>
    MovementEntity(
      id: '$date$amount',
      title: 't',
      amount: amount,
      type: MovementType.expense,
      categoryId: 'food',
      date: date,
      cardId: cardId ?? 'c',
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );

MovementEntity movement(double amount, MovementType type, String category) =>
    MovementEntity(
      id: '$amount$category',
      title: 't',
      amount: amount,
      type: type,
      categoryId: category,
      date: DateTime(2026, 10, 5),
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );

void main() {
  group('Billing periods', () {
    test('cutoff 29 and payment 29: Sep 29 – Oct 28, paid Oct 29', () {
      final c = card(cutoff: 29, payment: 29);
      final expected = BillingPeriod(
        start: DateTime(2026, 9, 29),
        end: DateTime(2026, 10, 28),
        paymentDate: DateTime(2026, 10, 29),
      );
      expect(c.billingPeriodFor(DateTime(2026, 9, 29)), expected);
      expect(c.billingPeriodFor(DateTime(2026, 10, 15, 18)), expected);
      expect(c.billingPeriodFor(DateTime(2026, 10, 28, 23, 59)), expected);

      // The cutoff day opens the next period.
      final next = c.billingPeriodFor(DateTime(2026, 10, 29));
      expect(next.start, DateTime(2026, 10, 29));
      expect(next.end, DateTime(2026, 11, 28));
      expect(next.paymentDate, DateTime(2026, 11, 29));
    });

    test('cutoff 2 and payment 20: Sep 2 – Oct 1, paid Oct 20', () {
      final c = card(cutoff: 2, payment: 20);
      final expected = BillingPeriod(
        start: DateTime(2026, 9, 2),
        end: DateTime(2026, 10, 1),
        paymentDate: DateTime(2026, 10, 20),
      );
      expect(c.billingPeriodFor(DateTime(2026, 9, 2)), expected);
      expect(c.billingPeriodFor(DateTime(2026, 10, 1)), expected);
      expect(
        c.billingPeriodFor(DateTime(2026, 9, 1)).paymentDate,
        DateTime(2026, 9, 20),
      );
    });

    test('cutoff 25 and payment 5: Aug 25 – Sep 24, paid Oct 5', () {
      final period = card().billingPeriodFor(DateTime(2026, 9, 10));
      expect(period.start, DateTime(2026, 8, 25));
      expect(period.end, DateTime(2026, 9, 24));
      expect(period.paymentDate, DateTime(2026, 10, 5));
      expect(period.fundingMonth(), MonthRange(DateTime(2026, 10)));
    });

    test('upcoming payment switches after the payment date', () {
      final nu = card();
      expect(
        nu.upcomingPeriod(DateTime(2026, 10, 1)).paymentDate,
        DateTime(2026, 10, 5),
      );
      expect(
        nu.upcomingPeriod(DateTime(2026, 10, 5)).paymentDate,
        DateTime(2026, 10, 5),
      );
      expect(
        nu.upcomingPeriod(DateTime(2026, 10, 6)).paymentDate,
        DateTime(2026, 11, 5),
      );
    });

    test('payment on the cutoff day is due that same day', () {
      final c = card(cutoff: 29, payment: 29);
      final today = DateTime(2026, 10, 29, 9);
      final upcoming = c.upcomingPeriod(today);
      expect(upcoming.end, DateTime(2026, 10, 28));
      expect(upcoming.isAwaitingPayment(today), isTrue);
      expect(upcoming.daysUntilPayment(today), 0);
    });

    test('statement total and grouping by period', () {
      final nu = card();
      final movements = [
        cardMovement(DateTime(2026, 9, 1), 100),
        cardMovement(DateTime(2026, 9, 24), 50),
        cardMovement(DateTime(2026, 9, 25), 30),
        cardMovement(DateTime(2026, 9, 2), 999, cardId: 'other'),
      ];
      final statements = CardStatement.build(
        nu,
        movements,
        DateTime(2026, 10, 1),
      );
      expect(statements.map((s) => s.period.end), [
        DateTime(2026, 10, 24),
        DateTime(2026, 9, 24),
      ]);
      expect(statements.map((s) => s.total), [30, 150]);

      final october = CardStatement.fundedIn(
        nu,
        movements,
        MonthRange(DateTime(2026, 10)),
      );
      expect(october.single.period.paymentDate, DateTime(2026, 10, 5));
      expect(october.single.total, 150);
    });
  });

  test('statements include empty periods between movements', () {
    final statements = CardStatement.build(card(), [
      cardMovement(DateTime(2026, 7, 1), 10),
      cardMovement(DateTime(2026, 9, 1), 20),
    ], DateTime(2026, 10, 1));
    expect(statements.map((s) => s.period.start), [
      DateTime(2026, 9, 25),
      DateTime(2026, 8, 25),
      DateTime(2026, 7, 25),
      DateTime(2026, 6, 25),
    ]);
    expect(statements.map((s) => s.total), [0, 20, 0, 10]);
  });

  group('Billing period edge cases', () {
    test('day 31 clamps to short months without gaps', () {
      final c = card(cutoff: 31, payment: 10);
      final feb = c.billingPeriodFor(DateTime(2026, 2, 15));
      expect(feb.start, DateTime(2026, 1, 31));
      expect(feb.end, DateTime(2026, 2, 27));
      final mar = c.billingPeriodFor(DateTime(2026, 2, 28));
      expect(mar.start, DateTime(2026, 2, 28));
      expect(mar.end, DateTime(2026, 3, 30));
    });

    test('rolls over the year', () {
      final period = card().billingPeriodFor(DateTime(2026, 12, 28));
      expect(period.start, DateTime(2026, 12, 25));
      expect(period.end, DateTime(2027, 1, 24));
      expect(period.paymentDate, DateTime(2027, 2, 5));
    });

    test('payment due before salary is funded by the previous month', () {
      final c = card(cutoff: 20, payment: 3);
      final period = c.billingPeriodFor(DateTime(2026, 10, 10));
      expect(period.paymentDate, DateTime(2026, 11, 3));
      expect(period.fundingMonth(), MonthRange(DateTime(2026, 10)));
      expect(
        CardStatement.fundedIn(
          c,
          const [],
          MonthRange(DateTime(2026, 10)),
        ).single.period,
        period,
      );
    });

    test('debit cards have no billing cycle', () {
      expect(card(type: CardType.debit).hasBillingCycle, isFalse);
      expect(card(cutoff: null).hasBillingCycle, isFalse);
    });
  });

  group('Card validation', () {
    ValidationFailure? validate({
      String digits = '1234',
      CardType type = CardType.credit,
      int? cutoff = 25,
      int? payment = 5,
    }) => CardValidator.validate(
      name: 'Nu',
      type: type,
      lastFourDigits: digits,
      cutoffDay: cutoff,
      paymentDueDay: payment,
    );

    test('requires exactly four digits', () {
      expect(validate(digits: '123'), isNotNull);
      expect(validate(digits: '12a4'), isNotNull);
      expect(validate(), isNull);
    });

    test(
      'credit needs cutoff and payment days (can be equal), debit does not',
      () {
        expect(validate(cutoff: null), isNotNull);
        expect(validate(payment: 32), isNotNull);
        expect(validate(cutoff: 29, payment: 29), isNull);
        expect(
          validate(type: CardType.debit, cutoff: null, payment: null),
          isNull,
        );
      },
    );
  });

  group('MonthRange', () {
    test('bounds include whole month', () {
      final month = MonthRange(DateTime(2026, 2, 14));
      expect(month.start, DateTime(2026, 2));
      expect(month.contains(DateTime(2026, 2, 28, 23, 59, 59)), isTrue);
      expect(month.contains(DateTime(2026, 3)), isFalse);
      expect(month.contains(DateTime(2026, 1, 31, 23)), isFalse);
    });

    test('previous and next cross years', () {
      expect(MonthRange(DateTime(2026, 1)).previous.start, DateTime(2025, 12));
      expect(MonthRange(DateTime(2026, 12)).next.start, DateTime(2027, 1));
    });
  });

  test('MovementSummary totals and expenses by category', () {
    final summary = MovementSummary.of([
      movement(1000, MovementType.income, 'salary'),
      movement(200, MovementType.expense, 'food'),
      movement(50, MovementType.expense, 'food'),
      movement(100, MovementType.expense, 'car'),
    ]);
    expect(summary.income, 1000);
    expect(summary.expense, 350);
    expect(summary.balance, 650);
    expect(summary.expenseByCategory, {'food': 250, 'car': 100});
  });

  group('Formatters', () {
    final now = DateTime(2026, 10, 20, 10);

    test('relative day labels', () {
      expect(
        Formatters.relativeDay(DateTime(2026, 10, 20, 1), now: now),
        'Hoy',
      );
      expect(
        Formatters.relativeDay(DateTime(2026, 10, 19, 23), now: now),
        'Ayer',
      );
      expect(Formatters.relativeDay(DateTime(2026, 2, 18), now: now), '18 Feb');
      expect(
        Formatters.relativeDay(DateTime(2025, 2, 18), now: now),
        '18 Feb 2025',
      );
    });

    test('month and currency', () {
      expect(Formatters.monthYear(DateTime(2026, 2)), 'Febrero 2026');
      expect(Formatters.currency(24580), '\$24,580.00');
      expect(Formatters.currencyNoDecimals(3200), '\$3,200');
    });
  });
}
