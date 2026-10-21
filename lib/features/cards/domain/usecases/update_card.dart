import 'package:dynora_finance/core/error/failures.dart';
import 'package:dynora_finance/core/usecase/usecase.dart';
import 'package:dynora_finance/features/cards/domain/entities/card_entity.dart';
import 'package:dynora_finance/features/cards/domain/repositories/card_repository.dart';
import 'package:dynora_finance/features/cards/domain/usecases/card_validator.dart';
import 'package:fpdart/fpdart.dart';

class UpdateCard implements UseCase<CardEntity, CardEntity> {
  const UpdateCard(this._repository);

  final CardRepository _repository;

  @override
  Future<Either<Failure, CardEntity>> call(CardEntity card) async {
    final failure = CardValidator.validate(
      name: card.name,
      type: card.type,
      lastFourDigits: card.lastFourDigits,
      cutoffDay: card.cutoffDay,
      paymentDueDay: card.paymentDueDay,
    );
    if (failure != null) return left(failure);

    final billed = card.type.hasBillingCycle;
    return _repository.updateCard(
      card.copyWith(
        name: card.name.trim(),
        cutoffDay: () => billed ? card.cutoffDay : null,
        paymentDueDay: () => billed ? card.paymentDueDay : null,
      ),
    );
  }
}
