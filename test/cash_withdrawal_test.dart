import 'package:dynora_finance/core/enums/movement_type.dart';
import 'package:dynora_finance/features/cards/domain/entities/card_entity.dart';
import 'package:dynora_finance/features/cards/domain/entities/card_payment_entity.dart';
import 'package:dynora_finance/features/cards/domain/entities/card_statement.dart';
import 'package:dynora_finance/features/cards/domain/entities/card_type.dart';
import 'package:dynora_finance/features/home/domain/entities/cash_flow.dart';
import 'package:dynora_finance/features/movements/domain/entities/movement_entity.dart';
import 'package:dynora_finance/features/movements/domain/entities/movement_summary.dart';
import 'package:dynora_finance/features/movements/domain/usecases/movement_validator.dart';
import 'package:flutter_test/flutter_test.dart';

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

MovementEntity withdrawal({int? count, double? rate, double amount = 5000}) =>
    MovementEntity(
      id: 'w',
      title: 'Disposición de efectivo',
      amount: amount,
      type: MovementType.expense,
      categoryId: MovementEntity.cashWithdrawalCategoryId,
      date: DateTime(2026, 10, 10),
      cardId: 'c',
      installmentCount: count,
      installmentRate: rate,
      isCashWithdrawal: true,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );

void main() {
  test('the card is charged amount plus interest in the chosen payments', () {
    final w = withdrawal(count: 6, rate: 15);
    expect(w.totalWithInterest, 5750);
    expect(w.installmentAmounts.first, 958.33);
    expect(w.installmentAmounts.reduce((a, b) => a + b), closeTo(5750, 0.0001));

    final statements = CardStatement.build(
      card,
      [w],
      const [],
      DateTime(2026, 10, 15),
    );
    expect(statements.where((s) => s.total > 0), hasLength(6));
  });

  test('a single payment can carry a commission', () {
    final w = withdrawal(rate: 3);
    expect(w.installmentAmounts, [5150]);
    final october = CardStatement.of(card, card.billingPeriodFor(w.date), [
      w,
    ], const []);
    expect(october.total, 5150);
  });

  test('counts as income (without interest), never as spending', () {
    final summary = MovementSummary.of([withdrawal(count: 6, rate: 15)]);
    expect(summary.income, 5000);
    expect(summary.expense, 0);
    expect(summary.expenseByCategory, isEmpty);
  });

  test('cash flow: money in on withdrawal, out when the card is paid', () {
    final flow = CashFlow.of(
      movements: [withdrawal(rate: 3)],
      cards: [card],
      payments: [
        CardPaymentEntity(
          id: 'p',
          cardId: 'c',
          periodStart: DateTime(2026, 10, 2),
          amount: 5150,
          paidAt: DateTime(2026, 11, 20),
          createdAt: DateTime(2026),
          updatedAt: DateTime(2026),
        ),
      ],
    );
    expect(flow.income, 5000);
    expect(flow.expense, 5150);
  });

  test('needs a card and allows no category', () {
    String? validate({String? cardId = 'c'}) => MovementValidator.validate(
      title: 'Disposición',
      amount: 5000,
      categoryId: MovementEntity.cashWithdrawalCategoryId,
      cardId: cardId,
      isCashWithdrawal: true,
    )?.message;

    expect(validate(), isNull);
    expect(validate(cardId: null), isNotNull);
  });
}
