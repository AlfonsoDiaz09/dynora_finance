import 'package:dynora_finance/core/error/failures.dart';
import 'package:dynora_finance/core/usecase/usecase.dart';
import 'package:dynora_finance/features/movements/domain/repositories/movement_repository.dart';
import 'package:fpdart/fpdart.dart';

class DeleteMovement implements UseCase<Unit, String> {
  const DeleteMovement(this._repository);

  final MovementRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(String id) {
    return _repository.deleteMovement(id);
  }
}
