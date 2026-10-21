import 'package:dynora_finance/core/error/exceptions.dart';
import 'package:dynora_finance/core/sync/sync_status.dart';
import 'package:dynora_finance/features/budget/data/models/budget_model.dart';
import 'package:isar_community/isar.dart';

abstract interface class BudgetLocalDataSource {
  /// Emits non-deleted budgets.
  Stream<List<BudgetModel>> watchBudgets();

  /// Returns the budget with [uid], including tombstones.
  Future<BudgetModel?> getByUid(String uid);

  Future<void> save(BudgetModel model);

  Future<void> saveAll(List<BudgetModel> models);

  /// Permanently removes the record (no tombstone).
  Future<void> purge(String uid);

  Future<void> purgeAll(List<String> uids);

  /// Records with local changes not yet pushed to the remote provider.
  Future<List<BudgetModel>> getPendingSync();
}

class BudgetLocalDataSourceImpl implements BudgetLocalDataSource {
  const BudgetLocalDataSourceImpl(this._isar);

  final Isar _isar;

  IsarCollection<BudgetModel> get _collection => _isar.budgetModels;

  @override
  Stream<List<BudgetModel>> watchBudgets() {
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
  Future<BudgetModel?> getByUid(String uid) {
    return _run(() => _collection.getByUid(uid));
  }

  @override
  Future<void> save(BudgetModel model) {
    return _run(() => _isar.writeTxn(() => _collection.putByUid(model)));
  }

  @override
  Future<void> saveAll(List<BudgetModel> models) {
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
  Future<List<BudgetModel>> getPendingSync() {
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
