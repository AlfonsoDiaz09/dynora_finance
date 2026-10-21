import 'package:dynora_finance/core/enums/movement_type.dart';
import 'package:dynora_finance/core/utils/month_range.dart';
import 'package:dynora_finance/features/cards/domain/entities/card_entity.dart';
import 'package:dynora_finance/features/cards/domain/entities/card_payment_entity.dart';
import 'package:dynora_finance/features/movements/domain/entities/movement_entity.dart';

/// Money that actually entered and left your accounts.
///
/// Purchases with credit or departmental cards don't move cash when made,
/// so they are excluded; the cash leaves when the card is paid, through the
/// registered [CardPaymentEntity]s. Cash, transfer and debit movements count
/// on their date.
class CashFlow {
  const CashFlow({required this.income, required this.expense});

  factory CashFlow.of({
    required Iterable<MovementEntity> movements,
    required Iterable<CardEntity> cards,
    required Iterable<CardPaymentEntity> payments,
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

    return CashFlow(income: income, expense: expense);
  }

  static const empty = CashFlow(income: 0, expense: 0);

  final double income;

  /// Cash and debit expenses plus card payments.
  final double expense;

  double get balance => income - expense;
}
