import 'package:dynora_finance/core/error/failures.dart';
import 'package:dynora_finance/features/cards/domain/entities/card_payment_entity.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class CardPaymentRepository {
  /// Emits every registered payment and each subsequent change.
  Stream<Either<Failure, List<CardPaymentEntity>>> watchPayments();

  /// Registers the payment of the statement of [cardId] starting on
  /// [periodStart], replacing a previous one for that statement.
  Future<Either<Failure, CardPaymentEntity>> registerPayment({
    required String cardId,
    required DateTime periodStart,
    required double amount,
    required DateTime paidAt,
  });

  Future<Either<Failure, Unit>> deletePayment(String id);
}
