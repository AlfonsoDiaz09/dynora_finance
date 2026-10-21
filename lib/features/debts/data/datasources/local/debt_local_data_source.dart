import 'package:dynora_finance/core/error/exceptions.dart';
import 'package:dynora_finance/core/sync/sync_status.dart';
import 'package:dynora_finance/features/debts/data/models/debt_model.dart';
import 'package:isar_community/isar.dart';

abstract interface class DebtLocalDataSource {
  /// Emits non-deleted debts.
  Stream<List<DebtModel>> watchDebts();

  /// Debts of [movementId], including tombstones.
  Future<List<DebtModel>> getByMovement(String movementId);

  /// Returns the debts with [uids] that exist, including tombstones.
  Future<List<DebtModel>> getByUids(List<String> uids);

  Future<DebtModel?> getByUid(String uid);

  Future<void> saveAll(List<DebtModel> models);

  Future<void> purgeAll(List<String> uids);

  /// Records with local changes not yet pushed to the remote provider.
  Future<List<DebtModel>> getPendingSync();
}

class DebtLocalDataSourceImpl implements DebtLocalDataSource {
  const DebtLocalDataSourceImpl(this._isar);

  final Isar _isar;

  IsarCollection<DebtModel> get _collection => _isar.debtModels;

  @override
  Stream<List<DebtModel>> watchDebts() {
    return _collection
        .filter()
        .isDeletedEqualTo(false)
        .watch(fireImmediately: true)
        .handleError(
          (Object e) => throw LocalDatabaseException(e.toString()),
          test: (e) => e is IsarError,
        );
  }

  @override
  Future<List<DebtModel>> getByMovement(String movementId) {
    return _run(
      () => _collection.filter().movementIdEqualTo(movementId).findAll(),
    );
  }

  @override
  Future<List<DebtModel>> getByUids(List<String> uids) {
    return _run(
      () async =>
          (await _collection.getAllByUid(uids)).whereType<DebtModel>().toList(),
    );
  }

  @override
  Future<DebtModel?> getByUid(String uid) {
    return _run(() => _collection.getByUid(uid));
  }

  @override
  Future<void> saveAll(List<DebtModel> models) {
    return _run(() => _isar.writeTxn(() => _collection.putAllByUid(models)));
  }

  @override
  Future<void> purgeAll(List<String> uids) {
    return _run(() => _isar.writeTxn(() => _collection.deleteAllByUid(uids)));
  }

  @override
  Future<List<DebtModel>> getPendingSync() {
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
