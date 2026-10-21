import 'package:dynora_finance/core/error/exceptions.dart';
import 'package:dynora_finance/core/sync/sync_status.dart';
import 'package:dynora_finance/features/debts/data/models/person_model.dart';
import 'package:isar_community/isar.dart';

abstract interface class PersonLocalDataSource {
  /// Emits non-deleted people sorted by name.
  Stream<List<PersonModel>> watchPeople();

  /// Non-deleted person called [name], ignoring case.
  Future<PersonModel?> findByName(String name);

  /// Returns the person with [uid], including tombstones.
  Future<PersonModel?> getByUid(String uid);

  Future<void> save(PersonModel model);

  Future<void> saveAll(List<PersonModel> models);

  Future<void> purgeAll(List<String> uids);

  /// Records with local changes not yet pushed to the remote provider.
  Future<List<PersonModel>> getPendingSync();
}

class PersonLocalDataSourceImpl implements PersonLocalDataSource {
  const PersonLocalDataSourceImpl(this._isar);

  final Isar _isar;

  IsarCollection<PersonModel> get _collection => _isar.personModels;

  @override
  Stream<List<PersonModel>> watchPeople() {
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
  Future<PersonModel?> findByName(String name) {
    return _run(
      () => _collection
          .filter()
          .isDeletedEqualTo(false)
          .and()
          .nameEqualTo(name, caseSensitive: false)
          .findFirst(),
    );
  }

  @override
  Future<PersonModel?> getByUid(String uid) {
    return _run(() => _collection.getByUid(uid));
  }

  @override
  Future<void> save(PersonModel model) {
    return _run(() => _isar.writeTxn(() => _collection.putByUid(model)));
  }

  @override
  Future<void> saveAll(List<PersonModel> models) {
    return _run(() => _isar.writeTxn(() => _collection.putAllByUid(models)));
  }

  @override
  Future<void> purgeAll(List<String> uids) {
    return _run(() => _isar.writeTxn(() => _collection.deleteAllByUid(uids)));
  }

  @override
  Future<List<PersonModel>> getPendingSync() {
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
