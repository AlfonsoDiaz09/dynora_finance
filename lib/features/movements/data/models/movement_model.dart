import 'package:dynora_finance/core/enums/movement_type.dart';
import 'package:dynora_finance/core/sync/sync_status.dart';
import 'package:dynora_finance/features/movements/domain/entities/movement_entity.dart';
import 'package:isar_community/isar.dart';

part 'movement_model.g.dart';

/// Local (Isar) representation of a movement.
///
/// [uid] is the global id shared with any remote provider; [isarId] is only
/// the internal Isar key and never leaves this layer.
@collection
class MovementModel {
  Id isarId = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String uid;

  late String title;
  late double amount;

  @Enumerated(EnumType.name)
  late MovementType type;

  @Index()
  late String categoryId;

  @Index()
  late DateTime date;

  String? note;

  /// Card used to pay, `null` for cash or transfers.
  @Index()
  String? cardId;
  late DateTime createdAt;
  late DateTime updatedAt;

  @Enumerated(EnumType.name)
  @Index()
  SyncStatus syncStatus = SyncStatus.pendingCreate;

  /// Tombstone kept until the deletion is pushed to the remote provider.
  @Index()
  bool isDeleted = false;

  DateTime? lastSyncedAt;

  MovementEntity toEntity() {
    return MovementEntity(
      id: uid,
      title: title,
      amount: amount,
      type: type,
      categoryId: categoryId,
      date: date,
      note: note,
      cardId: cardId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Copies the editable fields of [entity] into this model.
  void applyEntity(MovementEntity entity) {
    title = entity.title;
    amount = entity.amount;
    type = entity.type;
    categoryId = entity.categoryId;
    date = entity.date;
    note = entity.note;
    cardId = entity.cardId;
  }
}
