import 'package:dynora_finance/core/enums/movement_type.dart';
import 'package:dynora_finance/core/utils/month_range.dart';
import 'package:dynora_finance/features/cards/domain/entities/card_entity.dart';
import 'package:dynora_finance/features/movements/domain/entities/movement_entity.dart';
import 'package:dynora_finance/features/movements/domain/entities/movement_summary.dart';
import 'package:dynora_finance/shared/utils/formatters.dart';
import 'package:flutter_test/flutter_test.dart';

CardEntity card(int dueDay) => CardEntity(
  id: 'c',
  name: 'Nu',
  paymentDueDay: dueDay,
  colorValue: 0,
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
  group('CardEntity payment dates', () {
    test('due later this month', () {
      final now = DateTime(2026, 10, 20, 15, 30);
      expect(card(25).nextPaymentDate(now), DateTime(2026, 10, 25));
      expect(card(25).daysUntilPayment(now), 5);
    });

    test('due today counts as 0 days', () {
      expect(card(20).daysUntilPayment(DateTime(2026, 10, 20, 23)), 0);
    });

    test('already passed rolls to next month', () {
      final now = DateTime(2026, 10, 20);
      expect(card(5).nextPaymentDate(now), DateTime(2026, 11, 5));
      expect(card(5).daysUntilPayment(now), 16);
    });

    test('day 31 clamps to end of short months', () {
      expect(
        card(31).nextPaymentDate(DateTime(2026, 2, 10)),
        DateTime(2026, 2, 28),
      );
      expect(
        card(31).nextPaymentDate(DateTime(2028, 2, 10)),
        DateTime(2028, 2, 29),
      );
    });

    test('rolls over the year', () {
      expect(
        card(3).nextPaymentDate(DateTime(2026, 12, 15)),
        DateTime(2027, 1, 3),
      );
    });
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
