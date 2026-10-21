import 'package:dynora_finance/core/error/failures.dart';
import 'package:dynora_finance/core/usecase/usecase.dart';
import 'package:dynora_finance/features/debts/domain/repositories/debt_repository.dart';
import 'package:fpdart/fpdart.dart';

/// Marks debts as paid on a day (it can be in the past) or back to pending.
class SetDebtsPaid implements UseCase<Unit, SetDebtsPaidParams> {
  const SetDebtsPaid(this._repository, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final DebtRepository _repository;
  final DateTime Function() _clock;

  @override
  Future<Either<Failure, Unit>> call(SetDebtsPaidParams params) async {
    if (params.ids.isEmpty) return right(unit);
    final paidAt = params.paidAt;
    if (paidAt == null) return _repository.setPaid(params.ids, null);

    final now = _clock();
    final day = DateTime(paidAt.year, paidAt.month, paidAt.day);
    if (day.isAfter(DateTime(now.year, now.month, now.day))) {
      return left(
        const ValidationFailure('La fecha de pago no puede ser futura'),
      );
    }
    return _repository.setPaid(params.ids, day);
  }
}

class SetDebtsPaidParams {
  const SetDebtsPaidParams({required this.ids, required this.paidAt});

  final List<String> ids;

  /// `null` marks the debts as pending again.
  final DateTime? paidAt;
}
