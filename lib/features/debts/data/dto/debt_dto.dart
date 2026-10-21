import 'package:dynora_finance/core/sync/sync_status.dart';
import 'package:dynora_finance/features/debts/data/models/debt_model.dart';

/// Provider-agnostic shape of a debt exchanged with a remote backend.
class DebtDto {
  const DebtDto({
    required this.id,
    required this.movementId,
    required this.personId,
    required this.amount,
    this.paidAt,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
  });

  final String id;
  final String movementId;
  final String personId;
  final double amount;

  /// Calendar date (`yyyy-MM-dd`), not an instant.
  final DateTime? paidAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;

  factory DebtDto.fromJson(Map<String, dynamic> json) {
    final paidAt = json['paid_at'] as String?;
    return DebtDto(
      id: json['id'] as String,
      movementId: json['movement_id'] as String,
      personId: json['person_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      paidAt: paidAt == null ? null : _parseDate(paidAt),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      isDeleted: json['is_deleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    final paidAt = this.paidAt;
    return {
      'id': id,
      'movement_id': movementId,
      'person_id': personId,
      'amount': amount,
      'paid_at': paidAt == null ? null : _formatDate(paidAt),
      'created_at': createdAt.toUtc().toIso8601String(),
      'updated_at': updatedAt.toUtc().toIso8601String(),
      'is_deleted': isDeleted,
    };
  }

  factory DebtDto.fromModel(DebtModel model) {
    return DebtDto(
      id: model.uid,
      movementId: model.movementId,
      personId: model.personId,
      amount: model.amount,
      paidAt: model.paidAt,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      isDeleted: model.isDeleted,
    );
  }

  /// Builds a local model from remote data, already marked as synced.
  DebtModel toModel({required DateTime syncedAt}) {
    return DebtModel()
      ..uid = id
      ..movementId = movementId
      ..personId = personId
      ..amount = amount
      ..paidAt = paidAt
      ..createdAt = createdAt.toLocal()
      ..updatedAt = updatedAt.toLocal()
      ..isDeleted = isDeleted
      ..syncStatus = SyncStatus.synced
      ..lastSyncedAt = syncedAt;
  }

  // Dates travel without time zone so they mean the same day everywhere.
  static String _formatDate(DateTime date) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${date.year}-${two(date.month)}-${two(date.day)}';
  }

  static DateTime _parseDate(String value) {
    final parts = value.split('-').map(int.parse).toList();
    return DateTime(parts[0], parts[1], parts[2]);
  }
}
