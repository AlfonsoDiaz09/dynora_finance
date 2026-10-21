/// Sync state of a locally stored record.
///
/// Every local write marks the record as pending; a [SyncHandler] pushes
/// pending records to the remote provider and marks them as [synced].
enum SyncStatus {
  synced,
  pendingCreate,
  pendingUpdate,
  pendingDelete;

  bool get isPending => this != SyncStatus.synced;

  /// Status after a local edit: a record that never reached the remote
  /// stays a pending create.
  SyncStatus afterLocalUpdate() => this == SyncStatus.pendingCreate
      ? SyncStatus.pendingCreate
      : SyncStatus.pendingUpdate;
}
