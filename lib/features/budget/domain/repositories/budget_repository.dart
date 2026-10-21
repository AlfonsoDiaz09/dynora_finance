import 'package:dynora_finance/core/error/failures.dart';
import 'package:dynora_finance/features/budget/domain/entities/budget_entity.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class BudgetRepository {
  /// Emits the current budgets and every subsequent change.
  Stream<Either<Failure, List<BudgetEntity>>> watchBudgets();

  /// Creates the budget of [categoryId] or replaces its amount.
  Future<Either<Failure, BudgetEntity>> setBudget({
    required String categoryId,
    required double amount,
  });

  Future<Either<Failure, Unit>> deleteBudget(String id);
}
