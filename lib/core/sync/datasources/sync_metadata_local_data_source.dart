import 'package:dynora_finance/core/error/exceptions.dart';
import 'package:dynora_finance/core/sync/models/sync_metadata_model.dart';
import 'package:isar_community/isar.dart';

abstract interface class SyncMetadataLocalDataSource {
  Future<DateTime?> getLastPulledAt(String entityName);

  Future<void> saveLastPulledAt(String entityName, DateTime value);
}

class SyncMetadataLocalDataSourceImpl implements SyncMetadataLocalDataSource {
  const SyncMetadataLocalDataSourceImpl(this._isar);

  final Isar _isar;

  @override
  Future<DateTime?> getLastPulledAt(String entityName) async {
    try {
      final metadata = await _isar.syncMetadataModels.getByEntityName(
        entityName,
      );
      return metadata?.lastPulledAt;
    } on IsarError catch (e) {
      throw LocalDatabaseException(e.message);
    }
  }

  @override
  Future<void> saveLastPulledAt(String entityName, DateTime value) async {
    try {
      final metadata = SyncMetadataModel()
        ..entityName = entityName
        ..lastPulledAt = value;
      await _isar.writeTxn(
        () => _isar.syncMetadataModels.putByEntityName(metadata),
      );
    } on IsarError catch (e) {
      throw LocalDatabaseException(e.message);
    }
  }
}
