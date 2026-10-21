import 'package:dynora_finance/core/enums/movement_type.dart';
import 'package:dynora_finance/core/error/failures.dart';
import 'package:dynora_finance/core/sync/sync_engine.dart';
import 'package:dynora_finance/core/sync/sync_status.dart';
import 'package:dynora_finance/features/movements/data/datasources/local/movement_local_data_source.dart';
import 'package:dynora_finance/features/movements/data/datasources/remote/movement_remote_data_source.dart';
import 'package:dynora_finance/features/movements/data/dto/movement_dto.dart';
import 'package:dynora_finance/features/movements/data/models/movement_model.dart';
import 'package:dynora_finance/features/movements/data/repositories/movement_repository_impl.dart';
import 'package:dynora_finance/features/movements/data/sync/movement_sync_handler.dart';
import 'package:dynora_finance/features/movements/domain/entities/movement_filter.dart';
import 'package:dynora_finance/features/movements/domain/usecases/add_movement.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';

/// Stores copies, like Isar does, so tests catch shared-reference bugs.
class FakeLocal implements MovementLocalDataSource {
  final Map<String, MovementModel> rows = {};

  MovementModel _copy(MovementModel m) =>
      MovementDto.fromModel(m).toModel(syncedAt: DateTime(2000))
        ..syncStatus = m.syncStatus
        ..lastSyncedAt = m.lastSyncedAt;

  @override
  Future<List<MovementModel>> getMovements(MovementFilter f) async =>
      rows.values.where((m) => !m.isDeleted).map(_copy).toList();

  @override
  Stream<List<MovementModel>> watchMovements(MovementFilter f) =>
      Stream.fromFuture(getMovements(f));

  @override
  Future<MovementModel?> getByUid(String uid) async =>
      rows[uid] == null ? null : _copy(rows[uid]!);

  @override
  Future<void> save(MovementModel m) async => rows[m.uid] = _copy(m);

  @override
  Future<void> saveAll(List<MovementModel> ms) async => ms.forEach(save);

  @override
  Future<void> purge(String uid) async => rows.remove(uid);

  @override
  Future<void> purgeAll(List<String> uids) async => uids.forEach(rows.remove);

  @override
  Future<List<MovementModel>> getPendingSync() async =>
      rows.values.where((m) => m.syncStatus.isPending).map(_copy).toList();
}

class FakeRemote implements MovementRemoteDataSource {
  final Map<String, MovementDto> rows = {};

  @override
  Future<List<MovementDto>> fetchChangedSince(DateTime? since) async => rows
      .values
      .where((d) => since == null || d.updatedAt.isAfter(since))
      .toList();

  @override
  Future<void> upsert(List<MovementDto> dtos) async {
    for (final d in dtos) {
      rows[d.id] = d;
    }
  }
}

void main() {
  late FakeLocal local;
  late FakeRemote remote;
  late MovementRepositoryImpl repository;
  late MovementSyncHandler sync;

  setUp(() {
    local = FakeLocal();
    remote = FakeRemote();
    repository = MovementRepositoryImpl(
      local: local,
      syncEngine: const OfflineSyncEngine(),
      uuid: const Uuid(),
    );
    sync = MovementSyncHandler(local: local, remote: remote);
  });

  Future<String> create() async {
    final result = await repository.createMovement(
      title: 'Café',
      amount: 50,
      type: MovementType.expense,
      categoryId: 'food',
      date: DateTime(2026, 10, 20),
    );
    return result.getOrElse((f) => throw f).id;
  }

  test('create stores record locally as pending create', () async {
    final id = await create();
    expect(local.rows[id]!.syncStatus, SyncStatus.pendingCreate);
  });

  test('editing a pending create keeps it pending create', () async {
    final id = await create();
    final entity = local.rows[id]!.toEntity().copyWith(amount: 80);
    await repository.updateMovement(entity);
    expect(local.rows[id]!.syncStatus, SyncStatus.pendingCreate);
    expect(local.rows[id]!.amount, 80);
  });

  test('deleting a never-synced record purges it without tombstone', () async {
    final id = await create();
    await repository.deleteMovement(id);
    expect(local.rows, isEmpty);
  });

  test('push uploads pending records and marks them synced', () async {
    final id = await create();
    await sync.push();
    expect(remote.rows[id]!.title, 'Café');
    expect(local.rows[id]!.syncStatus, SyncStatus.synced);
  });

  test('deleting a synced record leaves a tombstone, push sends it', () async {
    final id = await create();
    await sync.push();

    await repository.deleteMovement(id);
    expect(local.rows[id]!.isDeleted, isTrue);
    expect(
      (await repository.getMovements(MovementFilter.all)).getOrElse((_) => []),
      isEmpty,
    );

    await sync.push();
    expect(remote.rows[id]!.isDeleted, isTrue);
    expect(local.rows, isEmpty);
  });

  test('pull applies remote changes and keeps newer local edits', () async {
    final id = await create();
    await sync.push();

    // Remote edit older than a newer local edit: local wins.
    final old = remote.rows[id]!;
    remote.rows[id] = MovementDto.fromJson({
      ...old.toJson(),
      'title': 'Remote',
      'updated_at': old.updatedAt
          .subtract(const Duration(days: 1))
          .toUtc()
          .toIso8601String(),
    });
    await repository.updateMovement(
      local.rows[id]!.toEntity().copyWith(title: 'Local'),
    );
    await sync.pull();
    expect(local.rows[id]!.title, 'Local');

    // Remote-only record is inserted as synced.
    remote.rows['r1'] = MovementDto.fromJson({
      ...old.toJson(),
      'id': 'r1',
      'title': 'From server',
    });
    final cursor = await sync.pull();
    expect(local.rows['r1']!.syncStatus, SyncStatus.synced);
    expect(cursor, isNotNull);
  });

  test('add use case rejects invalid amount', () async {
    final result = await AddMovement(repository)(
      AddMovementParams(
        title: 'X',
        amount: 0,
        type: MovementType.expense,
        categoryId: 'food',
        date: DateTime.now(),
      ),
    );
    expect(result.getLeft().toNullable(), isA<ValidationFailure>());
    expect(local.rows, isEmpty);
  });
}
