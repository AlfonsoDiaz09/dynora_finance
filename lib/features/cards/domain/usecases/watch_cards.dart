import 'package:dynora_finance/core/error/failures.dart';
import 'package:dynora_finance/core/usecase/usecase.dart';
import 'package:dynora_finance/features/cards/domain/entities/card_entity.dart';
import 'package:dynora_finance/features/cards/domain/repositories/card_repository.dart';
import 'package:fpdart/fpdart.dart';

class WatchCards implements StreamUseCase<List<CardEntity>, NoParams> {
  const WatchCards(this._repository);

  final CardRepository _repository;

  @override
  Stream<Either<Failure, List<CardEntity>>> call(NoParams params) {
    return _repository.watchCards();
  }
}
