import 'package:dynora_finance/core/sync/sync_status.dart';
import 'package:dynora_finance/features/budget/data/models/budget_model.dart';

/// Provider-agnostic shape of a budget exchanged with a remote backend.
class BudgetDto {
  const BudgetDto({
    required this.id,
    required this.categoryId,
    required this.amount,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
  });

  final String id;
  final String categoryId;
  final double amount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;

  factory BudgetDto.fromJson(Map<String, dynamic> json) {
    return BudgetDto(
      id: json['id'] as String,
      categoryId: json['category_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      isDeleted: json['is_deleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_id': categoryId,
      'amount': amount,
      'created_at': createdAt.toUtc().toIso8601String(),
      'updated_at': updatedAt.toUtc().toIso8601String(),
      'is_deleted': isDeleted,
    };
  }

  factory BudgetDto.fromModel(BudgetModel model) {
    return BudgetDto(
      id: model.uid,
      categoryId: model.categoryId,
      amount: model.amount,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      isDeleted: model.isDeleted,
    );
  }

  /// Builds a local model from remote data, already marked as synced.
  BudgetModel toModel({required DateTime syncedAt}) {
    return BudgetModel()
      ..uid = id
      ..categoryId = categoryId
      ..amount = amount
      ..createdAt = createdAt.toLocal()
      ..updatedAt = updatedAt.toLocal()
      ..isDeleted = isDeleted
      ..syncStatus = SyncStatus.synced
      ..lastSyncedAt = syncedAt;
  }
}
