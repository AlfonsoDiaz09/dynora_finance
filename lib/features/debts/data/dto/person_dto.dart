import 'package:dynora_finance/core/sync/sync_status.dart';
import 'package:dynora_finance/features/debts/data/models/person_model.dart';

/// Provider-agnostic shape of a person exchanged with a remote backend.
class PersonDto {
  const PersonDto({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
  });

  final String id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;

  factory PersonDto.fromJson(Map<String, dynamic> json) {
    return PersonDto(
      id: json['id'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      isDeleted: json['is_deleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'created_at': createdAt.toUtc().toIso8601String(),
      'updated_at': updatedAt.toUtc().toIso8601String(),
      'is_deleted': isDeleted,
    };
  }

  factory PersonDto.fromModel(PersonModel model) {
    return PersonDto(
      id: model.uid,
      name: model.name,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      isDeleted: model.isDeleted,
    );
  }

  /// Builds a local model from remote data, already marked as synced.
  PersonModel toModel({required DateTime syncedAt}) {
    return PersonModel()
      ..uid = id
      ..name = name
      ..createdAt = createdAt.toLocal()
      ..updatedAt = updatedAt.toLocal()
      ..isDeleted = isDeleted
      ..syncStatus = SyncStatus.synced
      ..lastSyncedAt = syncedAt;
  }
}
