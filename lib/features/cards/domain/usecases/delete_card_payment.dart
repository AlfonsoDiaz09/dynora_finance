import 'package:dynora_finance/core/error/failures.dart';
import 'package:dynora_finance/core/usecase/usecase.dart';
import 'package:dynora_finance/features/cards/domain/repositories/card_payment_repository.dart';
import 'package:fpdart/fpdart.dart';

class DeleteCardPayment implements UseCase<Unit, String> {
  const DeleteCardPayment(this._repository);

  final CardPaymentRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(String id) {
    return _repository.deletePayment(id);
  }
}
