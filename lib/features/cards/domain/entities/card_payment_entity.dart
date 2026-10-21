import 'package:equatable/equatable.dart';

/// Payment made to settle one statement (billing period) of a card.
class CardPaymentEntity extends Equatable {
  const CardPaymentEntity({
    required this.id,
    required this.cardId,
    required this.periodStart,
    required this.amount,
    required this.paidAt,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String cardId;

  /// Start of the paid period; identifies the statement together with
  /// [cardId].
  final DateTime periodStart;
  final double amount;

  /// Day the payment was made (may be registered later than that).
  final DateTime paidAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props => [
    id,
    cardId,
    periodStart,
    amount,
    paidAt,
    createdAt,
    updatedAt,
  ];
}
