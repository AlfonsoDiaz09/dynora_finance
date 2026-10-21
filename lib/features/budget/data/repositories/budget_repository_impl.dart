import 'dart:async';

import 'package:dynora_finance/core/error/exceptions.dart';
import 'package:dynora_finance/core/error/failures.dart';
import 'package:dynora_finance/core/error/guard.dart';
import 'package:dynora_finance/core/sync/sync_engine.dart';
import 'package:dynora_finance/core/sync/sync_status.dart';
import 'package:dynora_finance/features/budget/data/datasources/local/budget_local_data_source.dart';
import 'package:dynora_finance/features/budget/data/models/budget_model.dart';
import 'package:dynora_finance/features/budget/domain/entities/budget_entity.dart';
import 'package:dynora_finance/features/budget/domain/repositories/budget_repository.dart';
import 'package:fpdart/fpdart.dart';

/// Offline-first: the local database is the source of truth. Every write is
/// stored locally, flagged as pending, and a sync is requested in background.
class BudgetRepositoryImpl implements BudgetRepository {
  const BudgetRepositoryImpl({
    required BudgetLocalDataSource local,
    required SyncEngine syncEngine,
  }) : _local = local,
       _syncEngine = syncEngine;

  final BudgetLocalDataSource _local;
  final SyncEngine _syncEngine;

  @override
  Stream<Either<Failure, List<BudgetEntity>>> watchBudgets() {
    return guardStream(
      () => _local.watchBudgets().map(
        (models) => models.map((m) => m.toEntity()).toList(),
      ),
    );
  }

  @override
  Future<Either<Failure, BudgetEntity>> setBudget({
    required String categoryId,
    required double amount,
  }) {
    return guard(() async {
      final now = DateTime.now();
      final uid = BudgetModel.uidForCategory(categoryId);
      final existing = await _local.getByUid(uid);

      final BudgetModel model;
      if (existing == null) {
        model = BudgetModel()
          ..uid = uid
          ..categoryId = categoryId
          ..createdAt = now
          ..syncStatus = SyncStatus.pendingCreate;
      } else {
        // Also revives a deleted budget whose tombstone was not pushed yet.
        model = existing
          ..isDeleted = false
          ..syncStatus = existing.syncStatus == SyncStatus.pendingCreate
              ? SyncStatus.pendingCreate
              : SyncStatus.pendingUpdate;
      }
      model
        ..amount = amount
        ..updatedAt = now;

      await _local.save(model);
      _requestSync();
      return model.toEntity();
    });
  }

  @override
  Future<Either<Failure, Unit>> deleteBudget(String id) {
    return guard(() async {
      final model = await _local.getByUid(id);
      if (model == null || model.isDeleted) {
        throw NotFoundException('Presupuesto $id no encontrado');
      }

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

  void _requestSync() {
    if (_syncEngine.isEnabled) unawaited(_syncEngine.sync());
  }
}
