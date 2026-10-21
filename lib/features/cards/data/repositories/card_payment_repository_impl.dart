import 'dart:async';

import 'package:dynora_finance/core/error/exceptions.dart';
import 'package:dynora_finance/core/error/failures.dart';
import 'package:dynora_finance/core/error/guard.dart';
import 'package:dynora_finance/core/sync/sync_engine.dart';
import 'package:dynora_finance/core/sync/sync_status.dart';
import 'package:dynora_finance/features/cards/data/datasources/local/card_payment_local_data_source.dart';
import 'package:dynora_finance/features/cards/data/models/card_payment_model.dart';
import 'package:dynora_finance/features/cards/domain/entities/card_payment_entity.dart';
import 'package:dynora_finance/features/cards/domain/repositories/card_payment_repository.dart';
import 'package:fpdart/fpdart.dart';

/// Offline-first: the local database is the source of truth. Every write is
/// stored locally, flagged as pending, and a sync is requested in background.
class CardPaymentRepositoryImpl implements CardPaymentRepository {
  const CardPaymentRepositoryImpl({
    required CardPaymentLocalDataSource local,
    required SyncEngine syncEngine,
  }) : _local = local,
       _syncEngine = syncEngine;

  final CardPaymentLocalDataSource _local;
  final SyncEngine _syncEngine;

  @override
  Stream<Either<Failure, List<CardPaymentEntity>>> watchPayments() {
    return guardStream(
      () => _local.watchPayments().map(
        (models) => models.map((m) => m.toEntity()).toList(),
      ),
    );
  }

  @override
  Future<Either<Failure, CardPaymentEntity>> registerPayment({
    required String cardId,
    required DateTime periodStart,
    required double amount,
    required DateTime paidAt,
  }) {
    return guard(() async {
      final now = DateTime.now();
      final uid = CardPaymentModel.uidFor(cardId, periodStart);
      final existing = await _local.getByUid(uid);

      final CardPaymentModel model;
      if (existing == null) {
        model = CardPaymentModel()
          ..uid = uid
          ..cardId = cardId
          ..periodStart = periodStart
          ..createdAt = now
          ..syncStatus = SyncStatus.pendingCreate;
      } else {
        // Also revives a deleted payment whose tombstone was not pushed yet.
        model = existing
          ..isDeleted = false
          ..syncStatus = existing.syncStatus.afterLocalUpdate();
      }
      model
        ..amount = amount
        ..paidAt = paidAt
        ..updatedAt = now;

      await _local.save(model);
      _requestSync();
      return model.toEntity();
    });
  }

  @override
  Future<Either<Failure, Unit>> deletePayment(String id) {
    return guard(() async {
      final model = await _local.getByUid(id);
      if (model == null || model.isDeleted) {
        throw NotFoundException('Pago $id no encontrado');
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
