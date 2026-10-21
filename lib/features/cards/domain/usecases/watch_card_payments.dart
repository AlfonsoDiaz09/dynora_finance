import 'package:dynora_finance/core/error/failures.dart';
import 'package:dynora_finance/core/usecase/usecase.dart';
import 'package:dynora_finance/features/cards/domain/entities/card_payment_entity.dart';
import 'package:dynora_finance/features/cards/domain/repositories/card_payment_repository.dart';
import 'package:fpdart/fpdart.dart';

class WatchCardPayments
    implements StreamUseCase<List<CardPaymentEntity>, NoParams> {
  const WatchCardPayments(this._repository);

  final CardPaymentRepository _repository;

  @override
  Stream<Either<Failure, List<CardPaymentEntity>>> call(NoParams params) {
    return _repository.watchPayments();
  }
}
