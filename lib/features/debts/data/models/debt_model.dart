import 'package:dynora_finance/core/sync/sync_status.dart';
import 'package:dynora_finance/features/debts/domain/entities/debt_entity.dart';
import 'package:isar_community/isar.dart';

part 'debt_model.g.dart';

/// Local (Isar) representation of a debt.
///
/// [uid] is derived from the movement and the person (one debt per person
/// and movement), so it merges across devices; [isarId] never leaves this
/// layer.
@collection
class DebtModel {
  Id isarId = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String uid;

  @Index()
  late String movementId;

  @Index()
  late String personId;

  late double amount;
  DateTime? paidAt;
  late DateTime createdAt;
  late DateTime updatedAt;

  @Enumerated(EnumType.name)
  @Index()
  SyncStatus syncStatus = SyncStatus.pendingCreate;

  /// Tombstone kept until the deletion is pushed to the remote provider.
  @Index()
  bool isDeleted = false;

  DateTime? lastSyncedAt;

  static String uidFor(String movementId, String personId) =>
      'debt_${movementId}_$personId';

  DebtEntity toEntity() {
    return DebtEntity(
      id: uid,
      movementId: movementId,
      personId: personId,
      amount: amount,
      paidAt: paidAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
