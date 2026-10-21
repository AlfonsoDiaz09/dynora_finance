import 'dart:async';

import 'package:dynora_finance/core/error/failures.dart';
import 'package:dynora_finance/core/error/guard.dart';
import 'package:dynora_finance/core/sync/sync_engine.dart';
import 'package:dynora_finance/core/sync/sync_status.dart';
import 'package:dynora_finance/features/debts/data/datasources/local/debt_local_data_source.dart';
import 'package:dynora_finance/features/debts/data/models/debt_model.dart';
import 'package:dynora_finance/features/debts/domain/entities/debt_entity.dart';
import 'package:dynora_finance/features/debts/domain/repositories/debt_repository.dart';
import 'package:fpdart/fpdart.dart';

/// Offline-first: the local database is the source of truth. Every write is
/// stored locally, flagged as pending, and a sync is requested in background.
class DebtRepositoryImpl implements DebtRepository {
  const DebtRepositoryImpl({
    required DebtLocalDataSource local,
    required SyncEngine syncEngine,
  }) : _local = local,
       _syncEngine = syncEngine;

  final DebtLocalDataSource _local;
  final SyncEngine _syncEngine;

  @override
  Stream<Either<Failure, List<DebtEntity>>> watchDebts() {
    return guardStream(
      () => _local.watchDebts().map(
        (models) => models.map((m) => m.toEntity()).toList(),
      ),
    );
  }

  @override
  Future<Either<Failure, Unit>> setMovementDebts(
    String movementId,
    Map<String, double> shares,
  ) {
    return guard(() async {
      final now = DateTime.now();
      final existing = {
        for (final m in await _local.getByMovement(movementId)) m.uid: m,
      };

      final toSave = <DebtModel>[];
      final toPurge = <String>[];
      for (final MapEntry(key: personId, value: amount) in shares.entries) {
        final uid = DebtModel.uidFor(movementId, personId);
        final current = existing.remove(uid);
        if (current == null) {
          toSave.add(
            DebtModel()
              ..uid = uid
              ..movementId = movementId
              ..personId = personId
              ..amount = amount
              ..createdAt = now
              ..updatedAt = now
              ..syncStatus = SyncStatus.pendingCreate,
          );
        } else if (current.isDeleted || current.amount != amount) {
          // Keeps paidAt: a person who already paid stays paid.
          toSave.add(
            current
              ..amount = amount
              ..isDeleted = false
              ..updatedAt = now
              ..syncStatus = current.syncStatus.afterLocalUpdate(),
          );
        }
      }

      // People no longer in the split.
      for (final model in existing.values) {
        if (model.isDeleted) continue;
        if (model.syncStatus == SyncStatus.pendingCreate) {
          toPurge.add(model.uid);
        } else {
          toSave.add(
            model
              ..isDeleted = true
              ..updatedAt = now
              ..syncStatus = SyncStatus.pendingDelete,
          );
        }
      }

      await _local.saveAll(toSave);
      await _local.purgeAll(toPurge);
      if (toSave.isNotEmpty || toPurge.isNotEmpty) _requestSync();
      return unit;
    });
  }

  @override
  Future<Either<Failure, Unit>> setPaid(List<String> ids, DateTime? paidAt) {
    return guard(() async {
      final now = DateTime.now();
      final models = [
        for (final model in await _local.getByUids(ids))
          if (!model.isDeleted)
            model
              ..paidAt = paidAt
              ..updatedAt = now
              ..syncStatus = model.syncStatus.afterLocalUpdate(),
      ];
      await _local.saveAll(models);
      if (models.isNotEmpty) _requestSync();
      return unit;
    });
  }

  void _requestSync() {
    if (_syncEngine.isEnabled) unawaited(_syncEngine.sync());
  }
}
