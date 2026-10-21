import 'package:dynora_finance/core/error/failures.dart';
import 'package:dynora_finance/core/usecase/usecase.dart';
import 'package:dynora_finance/features/budget/domain/repositories/budget_repository.dart';
import 'package:fpdart/fpdart.dart';

class DeleteBudget implements UseCase<Unit, String> {
  const DeleteBudget(this._repository);

  final BudgetRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(String id) {
    return _repository.deleteBudget(id);
  }
}
