import 'package:dynora_finance/core/sync/sync_status.dart';
import 'package:dynora_finance/features/cards/data/models/card_model.dart';

/// Provider-agnostic shape of a card exchanged with a remote backend.
class CardDto {
  const CardDto({
    required this.id,
    required this.name,
    required this.paymentDueDay,
    required this.colorValue,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
  });

  final String id;
  final String name;
  final int paymentDueDay;
  final int colorValue;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;

  factory CardDto.fromJson(Map<String, dynamic> json) {
    return CardDto(
      id: json['id'] as String,
      name: json['name'] as String,
      paymentDueDay: json['payment_due_day'] as int,
      colorValue: json['color_value'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      isDeleted: json['is_deleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'payment_due_day': paymentDueDay,
      'color_value': colorValue,
      'created_at': createdAt.toUtc().toIso8601String(),
      'updated_at': updatedAt.toUtc().toIso8601String(),
      'is_deleted': isDeleted,
    };
  }

  factory CardDto.fromModel(CardModel model) {
    return CardDto(
      id: model.uid,
      name: model.name,
      paymentDueDay: model.paymentDueDay,
      colorValue: model.colorValue,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      isDeleted: model.isDeleted,
    );
  }

  /// Builds a local model from remote data, already marked as synced.
  CardModel toModel({required DateTime syncedAt}) {
    return CardModel()
      ..uid = id
      ..name = name
      ..paymentDueDay = paymentDueDay
      ..colorValue = colorValue
      ..createdAt = createdAt.toLocal()
      ..updatedAt = updatedAt.toLocal()
      ..isDeleted = isDeleted
      ..syncStatus = SyncStatus.synced
      ..lastSyncedAt = syncedAt;
  }
}
