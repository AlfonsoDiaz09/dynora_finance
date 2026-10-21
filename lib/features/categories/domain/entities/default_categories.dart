import 'package:dynora_finance/core/enums/movement_type.dart';

class DefaultCategory {
  const DefaultCategory({
    required this.id,
    required this.name,
    required this.type,
    required this.iconKey,
    required this.colorValue,
  });

  /// Fixed id so the same default merges across devices once sync exists.
  final String id;
  final String name;
  final MovementType type;
  final String iconKey;
  final int colorValue;
}

const List<DefaultCategory> defaultCategories = [
  DefaultCategory(
    id: 'default_food',
    name: 'Comida',
    type: MovementType.expense,
    iconKey: 'restaurant',
    colorValue: 0xFFFFAB40,
  ),
  DefaultCategory(
    id: 'default_transport',
    name: 'Transporte',
    type: MovementType.expense,
    iconKey: 'car',
    colorValue: 0xFF448AFF,
  ),
  DefaultCategory(
    id: 'default_shopping',
    name: 'Compras',
    type: MovementType.expense,
    iconKey: 'shopping',
    colorValue: 0xFFFF4081,
  ),
  DefaultCategory(
    id: 'default_entertainment',
    name: 'Entretenimiento',
    type: MovementType.expense,
    iconKey: 'movie',
    colorValue: 0xFFE040FB,
  ),
  DefaultCategory(
    id: 'default_subscriptions',
    name: 'Suscripciones',
    type: MovementType.expense,
    iconKey: 'subscriptions',
    colorValue: 0xFF7C4DFF,
  ),
  DefaultCategory(
    id: 'default_health',
    name: 'Salud',
    type: MovementType.expense,
    iconKey: 'health',
    colorValue: 0xFFFF5252,
  ),
  DefaultCategory(
    id: 'default_home',
    name: 'Hogar',
    type: MovementType.expense,
    iconKey: 'home',
    colorValue: 0xFF64FFDA,
  ),
  DefaultCategory(
    id: 'default_other_expense',
    name: 'Otros gastos',
    type: MovementType.expense,
    iconKey: 'other',
    colorValue: 0xFF9E9E9E,
  ),
  DefaultCategory(
    id: 'default_salary',
    name: 'Nómina',
    type: MovementType.income,
    iconKey: 'work',
    colorValue: 0xFF69F0AE,
  ),
  DefaultCategory(
    id: 'default_freelance',
    name: 'Freelance',
    type: MovementType.income,
    iconKey: 'laptop',
    colorValue: 0xFF40C4FF,
  ),
  DefaultCategory(
    id: 'default_other_income',
    name: 'Otros ingresos',
    type: MovementType.income,
    iconKey: 'money',
    colorValue: 0xFFB2FF59,
  ),
];
