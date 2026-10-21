import 'package:dynora_finance/core/sync/sync_status.dart';
import 'package:dynora_finance/features/cards/data/models/card_model.dart';
import 'package:dynora_finance/features/cards/domain/entities/card_type.dart';

/// Provider-agnostic shape of a card exchanged with a remote backend.
class CardDto {
  const CardDto({
    required this.id,
    required this.name,
    required this.type,
    required this.lastFourDigits,
    this.cutoffDay,
    this.paymentDueDay,
    required this.colorValue,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
  });

  final String id;
  final String name;
  final String type;
  final String lastFourDigits;
  final int? cutoffDay;
  final int? paymentDueDay;
  final int colorValue;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;

  factory CardDto.fromJson(Map<String, dynamic> json) {
    return CardDto(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      lastFourDigits: json['last_four_digits'] as String,
      cutoffDay: json['cutoff_day'] as int?,
      paymentDueDay: json['payment_due_day'] as int?,
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
      'type': type,
      'last_four_digits': lastFourDigits,
      'cutoff_day': cutoffDay,
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
      type: model.type.name,
      lastFourDigits: model.lastFourDigits,
      cutoffDay: model.cutoffDay,
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
      ..type = CardType.values.byName(type)
      ..lastFourDigits = lastFourDigits
      ..cutoffDay = cutoffDay
      ..paymentDueDay = paymentDueDay
      ..colorValue = colorValue
      ..createdAt = createdAt.toLocal()
      ..updatedAt = updatedAt.toLocal()
      ..isDeleted = isDeleted
      ..syncStatus = SyncStatus.synced
      ..lastSyncedAt = syncedAt;
  }
}
