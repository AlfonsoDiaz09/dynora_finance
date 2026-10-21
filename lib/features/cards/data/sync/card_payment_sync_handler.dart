import 'package:dynora_finance/core/sync/sync_handler.dart';
import 'package:dynora_finance/core/sync/sync_status.dart';
import 'package:dynora_finance/features/cards/data/datasources/local/card_payment_local_data_source.dart';
import 'package:dynora_finance/features/cards/data/datasources/remote/card_payment_remote_data_source.dart';
import 'package:dynora_finance/features/cards/data/dto/card_payment_dto.dart';
import 'package:dynora_finance/features/cards/data/models/card_payment_model.dart';

/// Conflict strategy: last write wins, comparing `updatedAt`.
class CardPaymentSyncHandler implements SyncHandler {
  const CardPaymentSyncHandler({
    required CardPaymentLocalDataSource local,
    required CardPaymentRemoteDataSource remote,
  }) : _local = local,
       _remote = remote;

  final CardPaymentLocalDataSource _local;
  final CardPaymentRemoteDataSource _remote;

  @override
  String get entityName => 'card_payments';

  @override
  Future<void> push() async {
    final pending = await _local.getPendingSync();
    if (pending.isEmpty) return;

    await _remote.upsert(pending.map(CardPaymentDto.fromModel).toList());

    final syncedAt = DateTime.now();
    final deleted = <String>[];
    final synced = <CardPaymentModel>[];
    for (final pushed in pending) {
      // Skip records edited while the push was in flight; they stay pending.
      final current = await _local.getByUid(pushed.uid);
      if (current == null || current.updatedAt != pushed.updatedAt) continue;

      if (current.isDeleted) {
        deleted.add(current.uid);
      } else {
        synced.add(
          current
            ..syncStatus = SyncStatus.synced
            ..lastSyncedAt = syncedAt,
        );
      }
    }
    await _local.saveAll(synced);
    await _local.purgeAll(deleted);
  }

  @override
  Future<DateTime?> pull({DateTime? since}) async {
    final changes = await _remote.fetchChangedSince(since);
    if (changes.isEmpty) return null;

    final syncedAt = DateTime.now();
    final toSave = <CardPaymentModel>[];
    final toPurge = <String>[];
    DateTime? cursor;

    for (final dto in changes) {
      if (cursor == null || dto.updatedAt.isAfter(cursor)) {
        cursor = dto.updatedAt;
      }

      final local = await _local.getByUid(dto.id);
      final localIsNewer =
          local != null &&
          local.syncStatus.isPending &&
          local.updatedAt.isAfter(dto.updatedAt.toLocal());
      if (localIsNewer) continue;

      if (dto.isDeleted) {
        toPurge.add(dto.id);
      } else {
        toSave.add(dto.toModel(syncedAt: syncedAt));
      }
    }

    await _local.saveAll(toSave);
    await _local.purgeAll(toPurge);
    return cursor;
  }
}
