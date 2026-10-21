import 'package:dynora_finance/core/error/failures.dart';
import 'package:dynora_finance/core/usecase/usecase.dart';
import 'package:dynora_finance/features/debts/domain/repositories/debt_repository.dart';
import 'package:fpdart/fpdart.dart';

/// Saves who owes you what for one movement (replacing the previous split).
class SetMovementDebts implements UseCase<Unit, SetMovementDebtsParams> {
  const SetMovementDebts(this._repository);

  final DebtRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(SetMovementDebtsParams params) async {
    final owed = params.shares.values.fold<double>(0, (sum, a) => sum + a);
    if (params.shares.values.any((a) => a <= 0 || a.isNaN || a.isInfinite)) {
      return left(
        const ValidationFailure('Cada persona debe deber más de \$0'),
      );
    }
    if (owed > params.movementAmount + 0.005) {
      return left(
        const ValidationFailure(
          'Lo que te deben no puede superar el monto del movimiento',
        ),
      );
    }
    return _repository.setMovementDebts(params.movementId, params.shares);
  }
}

class SetMovementDebtsParams {
  const SetMovementDebtsParams({
    required this.movementId,
    required this.movementAmount,
    required this.shares,
  });

  /// Removes every debt of [movementId].
  const SetMovementDebtsParams.clear(this.movementId)
    : movementAmount = 0,
      shares = const {};

  final String movementId;
  final double movementAmount;

  /// Person id → amount owed.
  final Map<String, double> shares;
}
