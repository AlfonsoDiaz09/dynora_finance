import 'package:isar_community/isar.dart';

part 'sync_metadata_model.g.dart';

@collection
class SyncMetadataModel {
  Id isarId = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String entityName;

  DateTime? lastPulledAt;
}
