import 'package:dynora_finance/core/error/failures.dart';
import 'package:dynora_finance/core/error/guard.dart';
import 'package:dynora_finance/core/sync/datasources/sync_metadata_local_data_source.dart';
import 'package:dynora_finance/core/sync/sync_handler.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class SyncEngine {
  bool get isEnabled;

  Future<Either<Failure, Unit>> sync();
}

/// Used while the app is offline only: records stay pending until a
/// [RemoteSyncEngine] is registered, then they are pushed on the first sync.
class OfflineSyncEngine implements SyncEngine {
  const OfflineSyncEngine();

  @override
  bool get isEnabled => false;

  @override
  Future<Either<Failure, Unit>> sync() async => right(unit);
}

/// Pushes local changes, then pulls remote changes, for every handler.
class RemoteSyncEngine implements SyncEngine {
  RemoteSyncEngine({
    required List<SyncHandler> handlers,
    required SyncMetadataLocalDataSource metadata,
  }) : _handlers = handlers,
       _metadata = metadata;

  final List<SyncHandler> _handlers;
  final SyncMetadataLocalDataSource _metadata;
  Future<Either<Failure, Unit>>? _running;

  @override
  bool get isEnabled => true;

  @override
  Future<Either<Failure, Unit>> sync() {
    // Concurrent calls share the run in progress.
    return _running ??= _syncAll().whenComplete(() => _running = null);
  }

  Future<Either<Failure, Unit>> _syncAll() {
    return guard(() async {
      for (final handler in _handlers) {
        await handler.push();
        final since = await _metadata.getLastPulledAt(handler.entityName);
        final cursor = await handler.pull(since: since);
        if (cursor != null) {
          await _metadata.saveLastPulledAt(handler.entityName, cursor);
        }
      }
      return unit;
    });
  }
}
