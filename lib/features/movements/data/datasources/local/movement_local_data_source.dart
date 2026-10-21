import 'package:dynora_finance/core/error/exceptions.dart';
import 'package:dynora_finance/core/sync/sync_status.dart';
import 'package:dynora_finance/features/movements/data/models/movement_model.dart';
import 'package:dynora_finance/features/movements/domain/entities/movement_filter.dart';
import 'package:isar_community/isar.dart';

abstract interface class MovementLocalDataSource {
  /// Returns non-deleted movements, newest first.
  Future<List<MovementModel>> getMovements(MovementFilter filter);

  Stream<List<MovementModel>> watchMovements(MovementFilter filter);

  /// Returns the movement with [uid], including tombstones.
  Future<MovementModel?> getByUid(String uid);

  Future<void> save(MovementModel model);

  Future<void> saveAll(List<MovementModel> models);

  /// Permanently removes the record (no tombstone).
  Future<void> purge(String uid);

  Future<void> purgeAll(List<String> uids);

  /// Records with local changes not yet pushed to the remote provider.
  Future<List<MovementModel>> getPendingSync();
}

class MovementLocalDataSourceImpl implements MovementLocalDataSource {
  const MovementLocalDataSourceImpl(this._isar);

  final Isar _isar;

  IsarCollection<MovementModel> get _collection => _isar.movementModels;

  @override
  Future<List<MovementModel>> getMovements(MovementFilter filter) {
    return _run(() => _query(filter).findAll());
  }

  @override
  Stream<List<MovementModel>> watchMovements(MovementFilter filter) {
    return _query(filter)
        .watch(fireImmediately: true)
        .handleError(
          (Object e) => throw LocalDatabaseException(e.toString()),
          test: (e) => e is IsarError,
        );
  }

  @override
  Future<MovementModel?> getByUid(String uid) {
    return _run(() => _collection.getByUid(uid));
  }

  @override
  Future<void> save(MovementModel model) {
    return _run(() => _isar.writeTxn(() => _collection.putByUid(model)));
  }

  @override
  Future<void> saveAll(List<MovementModel> models) {
    return _run(() => _isar.writeTxn(() => _collection.putAllByUid(models)));
  }

  @override
  Future<void> purge(String uid) {
    return _run(() => _isar.writeTxn(() => _collection.deleteByUid(uid)));
  }

  @override
  Future<void> purgeAll(List<String> uids) {
    return _run(() => _isar.writeTxn(() => _collection.deleteAllByUid(uids)));
  }

  @override
  Future<List<MovementModel>> getPendingSync() {
    return _run(
      () => _collection
          .filter()
          .not()
          .syncStatusEqualTo(SyncStatus.synced)
          .findAll(),
    );
  }

  QueryBuilder<MovementModel, MovementModel, QAfterSortBy> _query(
    MovementFilter filter,
  ) {
    return _collection
        .filter()
        .isDeletedEqualTo(false)
        .optional(filter.type != null, (q) => q.and().typeEqualTo(filter.type!))
        .optional(
          filter.categoryId != null,
          (q) => q.and().categoryIdEqualTo(filter.categoryId!),
        )
        .optional(
          filter.cardId != null,
          (q) => q.and().cardIdEqualTo(filter.cardId),
        )
        .optional(
          filter.from != null,
          (q) => q.and().dateGreaterThan(filter.from!, include: true),
        )
        .optional(
          filter.to != null,
          (q) => q.and().dateLessThan(filter.to!, include: true),
        )
        .sortByDateDesc()
        .thenByCreatedAtDesc();
  }

  Future<T> _run<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on IsarError catch (e) {
      throw LocalDatabaseException(e.message);
    }
  }
}
