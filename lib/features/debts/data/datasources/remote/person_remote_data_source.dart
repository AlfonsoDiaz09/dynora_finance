import 'package:dynora_finance/features/debts/data/dto/person_dto.dart';

/// Contract any remote provider must implement to sync people.
///
/// Implementations must throw `RemoteDataSourceException` on failure.
/// Deletions travel as DTOs with `isDeleted: true`.
abstract interface class PersonRemoteDataSource {
  /// Returns every person (deleted ones included) whose `updatedAt` is after
  /// [since], or all of them when [since] is `null`.
  Future<List<PersonDto>> fetchChangedSince(DateTime? since);

  /// Creates or replaces the given people on the remote provider.
  Future<void> upsert(List<PersonDto> people);
}
