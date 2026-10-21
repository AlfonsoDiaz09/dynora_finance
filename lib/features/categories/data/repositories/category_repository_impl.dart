import 'dart:async';

import 'package:dynora_finance/core/enums/movement_type.dart';
import 'package:dynora_finance/core/error/exceptions.dart';
import 'package:dynora_finance/core/error/failures.dart';
import 'package:dynora_finance/core/error/guard.dart';
import 'package:dynora_finance/core/sync/sync_engine.dart';
import 'package:dynora_finance/core/sync/sync_status.dart';
import 'package:dynora_finance/features/categories/data/datasources/local/category_local_data_source.dart';
import 'package:dynora_finance/features/categories/data/models/category_model.dart';
import 'package:dynora_finance/features/categories/domain/entities/category_entity.dart';
import 'package:dynora_finance/features/categories/domain/entities/default_categories.dart';
import 'package:dynora_finance/features/categories/domain/repositories/category_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';

/// Offline-first: the local database is the source of truth. Every write is
/// stored locally, flagged as pending, and a sync is requested in background.
class CategoryRepositoryImpl implements CategoryRepository {
  const CategoryRepositoryImpl({
    required CategoryLocalDataSource local,
    required SyncEngine syncEngine,
    required Uuid uuid,
  }) : _local = local,
       _syncEngine = syncEngine,
       _uuid = uuid;

  final CategoryLocalDataSource _local;
  final SyncEngine _syncEngine;
  final Uuid _uuid;

  @override
  Future<Either<Failure, List<CategoryEntity>>> getCategories({
    MovementType? type,
  }) {
    return guard(() async {
      final models = await _local.getCategories(type: type);
      return models.map((m) => m.toEntity()).toList();
    });
  }

  @override
  Stream<Either<Failure, List<CategoryEntity>>> watchCategories({
    MovementType? type,
  }) {
    return guardStream(
      () => _local
          .watchCategories(type: type)
          .map((models) => models.map((m) => m.toEntity()).toList()),
    );
  }

  @override
  Future<Either<Failure, CategoryEntity>> getCategoryById(String id) {
    return guard(() async => (await _findActive(id)).toEntity());
  }

  @override
  Future<Either<Failure, CategoryEntity>> createCategory({
    required String name,
    required MovementType type,
    required String iconKey,
    required int colorValue,
  }) {
    return guard(() async {
      final now = DateTime.now();
      final model = CategoryModel()
        ..uid = _uuid.v4()
        ..name = name
        ..type = type
        ..iconKey = iconKey
        ..colorValue = colorValue
        ..createdAt = now
        ..updatedAt = now
        ..syncStatus = SyncStatus.pendingCreate;

      await _local.save(model);
      _requestSync();
      return model.toEntity();
    });
  }

  @override
  Future<Either<Failure, CategoryEntity>> updateCategory(
    CategoryEntity category,
  ) {
    return guard(() async {
      final model = await _findActive(category.id)
        ..applyEntity(category);
      model
        ..updatedAt = DateTime.now()
        ..syncStatus = model.syncStatus.afterLocalUpdate();

      await _local.save(model);
      _requestSync();
      return model.toEntity();
    });
  }

  @override
  Future<Either<Failure, Unit>> deleteCategory(String id) {
    return guard(() async {
      final model = await _findActive(id);

      if (model.syncStatus == SyncStatus.pendingCreate) {
        // Never reached the remote provider: no tombstone needed.
        await _local.purge(id);
      } else {
        model
          ..isDeleted = true
          ..updatedAt = DateTime.now()
          ..syncStatus = SyncStatus.pendingDelete;
        await _local.save(model);
        _requestSync();
      }
      return unit;
    });
  }

  @override
  Future<Either<Failure, Unit>> seedDefaults(List<DefaultCategory> defaults) {
    return guard(() async {
      if (!await _local.isEmpty()) return unit;

      final now = DateTime.now();
      final models = [
        for (final category in defaults)
          CategoryModel()
            ..uid = category.id
            ..name = category.name
            ..type = category.type
            ..iconKey = category.iconKey
            ..colorValue = category.colorValue
            ..createdAt = now
            ..updatedAt = now
            ..syncStatus = SyncStatus.pendingCreate,
      ];
      await _local.saveAll(models);
      _requestSync();
      return unit;
    });
  }

  Future<CategoryModel> _findActive(String id) async {
    final model = await _local.getByUid(id);
    if (model == null || model.isDeleted) {
      throw NotFoundException('Categoría $id no encontrada');
    }
    return model;
  }

  void _requestSync() {
    if (_syncEngine.isEnabled) unawaited(_syncEngine.sync());
  }
}
