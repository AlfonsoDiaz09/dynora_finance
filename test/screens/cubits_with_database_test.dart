import 'package:dynora_finance/features/movements/presentation/cubit/movements_cubit.dart';
import 'package:dynora_finance/features/stats/presentation/cubit/stats_cubit.dart';
import 'package:dynora_finance/init_dependencies.dart';
import 'package:dynora_finance/shared/bloc/view_status.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';

import 'support/real_database.dart';

void main() {
  late Isar isar;
  final today = DateTime.now();

  setUpAll(() async {
    isar = await openTestDatabase();
    await seedSampleData(today);
  });

  tearDownAll(() => isar.close(deleteFromDisk: true));

  test('movements cubit loads the month', () async {
    final cubit = serviceLocator<MovementsCubit>()..start();
    final loaded = await cubit.stream
        .firstWhere((s) => s.status != ViewStatus.loading)
        .timeout(const Duration(seconds: 5));
    expect(loaded.error, isNull);
    expect(loaded.status, ViewStatus.loaded);
    expect(loaded.groups, isNotEmpty);
    await cubit.close();
  });

  test('stats cubit loads the month', () async {
    final cubit = serviceLocator<StatsCubit>()..start();
    final loaded = await cubit.stream
        .firstWhere((s) => s.status != ViewStatus.loading)
        .timeout(const Duration(seconds: 5));
    expect(loaded.error, isNull);
    expect(loaded.status, ViewStatus.loaded);
    await cubit.close();
  });
}
