import 'package:dynora_finance/features/budget/data/dto/budget_dto.dart';

/// Contract any remote provider must implement to sync budgets.
///
/// Implementations must throw `RemoteDataSourceException` on failure.
/// Deletions travel as DTOs with `isDeleted: true`.
abstract interface class BudgetRemoteDataSource {
  /// Returns every budget (deleted ones included) whose `updatedAt` is after
  /// [since], or all of them when [since] is `null`.
  Future<List<BudgetDto>> fetchChangedSince(DateTime? since);

  /// Creates or replaces the given budgets on the remote provider.
  Future<void> upsert(List<BudgetDto> budgets);
}
