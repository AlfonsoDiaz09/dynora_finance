import 'dart:async';

import 'package:dynora_finance/core/error/exceptions.dart';
import 'package:dynora_finance/core/error/failures.dart';
import 'package:dynora_finance/core/error/guard.dart';
import 'package:dynora_finance/core/sync/sync_engine.dart';
import 'package:dynora_finance/core/sync/sync_status.dart';
import 'package:dynora_finance/features/loans/data/datasources/local/loan_local_data_source.dart';
import 'package:dynora_finance/features/loans/data/datasources/local/loan_payment_local_data_source.dart';
import 'package:dynora_finance/features/loans/data/models/loan_model.dart';
import 'package:dynora_finance/features/loans/data/models/loan_payment_model.dart';
import 'package:dynora_finance/features/loans/domain/entities/loan_entity.dart';
import 'package:dynora_finance/features/loans/domain/entities/loan_payment_entity.dart';
import 'package:dynora_finance/features/loans/domain/repositories/loan_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';

/// Offline-first: the local database is the source of truth. Every write is
/// stored locally, flagged as pending, and a sync is requested in background.
class LoanRepositoryImpl implements LoanRepository {
  const LoanRepositoryImpl({
    required LoanLocalDataSource loans,
    required LoanPaymentLocalDataSource payments,
    required SyncEngine syncEngine,
    required Uuid uuid,
  }) : _loans = loans,
       _payments = payments,
       _syncEngine = syncEngine,
       _uuid = uuid;

  final LoanLocalDataSource _loans;
  final LoanPaymentLocalDataSource _payments;
  final SyncEngine _syncEngine;
  final Uuid _uuid;

  @override
  Stream<Either<Failure, List<LoanEntity>>> watchLoans() {
    return guardStream(
      () => _loans.watchLoans().map(
        (models) => models.map((m) => m.toEntity()).toList(),
      ),
    );
  }

  @override
  Future<Either<Failure, LoanEntity>> saveLoan(LoanEntity loan) {
    return guard(() async {
      final now = DateTime.now();
      final existing = loan.id.isEmpty ? null : await _loans.getByUid(loan.id);
      final LoanModel model;
      if (existing == null || existing.isDeleted) {
        if (loan.id.isNotEmpty) {
          throw NotFoundException('Préstamo ${loan.id} no encontrado');
        }
        model = LoanModel()
          ..uid = _uuid.v4()
          ..createdAt = now
          ..syncStatus = SyncStatus.pendingCreate;
      } else {
        model = existing..syncStatus = existing.syncStatus.afterLocalUpdate();
      }
      model
        ..applyEntity(loan)
        ..updatedAt = now;
      await _loans.saveAll([model]);
      _requestSync();
      return model.toEntity();
    });
  }

  @override
  Future<Either<Failure, Unit>> deleteLoan(String id) {
    return guard(() async {
      final model = await _loans.getByUid(id);
      if (model == null || model.isDeleted) {
        throw NotFoundException('Préstamo $id no encontrado');
      }
      final now = DateTime.now();
      await _remove(
        [model],
        save: _loans.saveAll,
        purge: _loans.purgeAll,
        uid: (m) => m.uid,
        status: (m) => m.syncStatus,
        tombstone: (m) => m
          ..isDeleted = true
          ..updatedAt = now
          ..syncStatus = SyncStatus.pendingDelete,
      );
      await _remove(
        [
          for (final p in await _payments.getByLoan(id))
            if (!p.isDeleted) p,
        ],
        save: _payments.saveAll,
        purge: _payments.purgeAll,
        uid: (m) => m.uid,
        status: (m) => m.syncStatus,
        tombstone: (m) => m
          ..isDeleted = true
          ..updatedAt = now
          ..syncStatus = SyncStatus.pendingDelete,
      );
      _requestSync();
      return unit;
    });
  }

  @override
  Stream<Either<Failure, List<LoanPaymentEntity>>> watchPayments() {
    return guardStream(
      () => _payments.watchPayments().map(
        (models) => models.map((m) => m.toEntity()).toList(),
      ),
    );
  }

  @override
  Future<Either<Failure, LoanPaymentEntity>> savePayment(
    LoanPaymentEntity payment,
  ) {
    return guard(() async {
      final now = DateTime.now();
      final existing = payment.id.isEmpty
          ? null
          : await _payments.getByUid(payment.id);
      final LoanPaymentModel model;
      if (existing == null || existing.isDeleted) {
        if (payment.id.isNotEmpty) {
          throw NotFoundException('Pago ${payment.id} no encontrado');
        }
        model = LoanPaymentModel()
          ..uid = _uuid.v4()
          ..createdAt = now
          ..syncStatus = SyncStatus.pendingCreate;
      } else {
        model = existing..syncStatus = existing.syncStatus.afterLocalUpdate();
      }
      model
        ..loanId = payment.loanId
        ..amount = payment.amount
        ..paidAt = DateTime(
          payment.paidAt.year,
          payment.paidAt.month,
          payment.paidAt.day,
        )
        ..note = payment.note
        ..updatedAt = now;
      await _payments.saveAll([model]);
      _requestSync();
      return model.toEntity();
    });
  }

  @override
  Future<Either<Failure, Unit>> deletePayment(String id) {
    return guard(() async {
      final model = await _payments.getByUid(id);
      if (model == null || model.isDeleted) {
        throw NotFoundException('Pago $id no encontrado');
      }
      await _remove(
        [model],
        save: _payments.saveAll,
        purge: _payments.purgeAll,
        uid: (m) => m.uid,
        status: (m) => m.syncStatus,
        tombstone: (m) => m
          ..isDeleted = true
          ..updatedAt = DateTime.now()
          ..syncStatus = SyncStatus.pendingDelete,
      );
      _requestSync();
      return unit;
    });
  }

  /// Purges records that never reached the remote provider and leaves a
  /// tombstone for the rest.
  Future<void> _remove<T>(
    List<T> models, {
    required Future<void> Function(List<T>) save,
    required Future<void> Function(List<String>) purge,
    required String Function(T) uid,
    required SyncStatus Function(T) status,
    required T Function(T) tombstone,
  }) async {
    final toPurge = [
      for (final m in models)
        if (status(m) == SyncStatus.pendingCreate) uid(m),
    ];
    final toSave = [
      for (final m in models)
        if (status(m) != SyncStatus.pendingCreate) tombstone(m),
    ];
    await save(toSave);
    await purge(toPurge);
  }

  void _requestSync() {
    if (_syncEngine.isEnabled) unawaited(_syncEngine.sync());
  }
}
