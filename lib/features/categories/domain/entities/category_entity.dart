import 'package:dynora_finance/core/enums/movement_type.dart';
import 'package:equatable/equatable.dart';

class CategoryEntity extends Equatable {
  const CategoryEntity({
    required this.id,
    required this.name,
    required this.type,
    required this.iconKey,
    required this.colorValue,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;

  /// Whether the category groups incomes or expenses.
  final MovementType type;

  /// Key of the icon in the presentation icon catalog.
  final String iconKey;

  /// ARGB value of the category color.
  final int colorValue;
  final DateTime createdAt;
  final DateTime updatedAt;

  CategoryEntity copyWith({
    String? name,
    MovementType? type,
    String? iconKey,
    int? colorValue,
  }) {
    return CategoryEntity(
      id: id,
      name: name ?? this.name,
      type: type ?? this.type,
      iconKey: iconKey ?? this.iconKey,
      colorValue: colorValue ?? this.colorValue,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    type,
    iconKey,
    colorValue,
    createdAt,
    updatedAt,
  ];
}
