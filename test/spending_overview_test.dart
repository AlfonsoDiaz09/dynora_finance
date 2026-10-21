import 'package:dynora_finance/core/enums/movement_type.dart';
import 'package:dynora_finance/features/cards/domain/entities/card_entity.dart';
import 'package:dynora_finance/features/cards/domain/entities/card_payment_entity.dart';
import 'package:dynora_finance/features/cards/domain/entities/card_type.dart';
import 'package:dynora_finance/features/home/domain/entities/spending_overview.dart';
import 'package:dynora_finance/features/movements/domain/entities/movement_entity.dart';
import 'package:flutter_test/flutter_test.dart';

// Corte 2, pago 20: the period of Oct 21 is Oct 2 – Nov 1, paid Nov 20.
final card = CardEntity(
  id: 'c',
  name: 'BBVA',
  type: CardType.credit,
  lastFourDigits: '5690',
  cutoffDay: 2,
  paymentDueDay: 20,
  colorValue: 0,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);
final now = DateTime(2026, 10, 21, 12);

MovementEntity movement(
  double amount, {
  MovementType type = MovementType.expense,
  String? cardId,
  DateTime? date,
  int? count,
  double? rate,
  bool withdrawal = false,
}) => MovementEntity(
  id: '$amount$date$cardId$withdrawal',
  title: 't',
  amount: amount,
  type: type,
  categoryId: 'x',
  date: date ?? DateTime(2026, 10, 10),
  cardId: cardId,
  installmentCount: count,
  installmentRate: rate,
  isCashWithdrawal: withdrawal,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);

final salary = movement(
  15000,
  type: MovementType.income,
  date: DateTime(2026, 10, 1),
);

SpendingOverview overview(
  List<MovementEntity> movements, {
  List<CardPaymentEntity> payments = const [],
}) => SpendingOverview.of(
  movements: movements,
  cards: [card],
  cardPayments: payments,
  now: now,
);

void main() {
  test('a credit purchase lowers what you can spend right away', () {
    final o = overview([salary, movement(2369, cardId: 'c')]);
    expect(o.cash, 15000);
    expect(o.cardDebt, 2369);
    expect(o.available, 12631);
    expect(o.monthExpense, 2369);
  });

  test('paying the statement does not deduct it twice', () {
    final o = overview(
      [salary, movement(2369, cardId: 'c')],
      payments: [
        CardPaymentEntity(
          id: 'p',
          cardId: 'c',
          periodStart: DateTime(2026, 10, 2),
          amount: 2369,
          paidAt: DateTime(2026, 10, 21),
          createdAt: DateTime(2026),
          updatedAt: DateTime(2026),
        ),
      ],
    );
    expect(o.cash, 12631);
    expect(o.cardDebt, 0);
    expect(o.available, 12631);
    expect(o.monthExpense, 2369);
  });

  test('only the current installment is deducted; the rest is future', () {
    final o = overview([salary, movement(12000, cardId: 'c', count: 12)]);
    expect(o.cardDebt, 1000);
    expect(o.futureInstallments, 11000);
    expect(o.available, 14000);
    expect(o.monthExpense, 1000);
  });

  test('a withdrawal adds the cash and deducts its current charge', () {
    final o = overview([
      movement(5000, cardId: 'c', count: 6, rate: 15, withdrawal: true),
    ]);
    expect(o.cash, 5000);
    expect(o.cardDebt, 958.33);
    expect(o.available, closeTo(4041.67, 0.001));
    expect(o.monthIncome, 5000);
  });

  test('later installments are incurred when their period starts', () {
    // Bought Sep 10 in 3 payments: Sep 2–Oct 1 (unpaid), Oct 2–Nov 1, Nov 2…
    final o = overview([
      movement(3000, cardId: 'c', count: 3, date: DateTime(2026, 9, 10)),
    ]);
    expect(o.cardDebt, 2000);
    expect(o.futureInstallments, 1000);
    expect(o.monthExpense, 1000);
  });

  test('cash and debit purchases count on their date', () {
    final o = overview([salary, movement(500)]);
    expect(o.available, 14500);
    expect(o.monthExpense, 500);
  });
}
