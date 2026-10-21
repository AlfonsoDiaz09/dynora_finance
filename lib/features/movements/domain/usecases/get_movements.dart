import 'package:dynora_finance/core/error/failures.dart';
import 'package:dynora_finance/core/usecase/usecase.dart';
import 'package:dynora_finance/features/movements/domain/entities/movement_entity.dart';
import 'package:dynora_finance/features/movements/domain/entities/movement_filter.dart';
import 'package:dynora_finance/features/movements/domain/repositories/movement_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetMovements implements UseCase<List<MovementEntity>, MovementFilter> {
  const GetMovements(this._repository);

  final MovementRepository _repository;

  @override
  Future<Either<Failure, List<MovementEntity>>> call(MovementFilter filter) {
    return _repository.getMovements(filter);
  }
}
