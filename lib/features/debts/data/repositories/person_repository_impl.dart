import 'dart:async';

import 'package:dynora_finance/core/error/failures.dart';
import 'package:dynora_finance/core/error/guard.dart';
import 'package:dynora_finance/core/sync/sync_engine.dart';
import 'package:dynora_finance/core/sync/sync_status.dart';
import 'package:dynora_finance/features/debts/data/datasources/local/person_local_data_source.dart';
import 'package:dynora_finance/features/debts/data/models/person_model.dart';
import 'package:dynora_finance/features/debts/domain/entities/person_entity.dart';
import 'package:dynora_finance/features/debts/domain/repositories/person_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';

/// Offline-first: the local database is the source of truth. Every write is
/// stored locally, flagged as pending, and a sync is requested in background.
class PersonRepositoryImpl implements PersonRepository {
  const PersonRepositoryImpl({
    required PersonLocalDataSource local,
    required SyncEngine syncEngine,
    required Uuid uuid,
  }) : _local = local,
       _syncEngine = syncEngine,
       _uuid = uuid;

  final PersonLocalDataSource _local;
  final SyncEngine _syncEngine;
  final Uuid _uuid;

  @override
  Stream<Either<Failure, List<PersonEntity>>> watchPeople() {
    return guardStream(
      () => _local.watchPeople().map(
        (models) => models.map((m) => m.toEntity()).toList(),
      ),
    );
  }

  @override
  Future<Either<Failure, PersonEntity>> findOrCreate(String name) {
    return guard(() async {
      final existing = await _local.findByName(name);
      if (existing != null) return existing.toEntity();

      final now = DateTime.now();
      final model = PersonModel()
        ..uid = _uuid.v4()
        ..name = name
        ..createdAt = now
        ..updatedAt = now
        ..syncStatus = SyncStatus.pendingCreate;
      await _local.save(model);
      if (_syncEngine.isEnabled) unawaited(_syncEngine.sync());
      return model.toEntity();
    });
  }
}
