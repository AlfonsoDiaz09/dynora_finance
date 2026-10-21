import 'package:dynora_finance/core/error/failures.dart';
import 'package:dynora_finance/core/usecase/usecase.dart';
import 'package:dynora_finance/features/cards/domain/entities/card_entity.dart';
import 'package:dynora_finance/features/cards/domain/repositories/card_repository.dart';
import 'package:dynora_finance/features/cards/domain/usecases/card_validator.dart';
import 'package:fpdart/fpdart.dart';

class AddCard implements UseCase<CardEntity, AddCardParams> {
  const AddCard(this._repository);

  final CardRepository _repository;

  @override
  Future<Either<Failure, CardEntity>> call(AddCardParams params) async {
    final failure = CardValidator.validate(
      name: params.name,
      paymentDueDay: params.paymentDueDay,
    );
    if (failure != null) return left(failure);

    return _repository.createCard(
      name: params.name.trim(),
      paymentDueDay: params.paymentDueDay,
      colorValue: params.colorValue,
    );
  }
}

class AddCardParams {
  const AddCardParams({
    required this.name,
    required this.paymentDueDay,
    required this.colorValue,
  });

  final String name;
  final int paymentDueDay;
  final int colorValue;
}
