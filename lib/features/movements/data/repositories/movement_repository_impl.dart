import 'dart:async';

import 'package:dynora_finance/core/enums/movement_type.dart';
import 'package:dynora_finance/core/error/exceptions.dart';
import 'package:dynora_finance/core/error/failures.dart';
import 'package:dynora_finance/core/error/guard.dart';
import 'package:dynora_finance/core/sync/sync_engine.dart';
import 'package:dynora_finance/core/sync/sync_status.dart';
import 'package:dynora_finance/features/movements/data/datasources/local/movement_local_data_source.dart';
import 'package:dynora_finance/features/movements/data/models/movement_model.dart';
import 'package:dynora_finance/features/movements/domain/entities/movement_entity.dart';
import 'package:dynora_finance/features/movements/domain/entities/movement_filter.dart';
import 'package:dynora_finance/features/movements/domain/repositories/movement_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';

/// Offline-first: the local database is the source of truth. Every write is
/// stored locally, flagged as pending, and a sync is requested in background.
class MovementRepositoryImpl implements MovementRepository {
  const MovementRepositoryImpl({
    required MovementLocalDataSource local,
    required SyncEngine syncEngine,
    required Uuid uuid,
  }) : _local = local,
       _syncEngine = syncEngine,
       _uuid = uuid;

  final MovementLocalDataSource _local;
  final SyncEngine _syncEngine;
  final Uuid _uuid;

  @override
  Future<Either<Failure, List<MovementEntity>>> getMovements(
    MovementFilter filter,
  ) {
    return guard(() async {
      final models = await _local.getMovements(filter);
      return models.map((m) => m.toEntity()).toList();
    });
  }

  @override
  Stream<Either<Failure, List<MovementEntity>>> watchMovements(
    MovementFilter filter,
  ) {
    return guardStream(
      () => _local
          .watchMovements(filter)
          .map((models) => models.map((m) => m.toEntity()).toList()),
    );
  }

  @override
  Future<Either<Failure, MovementEntity>> getMovementById(String id) {
    return guard(() async => (await _findActive(id)).toEntity());
  }

  @override
  Future<Either<Failure, MovementEntity>> createMovement({
    required String title,
    required double amount,
    required MovementType type,
    required String categoryId,
    required DateTime date,
    String? note,
    String? cardId,
  }) {
    return guard(() async {
      final now = DateTime.now();
      final model = MovementModel()
        ..uid = _uuid.v4()
        ..title = title
        ..amount = amount
        ..type = type
        ..categoryId = categoryId
        ..date = date
        ..note = note
        ..cardId = cardId
        ..createdAt = now
        ..updatedAt = now
        ..syncStatus = SyncStatus.pendingCreate;

      await _local.save(model);
      _requestSync();
      return model.toEntity();
    });
  }

  @override
  Future<Either<Failure, MovementEntity>> updateMovement(
    MovementEntity movement,
  ) {
    return guard(() async {
      final model = await _findActive(movement.id)
        ..applyEntity(movement);
      model
        ..updatedAt = DateTime.now()
        ..syncStatus = model.syncStatus.afterLocalUpdate();

      await _local.save(model);
      _requestSync();
      return model.toEntity();
    });
  }

  @override
  Future<Either<Failure, Unit>> deleteMovement(String id) {
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

  Future<MovementModel> _findActive(String id) async {
    final model = await _local.getByUid(id);
    if (model == null || model.isDeleted) {
      throw NotFoundException('Transacción $id no encontrada');
    }
    return model;
  }

  void _requestSync() {
    if (_syncEngine.isEnabled) unawaited(_syncEngine.sync());
  }
}
