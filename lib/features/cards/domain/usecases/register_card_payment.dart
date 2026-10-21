import 'package:dynora_finance/core/error/failures.dart';
import 'package:dynora_finance/core/usecase/usecase.dart';
import 'package:dynora_finance/features/cards/domain/entities/card_payment_entity.dart';
import 'package:dynora_finance/features/cards/domain/repositories/card_payment_repository.dart';
import 'package:fpdart/fpdart.dart';

class RegisterCardPayment
    implements UseCase<CardPaymentEntity, RegisterCardPaymentParams> {
  const RegisterCardPayment(this._repository, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final CardPaymentRepository _repository;
  final DateTime Function() _clock;

  @override
  Future<Either<Failure, CardPaymentEntity>> call(
    RegisterCardPaymentParams params,
  ) async {
    if (params.amount <= 0 || params.amount.isNaN || params.amount.isInfinite) {
      return left(const ValidationFailure('El monto debe ser mayor a 0'));
    }
    final now = _clock();
    final today = DateTime(now.year, now.month, now.day);
    final paidDay = DateTime(
      params.paidAt.year,
      params.paidAt.month,
      params.paidAt.day,
    );
    if (paidDay.isAfter(today)) {
      return left(
        const ValidationFailure('La fecha de pago no puede ser futura'),
      );
    }

    return _repository.registerPayment(
      cardId: params.cardId,
      periodStart: params.periodStart,
      amount: params.amount,
      paidAt: paidDay,
    );
  }
}

class RegisterCardPaymentParams {
  const RegisterCardPaymentParams({
    required this.cardId,
    required this.periodStart,
    required this.amount,
    required this.paidAt,
  });

  final String cardId;
  final DateTime periodStart;
  final double amount;
  final DateTime paidAt;
}
