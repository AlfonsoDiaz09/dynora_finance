import 'package:dynora_finance/core/error/failures.dart';
import 'package:dynora_finance/core/usecase/usecase.dart';
import 'package:dynora_finance/features/budget/domain/entities/budget_entity.dart';
import 'package:dynora_finance/features/budget/domain/repositories/budget_repository.dart';
import 'package:fpdart/fpdart.dart';

class SetBudget implements UseCase<BudgetEntity, SetBudgetParams> {
  const SetBudget(this._repository);

  final BudgetRepository _repository;

  @override
  Future<Either<Failure, BudgetEntity>> call(SetBudgetParams params) async {
    if (params.categoryId.isEmpty) {
      return left(const ValidationFailure('La categoría es obligatoria'));
    }
    if (params.amount <= 0 || params.amount.isNaN || params.amount.isInfinite) {
      return left(const ValidationFailure('El monto debe ser mayor a 0'));
    }

    return _repository.setBudget(
      categoryId: params.categoryId,
      amount: params.amount,
    );
  }
}

class SetBudgetParams {
  const SetBudgetParams({required this.categoryId, required this.amount});

  final String categoryId;
  final double amount;
}
