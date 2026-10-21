import 'package:dynora_finance/features/cards/data/dto/card_dto.dart';

/// Contract any remote provider must implement to sync cards.
///
/// Implementations must throw `RemoteDataSourceException` on failure.
/// Deletions travel as DTOs with `isDeleted: true`.
abstract interface class CardRemoteDataSource {
  /// Returns every card (deleted ones included) whose `updatedAt` is after
  /// [since], or all of them when [since] is `null`.
  Future<List<CardDto>> fetchChangedSince(DateTime? since);

  /// Creates or replaces the given cards on the remote provider.
  Future<void> upsert(List<CardDto> cards);
}
