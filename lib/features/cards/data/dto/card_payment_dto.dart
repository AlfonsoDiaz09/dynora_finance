import 'package:dynora_finance/core/sync/sync_status.dart';
import 'package:dynora_finance/features/cards/data/models/card_payment_model.dart';

/// Provider-agnostic shape of a card payment exchanged with a remote backend.
class CardPaymentDto {
  const CardPaymentDto({
    required this.id,
    required this.cardId,
    required this.periodStart,
    required this.amount,
    required this.paidAt,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
  });

  final String id;
  final String cardId;

  /// Calendar date (`yyyy-MM-dd`), not an instant.
  final DateTime periodStart;
  final double amount;

  /// Calendar date (`yyyy-MM-dd`), not an instant.
  final DateTime paidAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;

  factory CardPaymentDto.fromJson(Map<String, dynamic> json) {
    return CardPaymentDto(
      id: json['id'] as String,
      cardId: json['card_id'] as String,
      periodStart: _parseDate(json['period_start'] as String),
      amount: (json['amount'] as num).toDouble(),
      paidAt: _parseDate(json['paid_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      isDeleted: json['is_deleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'card_id': cardId,
      'period_start': _formatDate(periodStart),
      'amount': amount,
      'paid_at': _formatDate(paidAt),
      'created_at': createdAt.toUtc().toIso8601String(),
      'updated_at': updatedAt.toUtc().toIso8601String(),
      'is_deleted': isDeleted,
    };
  }

  factory CardPaymentDto.fromModel(CardPaymentModel model) {
    return CardPaymentDto(
      id: model.uid,
      cardId: model.cardId,
      periodStart: model.periodStart,
      amount: model.amount,
      paidAt: model.paidAt,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      isDeleted: model.isDeleted,
    );
  }

  /// Builds a local model from remote data, already marked as synced.
  CardPaymentModel toModel({required DateTime syncedAt}) {
    return CardPaymentModel()
      ..uid = id
      ..cardId = cardId
      ..periodStart = periodStart
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
