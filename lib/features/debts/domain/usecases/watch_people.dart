import 'package:dynora_finance/core/error/failures.dart';
import 'package:dynora_finance/core/usecase/usecase.dart';
import 'package:dynora_finance/features/debts/domain/entities/person_entity.dart';
import 'package:dynora_finance/features/debts/domain/repositories/person_repository.dart';
import 'package:fpdart/fpdart.dart';

class WatchPeople implements StreamUseCase<List<PersonEntity>, NoParams> {
  const WatchPeople(this._repository);

  final PersonRepository _repository;

  @override
  Stream<Either<Failure, List<PersonEntity>>> call(NoParams params) {
    return _repository.watchPeople();
  }
}
