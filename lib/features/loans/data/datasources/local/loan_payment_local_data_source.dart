import 'package:dynora_finance/core/error/exceptions.dart';
import 'package:dynora_finance/core/sync/sync_status.dart';
import 'package:dynora_finance/features/loans/data/models/loan_payment_model.dart';
import 'package:isar_community/isar.dart';

abstract interface class LoanPaymentLocalDataSource {
  /// Emits non-deleted payments.
  Stream<List<LoanPaymentModel>> watchPayments();

  /// Payments of [loanId], including tombstones.
  Future<List<LoanPaymentModel>> getByLoan(String loanId);

  /// Returns the payment with [uid], including tombstones.
  Future<LoanPaymentModel?> getByUid(String uid);

  Future<void> saveAll(List<LoanPaymentModel> models);

  Future<void> purgeAll(List<String> uids);

  /// Records with local changes not yet pushed to the remote provider.
  Future<List<LoanPaymentModel>> getPendingSync();
}

class LoanPaymentLocalDataSourceImpl implements LoanPaymentLocalDataSource {
  const LoanPaymentLocalDataSourceImpl(this._isar);

  final Isar _isar;

  IsarCollection<LoanPaymentModel> get _collection => _isar.loanPaymentModels;

  @override
  Stream<List<LoanPaymentModel>> watchPayments() {
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
  Future<List<LoanPaymentModel>> getByLoan(String loanId) {
    return _run(() => _collection.filter().loanIdEqualTo(loanId).findAll());
  }

  @override
  Future<LoanPaymentModel?> getByUid(String uid) {
    return _run(() => _collection.getByUid(uid));
  }

  @override
  Future<void> saveAll(List<LoanPaymentModel> models) {
    return _run(() => _isar.writeTxn(() => _collection.putAllByUid(models)));
  }

  @override
  Future<void> purgeAll(List<String> uids) {
    return _run(() => _isar.writeTxn(() => _collection.deleteAllByUid(uids)));
  }

  @override
  Future<List<LoanPaymentModel>> getPendingSync() {
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
