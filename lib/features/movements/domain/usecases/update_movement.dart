import 'package:dynora_finance/core/error/failures.dart';
import 'package:dynora_finance/core/usecase/usecase.dart';
import 'package:dynora_finance/features/movements/domain/entities/movement_entity.dart';
import 'package:dynora_finance/features/movements/domain/repositories/movement_repository.dart';
import 'package:dynora_finance/features/movements/domain/usecases/movement_validator.dart';
import 'package:fpdart/fpdart.dart';

class UpdateMovement implements UseCase<MovementEntity, MovementEntity> {
  const UpdateMovement(this._repository);

  final MovementRepository _repository;

  @override
  Future<Either<Failure, MovementEntity>> call(MovementEntity movement) async {
    final failure = MovementValidator.validate(
      title: movement.title,
      amount: movement.amount,
      categoryId: movement.categoryId,
      cardId: movement.cardId,
      installmentCount: movement.installmentCount,
      installmentRate: movement.installmentRate,
    );
    if (failure != null) return left(failure);

    return _repository.updateMovement(
      movement.copyWith(title: movement.title.trim()),
    );
  }
}
