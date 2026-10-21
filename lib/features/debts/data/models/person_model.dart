import 'package:dynora_finance/core/sync/sync_status.dart';
import 'package:dynora_finance/features/debts/domain/entities/person_entity.dart';
import 'package:isar_community/isar.dart';

part 'person_model.g.dart';

/// Local (Isar) representation of a person.
///
/// [uid] is the global id shared with any remote provider; [isarId] is only
/// the internal Isar key and never leaves this layer.
@collection
class PersonModel {
  Id isarId = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String uid;

  @Index(caseSensitive: false)
  late String name;

  late DateTime createdAt;
  late DateTime updatedAt;

  @Enumerated(EnumType.name)
  @Index()
  SyncStatus syncStatus = SyncStatus.pendingCreate;

  /// Tombstone kept until the deletion is pushed to the remote provider.
  @Index()
  bool isDeleted = false;

  DateTime? lastSyncedAt;

  PersonEntity toEntity() {
    return PersonEntity(
      id: uid,
      name: name,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
