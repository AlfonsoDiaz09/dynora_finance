import 'package:dynora_finance/core/sync/sync_status.dart';
import 'package:dynora_finance/features/cards/domain/entities/card_payment_entity.dart';
import 'package:isar_community/isar.dart';

part 'card_payment_model.g.dart';

/// Local (Isar) representation of a card payment.
///
/// [uid] is derived from the card and the period (one payment per
/// statement), so the same payment merges across devices; [isarId] never
/// leaves this layer.
@collection
class CardPaymentModel {
  Id isarId = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String uid;

  @Index()
  late String cardId;

  late DateTime periodStart;
  late double amount;
  late DateTime paidAt;
  late DateTime createdAt;
  late DateTime updatedAt;

  @Enumerated(EnumType.name)
  @Index()
  SyncStatus syncStatus = SyncStatus.pendingCreate;

  /// Tombstone kept until the deletion is pushed to the remote provider.
  @Index()
  bool isDeleted = false;

  DateTime? lastSyncedAt;

  static String uidFor(String cardId, DateTime periodStart) {
    String two(int n) => n.toString().padLeft(2, '0');
    return 'payment_${cardId}_${periodStart.year}'
        '${two(periodStart.month)}${two(periodStart.day)}';
  }

  CardPaymentEntity toEntity() {
    return CardPaymentEntity(
      id: uid,
      cardId: cardId,
      periodStart: periodStart,
      amount: amount,
      paidAt: paidAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
