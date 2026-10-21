import 'package:dynora_finance/features/categories/data/dto/category_dto.dart';

/// Contract any remote provider must implement to sync categories.
///
/// Implementations must throw `RemoteDataSourceException` on failure.
/// Deletions travel as DTOs with `isDeleted: true`.
abstract interface class CategoryRemoteDataSource {
  /// Returns every category (deleted ones included) whose `updatedAt` is
  /// after [since], or all of them when [since] is `null`.
  Future<List<CategoryDto>> fetchChangedSince(DateTime? since);

  /// Creates or replaces the given categories on the remote provider.
  Future<void> upsert(List<CategoryDto> categories);
}
