import 'dart:async';

import 'package:dynora_finance/core/error/exceptions.dart';
import 'package:dynora_finance/core/error/failures.dart';
import 'package:dynora_finance/core/error/guard.dart';
import 'package:dynora_finance/core/sync/sync_engine.dart';
import 'package:dynora_finance/core/sync/sync_status.dart';
import 'package:dynora_finance/features/cards/data/datasources/local/card_local_data_source.dart';
import 'package:dynora_finance/features/cards/data/models/card_model.dart';
import 'package:dynora_finance/features/cards/domain/entities/card_entity.dart';
import 'package:dynora_finance/features/cards/domain/repositories/card_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';

/// Offline-first: the local database is the source of truth. Every write is
/// stored locally, flagged as pending, and a sync is requested in background.
class CardRepositoryImpl implements CardRepository {
  const CardRepositoryImpl({
    required CardLocalDataSource local,
    required SyncEngine syncEngine,
    required Uuid uuid,
  }) : _local = local,
       _syncEngine = syncEngine,
       _uuid = uuid;

  final CardLocalDataSource _local;
  final SyncEngine _syncEngine;
  final Uuid _uuid;

  @override
  Stream<Either<Failure, List<CardEntity>>> watchCards() {
    return guardStream(
      () => _local.watchCards().map(
        (models) => models.map((m) => m.toEntity()).toList(),
      ),
    );
  }

  @override
  Future<Either<Failure, CardEntity>> createCard({
    required String name,
    required int paymentDueDay,
    required int colorValue,
  }) {
    return guard(() async {
      final now = DateTime.now();
      final model = CardModel()
        ..uid = _uuid.v4()
        ..name = name
        ..paymentDueDay = paymentDueDay
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
  Future<Either<Failure, CardEntity>> updateCard(CardEntity card) {
    return guard(() async {
      final model = await _findActive(card.id)
        ..applyEntity(card);
      model
        ..updatedAt = DateTime.now()
        ..syncStatus = model.syncStatus.afterLocalUpdate();

      await _local.save(model);
      _requestSync();
      return model.toEntity();
    });
  }

  @override
  Future<Either<Failure, Unit>> deleteCard(String id) {
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

  Future<CardModel> _findActive(String id) async {
    final model = await _local.getByUid(id);
    if (model == null || model.isDeleted) {
      throw NotFoundException('Tarjeta $id no encontrada');
    }
    return model;
  }

  void _requestSync() {
    if (_syncEngine.isEnabled) unawaited(_syncEngine.sync());
  }
}
