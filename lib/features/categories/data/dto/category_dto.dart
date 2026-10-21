import 'package:dynora_finance/core/enums/movement_type.dart';
import 'package:dynora_finance/core/sync/sync_status.dart';
import 'package:dynora_finance/features/categories/data/models/category_model.dart';

/// Provider-agnostic shape of a category exchanged with a remote backend.
class CategoryDto {
  const CategoryDto({
    required this.id,
    required this.name,
    required this.type,
    required this.iconCodePoint,
    required this.colorValue,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
  });

  final String id;
  final String name;
  final String type;
  final int iconCodePoint;
  final int colorValue;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;

  factory CategoryDto.fromJson(Map<String, dynamic> json) {
    return CategoryDto(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      iconCodePoint: json['icon_code_point'] as int,
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
      'icon_code_point': iconCodePoint,
      'color_value': colorValue,
      'created_at': createdAt.toUtc().toIso8601String(),
      'updated_at': updatedAt.toUtc().toIso8601String(),
      'is_deleted': isDeleted,
    };
  }

  factory CategoryDto.fromModel(CategoryModel model) {
    return CategoryDto(
      id: model.uid,
      name: model.name,
      type: model.type.name,
      iconCodePoint: model.iconCodePoint,
      colorValue: model.colorValue,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      isDeleted: model.isDeleted,
    );
  }

  /// Builds a local model from remote data, already marked as synced.
  CategoryModel toModel({required DateTime syncedAt}) {
    return CategoryModel()
      ..uid = id
      ..name = name
      ..type = MovementType.values.byName(type)
      ..iconCodePoint = iconCodePoint
      ..colorValue = colorValue
      ..createdAt = createdAt.toLocal()
      ..updatedAt = updatedAt.toLocal()
      ..isDeleted = isDeleted
      ..syncStatus = SyncStatus.synced
      ..lastSyncedAt = syncedAt;
  }
}
