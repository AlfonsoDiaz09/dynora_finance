import 'package:dynora_finance/core/error/failures.dart';
import 'package:dynora_finance/core/usecase/usecase.dart';
import 'package:dynora_finance/features/debts/domain/entities/debt_entity.dart';
import 'package:dynora_finance/features/debts/domain/repositories/debt_repository.dart';
import 'package:fpdart/fpdart.dart';

class WatchDebts implements StreamUseCase<List<DebtEntity>, NoParams> {
  const WatchDebts(this._repository);

  final DebtRepository _repository;

  @override
  Stream<Either<Failure, List<DebtEntity>>> call(NoParams params) {
    return _repository.watchDebts();
  }
}
