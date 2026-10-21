/// Synchronizes one entity type (movements, categories, ...) between the
/// local database and a remote provider.
abstract interface class SyncHandler {
  /// Unique key used to store the pull cursor of this entity.
  String get entityName;

  /// Sends every pending local change to the remote provider.
  Future<void> push();

  /// Applies remote changes made after [since] and returns the new cursor,
  /// or `null` when nothing changed.
  Future<DateTime?> pull({DateTime? since});
}
