import 'package:dynora_finance/core/enums/movement_type.dart';
import 'package:dynora_finance/core/error/failures.dart';
import 'package:dynora_finance/features/movements/domain/entities/movement_entity.dart';
import 'package:dynora_finance/features/movements/domain/entities/movement_filter.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class MovementRepository {
  Future<Either<Failure, List<MovementEntity>>> getMovements(
    MovementFilter filter,
  );

  /// Emits the current list and every subsequent change.
  Stream<Either<Failure, List<MovementEntity>>> watchMovements(
    MovementFilter filter,
  );

  Future<Either<Failure, MovementEntity>> getMovementById(String id);

  Future<Either<Failure, MovementEntity>> createMovement({
    required String title,
    required double amount,
    required MovementType type,
    required String categoryId,
    required DateTime date,
    String? note,
    String? cardId,
  });

  Future<Either<Failure, MovementEntity>> updateMovement(
    MovementEntity movement,
  );

  Future<Either<Failure, Unit>> deleteMovement(String id);
}
