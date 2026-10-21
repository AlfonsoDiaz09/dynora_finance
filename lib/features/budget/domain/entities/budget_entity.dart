import 'package:equatable/equatable.dart';

/// Monthly spending limit for one expense category.
class BudgetEntity extends Equatable {
  const BudgetEntity({
    required this.id,
    required this.categoryId,
    required this.amount,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String categoryId;

  /// Limit for each calendar month.
  final double amount;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props => [id, categoryId, amount, createdAt, updatedAt];
}
