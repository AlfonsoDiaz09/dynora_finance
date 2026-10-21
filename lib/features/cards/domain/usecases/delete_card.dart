import 'package:dynora_finance/core/error/failures.dart';
import 'package:dynora_finance/core/usecase/usecase.dart';
import 'package:dynora_finance/features/cards/domain/repositories/card_repository.dart';
import 'package:fpdart/fpdart.dart';

class DeleteCard implements UseCase<Unit, String> {
  const DeleteCard(this._repository);

  final CardRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(String id) {
    return _repository.deleteCard(id);
  }
}
