import 'package:dynora_finance/core/error/failures.dart';
import 'package:dynora_finance/features/debts/domain/entities/debt_entity.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class DebtRepository {
  /// Emits every debt and each subsequent change.
  Stream<Either<Failure, List<DebtEntity>>> watchDebts();

  /// Makes the debts of [movementId] exactly [shares] (person id → amount):
  /// updates existing ones keeping their paid status, adds new ones and
  /// removes the rest. An empty map removes every debt of the movement.
  Future<Either<Failure, Unit>> setMovementDebts(
    String movementId,
    Map<String, double> shares,
  );

  /// Marks the debts [ids] as paid on [paidAt], or as pending when `null`.
  Future<Either<Failure, Unit>> setPaid(List<String> ids, DateTime? paidAt);
}
