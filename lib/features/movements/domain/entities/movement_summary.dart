import 'package:dynora_finance/core/enums/movement_type.dart';
import 'package:dynora_finance/features/movements/domain/entities/movement_entity.dart';

/// Totals of a list of movements.
class MovementSummary {
  const MovementSummary({
    required this.income,
    required this.expense,
    required this.expenseByCategory,
  });

  factory MovementSummary.of(Iterable<MovementEntity> movements) {
    var income = 0.0;
    var expense = 0.0;
    final byCategory = <String, double>{};

    for (final movement in movements) {
      if (movement.isCashWithdrawal || movement.type == MovementType.income) {
        income += movement.amount;
      } else {
        expense += movement.amount;
        byCategory.update(
          movement.categoryId,
          (total) => total + movement.amount,
          ifAbsent: () => movement.amount,
        );
      }
    }

    return MovementSummary(
      income: income,
      expense: expense,
      expenseByCategory: byCategory,
    );
  }

  static const empty = MovementSummary(
    income: 0,
    expense: 0,
    expenseByCategory: {},
  );

  final double income;
  final double expense;

  /// Expense total per category id.
  final Map<String, double> expenseByCategory;

  double get balance => income - expense;
}
