import 'package:dynora_finance/core/error/failures.dart';
import 'package:dynora_finance/features/cards/domain/entities/card_entity.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class CardRepository {
  /// Emits the current cards (sorted by name) and every subsequent change.
  Stream<Either<Failure, List<CardEntity>>> watchCards();

  Future<Either<Failure, CardEntity>> createCard({
    required String name,
    required int paymentDueDay,
    required int colorValue,
  });

  Future<Either<Failure, CardEntity>> updateCard(CardEntity card);

  Future<Either<Failure, Unit>> deleteCard(String id);
}
