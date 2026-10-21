import 'package:equatable/equatable.dart';

/// A payment you made towards a loan.
class LoanPaymentEntity extends Equatable {
  const LoanPaymentEntity({
    required this.id,
    required this.loanId,
    required this.amount,
    required this.paidAt,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String loanId;
  final double amount;
  final DateTime paidAt;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props => [
    id,
    loanId,
    amount,
    paidAt,
    note,
    createdAt,
    updatedAt,
  ];
}
