import 'package:dynora_finance/core/enums/movement_type.dart';
import 'package:equatable/equatable.dart';

class MovementEntity extends Equatable {
  const MovementEntity({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.date,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final double amount;
  final MovementType type;
  final String categoryId;
  final DateTime date;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isExpense => type == MovementType.expense;

  MovementEntity copyWith({
    String? title,
    double? amount,
    MovementType? type,
    String? categoryId,
    DateTime? date,
    String? note,
  }) {
    return MovementEntity(
      id: id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      date: date ?? this.date,
      note: note ?? this.note,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    amount,
    type,
    categoryId,
    date,
    note,
    createdAt,
    updatedAt,
  ];
}
