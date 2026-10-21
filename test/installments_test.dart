import 'package:dynora_finance/core/enums/movement_type.dart';
import 'package:dynora_finance/core/enums/payment_method.dart';
import 'package:dynora_finance/features/cards/domain/entities/card_entity.dart';
import 'package:dynora_finance/features/cards/domain/entities/card_statement.dart';
import 'package:dynora_finance/features/cards/domain/entities/card_type.dart';
import 'package:dynora_finance/features/movements/domain/entities/movement_entity.dart';
import 'package:dynora_finance/features/movements/domain/usecases/movement_validator.dart';
import 'package:flutter_test/flutter_test.dart';

final card = CardEntity(
  id: 'c',
  name: 'Nu',
  type: CardType.credit,
  lastFourDigits: '1234',
  cutoffDay: 2,
  paymentDueDay: 20,
  colorValue: 0,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);

MovementEntity purchase({
  double amount = 12000,
  int? count,
  double? rate,
  String? cardId = 'c',
  PaymentMethod? method,
  DateTime? date,
}) => MovementEntity(
  id: 'm',
  title: 'Laptop',
  amount: amount,
  type: MovementType.expense,
  categoryId: 'tech',
  date: date ?? DateTime(2026, 9, 10),
  cardId: cardId,
  paymentMethod: method,
  installmentCount: count,
  installmentRate: rate,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);

void main() {
  group('Installment amounts', () {
    test('interest-free splits the price evenly', () {
      final m = purchase(count: 12);
      expect(m.hasInterest, isFalse);
      expect(m.installmentAmounts, List.filled(12, 1000.0));
    });

    test('rounding cents go to the last installment', () {
      final amounts = purchase(amount: 1000, count: 3).installmentAmounts;
      expect(amounts, [333.33, 333.33, 333.34]);
      expect(amounts.reduce((a, b) => a + b), closeTo(1000, 0.0001));
    });

    test('fixed interest is added to the price', () {
      final m = purchase(amount: 12000, count: 12, rate: 15);
      expect(m.totalWithInterest, 13800);
      expect(m.installmentAmounts.first, 1150);
      expect(
        m.installmentAmounts.reduce((a, b) => a + b),
        closeTo(13800, 0.0001),
      );
    });

    test('a single charge is the full price', () {
      expect(purchase().installmentAmounts, [12000]);
    });
  });

  group('Installments in statements (cutoff 2, payment 20)', () {
    test('each installment lands in a consecutive period', () {
      final statements = CardStatement.build(
        card,
        [purchase(count: 3)],
        const [],
        DateTime(2026, 9, 15),
      );
      // Sep 2 – Oct 1 (purchase), then Oct 2 – Nov 1 and Nov 2 – Dec 1.
      expect(statements.map((s) => s.period.start), [
        DateTime(2026, 11, 2),
        DateTime(2026, 10, 2),
        DateTime(2026, 9, 2),
      ]);
      expect(statements.map((s) => s.total), [4000, 4000, 4000]);
      expect(statements.map((s) => s.charges.single.installmentNumber), [
        3,
        2,
        1,
      ]);
      expect(
        statements.first.status(DateTime(2026, 9, 15)),
        StatementStatus.future,
      );
    });

    test('installments add up with other purchases of the period', () {
      final single = MovementEntity(
        id: 's',
        title: 'Café',
        amount: 50,
        type: MovementType.expense,
        categoryId: 'food',
        date: DateTime(2026, 10, 5),
        cardId: 'c',
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      );
      final october = CardStatement.of(
        card,
        card.billingPeriodFor(DateTime(2026, 10, 5)),
        [purchase(count: 12), single],
        const [],
      );
      expect(october.total, 1050);
      expect(october.charges, hasLength(2));
    });
  });

  group('Payment method', () {
    test('a card always means card, otherwise cash unless transfer', () {
      expect(purchase().paymentMethod, PaymentMethod.card);
      expect(purchase(cardId: null).paymentMethod, PaymentMethod.cash);
      expect(
        purchase(cardId: null, method: PaymentMethod.transfer).paymentMethod,
        PaymentMethod.transfer,
      );
      expect(
        purchase(method: PaymentMethod.transfer).paymentMethod,
        PaymentMethod.card,
      );
    });
  });

  group('Validation', () {
    String? validate({String? cardId = 'c', int? count = 12, double? rate}) =>
        MovementValidator.validate(
          title: 'Laptop',
          amount: 100,
          categoryId: 'tech',
          cardId: cardId,
          installmentCount: count,
          installmentRate: rate,
        )?.message;

    test('installments need a card and at most 48 months', () {
      expect(validate(), isNull);
      expect(validate(cardId: null), isNotNull);
      expect(validate(count: 49), isNotNull);
      expect(validate(rate: 101), isNotNull);
      expect(validate(cardId: null, count: null), isNull);
    });
  });
}
