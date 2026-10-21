import 'package:dynora_finance/core/sync/sync_status.dart';
import 'package:dynora_finance/features/cards/domain/entities/card_entity.dart';
import 'package:isar_community/isar.dart';

part 'card_model.g.dart';

/// Local (Isar) representation of a card.
///
/// [uid] is the global id shared with any remote provider; [isarId] is only
/// the internal Isar key and never leaves this layer.
@collection
class CardModel {
  Id isarId = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String uid;

  late String name;
  late int paymentDueDay;
  late int colorValue;
  late DateTime createdAt;
  late DateTime updatedAt;

  @Enumerated(EnumType.name)
  @Index()
  SyncStatus syncStatus = SyncStatus.pendingCreate;

  /// Tombstone kept until the deletion is pushed to the remote provider.
  @Index()
  bool isDeleted = false;

  DateTime? lastSyncedAt;

  CardEntity toEntity() {
    return CardEntity(
      id: uid,
      name: name,
      paymentDueDay: paymentDueDay,
      colorValue: colorValue,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Copies the editable fields of [entity] into this model.
  void applyEntity(CardEntity entity) {
    name = entity.name;
    paymentDueDay = entity.paymentDueDay;
    colorValue = entity.colorValue;
  }
}
