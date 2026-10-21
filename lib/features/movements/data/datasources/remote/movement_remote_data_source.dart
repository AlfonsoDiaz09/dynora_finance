import 'package:dynora_finance/features/movements/data/dto/movement_dto.dart';

/// Contract any remote provider must implement to sync movements.
///
/// Implementations (Supabase, Firestore, REST, ...) must throw
/// `RemoteDataSourceException` on failure. Deletions travel as DTOs with
/// `isDeleted: true` so other devices can apply them on pull.
abstract interface class MovementRemoteDataSource {
  /// Returns every movement (deleted ones included) whose `updatedAt` is
  /// after [since], or all of them when [since] is `null`.
  Future<List<MovementDto>> fetchChangedSince(DateTime? since);

  /// Creates or replaces the given movements on the remote provider.
  Future<void> upsert(List<MovementDto> movements);
}
