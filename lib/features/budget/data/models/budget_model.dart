import 'package:dynora_finance/core/sync/sync_status.dart';
import 'package:dynora_finance/features/budget/domain/entities/budget_entity.dart';
import 'package:isar_community/isar.dart';

part 'budget_model.g.dart';

/// Local (Isar) representation of a budget.
///
/// [uid] is derived from the category (one budget per category), so the
/// same budget merges across devices; [isarId] never leaves this layer.
@collection
class BudgetModel {
  Id isarId = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String uid;

  @Index()
  late String categoryId;

  late double amount;
  late DateTime createdAt;
  late DateTime updatedAt;

  @Enumerated(EnumType.name)
  @Index()
  SyncStatus syncStatus = SyncStatus.pendingCreate;

  /// Tombstone kept until the deletion is pushed to the remote provider.
  @Index()
  bool isDeleted = false;

  DateTime? lastSyncedAt;

  static String uidForCategory(String categoryId) => 'budget_$categoryId';

  BudgetEntity toEntity() {
    return BudgetEntity(
      id: uid,
      categoryId: categoryId,
      amount: amount,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
