import 'package:dynora_finance/core/enums/movement_type.dart';
import 'package:dynora_finance/core/error/exceptions.dart';
import 'package:dynora_finance/core/sync/sync_status.dart';
import 'package:dynora_finance/features/categories/data/models/category_model.dart';
import 'package:isar_community/isar.dart';

abstract interface class CategoryLocalDataSource {
  /// Returns non-deleted categories sorted by name.
  Future<List<CategoryModel>> getCategories({MovementType? type});

  Stream<List<CategoryModel>> watchCategories({MovementType? type});

  /// Returns the category with [uid], including tombstones.
  Future<CategoryModel?> getByUid(String uid);

  Future<void> save(CategoryModel model);

  Future<void> saveAll(List<CategoryModel> models);

  /// Permanently removes the record (no tombstone).
  Future<void> purge(String uid);

  Future<void> purgeAll(List<String> uids);

  /// Records with local changes not yet pushed to the remote provider.
  Future<List<CategoryModel>> getPendingSync();
}

class CategoryLocalDataSourceImpl implements CategoryLocalDataSource {
  const CategoryLocalDataSourceImpl(this._isar);

  final Isar _isar;

  IsarCollection<CategoryModel> get _collection => _isar.categoryModels;

  @override
  Future<List<CategoryModel>> getCategories({MovementType? type}) {
    return _run(() => _query(type).findAll());
  }

  @override
  Stream<List<CategoryModel>> watchCategories({MovementType? type}) {
    return _query(type)
        .watch(fireImmediately: true)
        .handleError(
          (Object e) => throw LocalDatabaseException(e.toString()),
          test: (e) => e is IsarError,
        );
  }

  @override
  Future<CategoryModel?> getByUid(String uid) {
    return _run(() => _collection.getByUid(uid));
  }

  @override
  Future<void> save(CategoryModel model) {
    return _run(() => _isar.writeTxn(() => _collection.putByUid(model)));
  }

  @override
  Future<void> saveAll(List<CategoryModel> models) {
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
  Future<List<CategoryModel>> getPendingSync() {
    return _run(
      () => _collection
          .filter()
          .not()
          .syncStatusEqualTo(SyncStatus.synced)
          .findAll(),
    );
  }

  QueryBuilder<CategoryModel, CategoryModel, QAfterSortBy> _query(
    MovementType? type,
  ) {
    return _collection
        .filter()
        .isDeletedEqualTo(false)
        .optional(type != null, (q) => q.and().typeEqualTo(type!))
        .sortByName();
  }

  Future<T> _run<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on IsarError catch (e) {
      throw LocalDatabaseException(e.message);
    }
  }
}
