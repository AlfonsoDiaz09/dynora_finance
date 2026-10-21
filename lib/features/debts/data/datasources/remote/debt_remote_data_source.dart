import 'package:dynora_finance/features/debts/data/dto/debt_dto.dart';

/// Contract any remote provider must implement to sync debts.
///
/// Implementations must throw `RemoteDataSourceException` on failure.
/// Deletions travel as DTOs with `isDeleted: true`.
abstract interface class DebtRemoteDataSource {
  /// Returns every debt (deleted ones included) whose `updatedAt` is after
  /// [since], or all of them when [since] is `null`.
  Future<List<DebtDto>> fetchChangedSince(DateTime? since);

  /// Creates or replaces the given debts on the remote provider.
  Future<void> upsert(List<DebtDto> debts);
}
