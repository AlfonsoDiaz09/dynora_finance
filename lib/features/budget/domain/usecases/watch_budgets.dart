import 'package:dynora_finance/core/error/failures.dart';
import 'package:dynora_finance/core/usecase/usecase.dart';
import 'package:dynora_finance/features/budget/domain/entities/budget_entity.dart';
import 'package:dynora_finance/features/budget/domain/repositories/budget_repository.dart';
import 'package:fpdart/fpdart.dart';

class WatchBudgets implements StreamUseCase<List<BudgetEntity>, NoParams> {
  const WatchBudgets(this._repository);

  final BudgetRepository _repository;

  @override
  Stream<Either<Failure, List<BudgetEntity>>> call(NoParams params) {
    return _repository.watchBudgets();
  }
}
