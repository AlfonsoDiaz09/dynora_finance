import 'package:dynora_finance/core/error/exceptions.dart';
import 'package:dynora_finance/core/sync/sync_status.dart';
import 'package:dynora_finance/features/loans/data/models/loan_model.dart';
import 'package:isar_community/isar.dart';

abstract interface class LoanLocalDataSource {
  /// Emits non-deleted loans, oldest first.
  Stream<List<LoanModel>> watchLoans();

  /// Returns the loan with [uid], including tombstones.
  Future<LoanModel?> getByUid(String uid);

  Future<void> saveAll(List<LoanModel> models);

  Future<void> purgeAll(List<String> uids);

  /// Records with local changes not yet pushed to the remote provider.
  Future<List<LoanModel>> getPendingSync();
}

class LoanLocalDataSourceImpl implements LoanLocalDataSource {
  const LoanLocalDataSourceImpl(this._isar);

  final Isar _isar;

  IsarCollection<LoanModel> get _collection => _isar.loanModels;

  @override
  Stream<List<LoanModel>> watchLoans() {
    return _collection
        .filter()
        .isDeletedEqualTo(false)
        .sortByStartDate()
        .watch(fireImmediately: true)
        .handleError(
          (Object e) => throw LocalDatabaseException(e.toString()),
          test: (e) => e is IsarError,
        );
  }

  @override
  Future<LoanModel?> getByUid(String uid) {
    return _run(() => _collection.getByUid(uid));
  }

  @override
  Future<void> saveAll(List<LoanModel> models) {
    return _run(() => _isar.writeTxn(() => _collection.putAllByUid(models)));
  }

  @override
  Future<void> purgeAll(List<String> uids) {
    return _run(() => _isar.writeTxn(() => _collection.deleteAllByUid(uids)));
  }

  @override
  Future<List<LoanModel>> getPendingSync() {
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
