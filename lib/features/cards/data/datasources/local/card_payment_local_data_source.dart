import 'package:dynora_finance/core/error/exceptions.dart';
import 'package:dynora_finance/core/sync/sync_status.dart';
import 'package:dynora_finance/features/cards/data/models/card_payment_model.dart';
import 'package:isar_community/isar.dart';

abstract interface class CardPaymentLocalDataSource {
  /// Emits non-deleted payments.
  Stream<List<CardPaymentModel>> watchPayments();

  /// Returns the payment with [uid], including tombstones.
  Future<CardPaymentModel?> getByUid(String uid);

  Future<void> save(CardPaymentModel model);

  Future<void> saveAll(List<CardPaymentModel> models);

  /// Permanently removes the record (no tombstone).
  Future<void> purge(String uid);

  Future<void> purgeAll(List<String> uids);

  /// Records with local changes not yet pushed to the remote provider.
  Future<List<CardPaymentModel>> getPendingSync();
}

class CardPaymentLocalDataSourceImpl implements CardPaymentLocalDataSource {
  const CardPaymentLocalDataSourceImpl(this._isar);

  final Isar _isar;

  IsarCollection<CardPaymentModel> get _collection => _isar.cardPaymentModels;

  @override
  Stream<List<CardPaymentModel>> watchPayments() {
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
  Future<CardPaymentModel?> getByUid(String uid) {
    return _run(() => _collection.getByUid(uid));
  }

  @override
  Future<void> save(CardPaymentModel model) {
    return _run(() => _isar.writeTxn(() => _collection.putByUid(model)));
  }

  @override
  Future<void> saveAll(List<CardPaymentModel> models) {
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
  Future<List<CardPaymentModel>> getPendingSync() {
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
