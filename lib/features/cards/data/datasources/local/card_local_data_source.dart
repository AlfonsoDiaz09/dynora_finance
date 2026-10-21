import 'package:dynora_finance/core/error/exceptions.dart';
import 'package:dynora_finance/core/sync/sync_status.dart';
import 'package:dynora_finance/features/cards/data/models/card_model.dart';
import 'package:isar_community/isar.dart';

abstract interface class CardLocalDataSource {
  /// Emits non-deleted cards sorted by name.
  Stream<List<CardModel>> watchCards();

  /// Returns the card with [uid], including tombstones.
  Future<CardModel?> getByUid(String uid);

  Future<void> save(CardModel model);

  Future<void> saveAll(List<CardModel> models);

  /// Permanently removes the record (no tombstone).
  Future<void> purge(String uid);

  Future<void> purgeAll(List<String> uids);

  /// Records with local changes not yet pushed to the remote provider.
  Future<List<CardModel>> getPendingSync();
}

class CardLocalDataSourceImpl implements CardLocalDataSource {
  const CardLocalDataSourceImpl(this._isar);

  final Isar _isar;

  IsarCollection<CardModel> get _collection => _isar.cardModels;

  @override
  Stream<List<CardModel>> watchCards() {
    return _collection
        .filter()
        .isDeletedEqualTo(false)
        .sortByName()
        .watch(fireImmediately: true)
        .handleError(
          (Object e) => throw LocalDatabaseException(e.toString()),
          test: (e) => e is IsarError,
        );
  }

  @override
  Future<CardModel?> getByUid(String uid) {
    return _run(() => _collection.getByUid(uid));
  }

  @override
  Future<void> save(CardModel model) {
    return _run(() => _isar.writeTxn(() => _collection.putByUid(model)));
  }

  @override
  Future<void> saveAll(List<CardModel> models) {
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
  Future<List<CardModel>> getPendingSync() {
    return _run(
      () => _collection
          .filter()
          .not()
          .syncStatusEqualTo(SyncStatus.synced)
          .findAll(),
    );
  }

  Future<T> _run<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on IsarError catch (e) {
      throw LocalDatabaseException(e.message);
    }
  }
}
