import 'package:dynora_finance/core/enums/movement_type.dart';
import 'package:dynora_finance/core/sync/sync_status.dart';
import 'package:dynora_finance/features/categories/domain/entities/category_entity.dart';
import 'package:isar_community/isar.dart';

part 'category_model.g.dart';

/// Local (Isar) representation of a category.
///
/// [uid] is the global id shared with any remote provider; [isarId] is only
/// the internal Isar key and never leaves this layer.
@collection
class CategoryModel {
  Id isarId = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String uid;

  late String name;

  @Enumerated(EnumType.name)
  @Index()
  late MovementType type;

  late int iconCodePoint;
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

  CategoryEntity toEntity() {
    return CategoryEntity(
      id: uid,
      name: name,
      type: type,
      iconCodePoint: iconCodePoint,
      colorValue: colorValue,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Copies the editable fields of [entity] into this model.
  void applyEntity(CategoryEntity entity) {
    name = entity.name;
    type = entity.type;
    iconCodePoint = entity.iconCodePoint;
    colorValue = entity.colorValue;
  }
}
