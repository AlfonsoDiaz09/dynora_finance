import 'package:equatable/equatable.dart';

/// Part of a movement that a person owes you.
class DebtEntity extends Equatable {
  const DebtEntity({
    required this.id,
    required this.movementId,
    required this.personId,
    required this.amount,
    this.paidAt,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String movementId;
  final String personId;
  final double amount;

  /// Day the person paid you back; `null` while pending.
  final DateTime? paidAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isPaid => paidAt != null;

  @override
  List<Object?> get props => [
    id,
    movementId,
    personId,
    amount,
    paidAt,
    createdAt,
    updatedAt,
  ];
}
