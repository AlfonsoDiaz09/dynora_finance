import 'package:dynora_finance/features/cards/data/dto/card_payment_dto.dart';

/// Contract any remote provider must implement to sync card payments.
///
/// Implementations must throw `RemoteDataSourceException` on failure.
/// Deletions travel as DTOs with `isDeleted: true`.
abstract interface class CardPaymentRemoteDataSource {
  /// Returns every payment (deleted ones included) whose `updatedAt` is after
  /// [since], or all of them when [since] is `null`.
  Future<List<CardPaymentDto>> fetchChangedSince(DateTime? since);

  /// Creates or replaces the given payments on the remote provider.
  Future<void> upsert(List<CardPaymentDto> payments);
}
