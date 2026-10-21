import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

class IsarDatabase {
  const IsarDatabase._();

  static const String name = 'dynora_finance';

  /// Opens the local database. Schemas come from the composition root
  /// (init_dependencies) so core does not depend on any feature.
  static Future<Isar> open(List<CollectionSchema<dynamic>> schemas) async {
    final existing = Isar.getInstance(name);
    if (existing != null) return existing;

    final directory = await getApplicationDocumentsDirectory();
    return Isar.open(schemas, directory: directory.path, name: name);
  }
}
