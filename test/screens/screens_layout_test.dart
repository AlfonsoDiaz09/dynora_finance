import 'package:dynora_finance/app/theme/app_theme.dart';
import 'package:dynora_finance/features/movements/presentation/pages/movements/movements_page.dart';
import 'package:dynora_finance/features/stats/presentation/pages/stats/stats_page.dart';
import 'package:dynora_finance/shared/widgets/form/segment_option.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';

import 'support/real_database.dart';

/// Lets the database deliver results and rebuilds.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 5; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pump();
  }
}

/// Renders [page] on a phone [width] logical pixels wide with real data.
Future<void> pumpScreen(WidgetTester tester, Widget page, double width) async {
  tester.view.devicePixelRatio = 2.625;
  tester.view.physicalSize = Size(width * 2.625, 800 * 2.625);
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(360, 640),
      minTextAdapt: true,
      child: MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(body: page),
      ),
    ),
  );
  await settle(tester);
}

void main() {
  late Isar isar;

  setUp(() async {
    isar = await openTestDatabase();
    await seedSampleData(DateTime.now());
  });

  tearDown(() => isar.close(deleteFromDisk: true));

  for (final width in [320.0, 360.0, 411.0]) {
    testWidgets('movements screen at ${width.toInt()}px', (tester) async {
      await pumpScreen(tester, const MovementsPage(), width);
      expect(tester.takeException(), isNull);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Despensa'), findsOneWidget);
      expect(find.textContaining('Suscripción anual'), findsOneWidget);

      // Another month shows the "Hoy" shortcut and must still fit.
      await tester.tap(find.byTooltip('Mes anterior'));
      await settle(tester);
      expect(find.text('Hoy'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('stats screen at ${width.toInt()}px', (tester) async {
      await pumpScreen(tester, const StatsPage(), width);
      expect(tester.takeException(), isNull);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Gastos por categoría'), findsOneWidget);
      expect(find.text('Hogar'), findsOneWidget);
    });
  }

  testWidgets('movement filters and search', (tester) async {
    await pumpScreen(tester, const MovementsPage(), 360);

    WidgetController.hitTestWarningShouldBeFatal = true;
    await tester.tap(find.widgetWithText(SegmentOption, 'Ingresos'));
    await tester.pump();
    expect(find.text('Nómina'), findsOneWidget);
    expect(find.text('Despensa'), findsNothing);

    await tester.tap(find.widgetWithText(SegmentOption, 'Todos'));
    await tester.pump();
    await tester.tap(find.byTooltip('Buscar'));
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'despen');
    await tester.pump();
    expect(find.text('Despensa'), findsOneWidget);
    expect(find.text('Nómina'), findsNothing);

    await tester.enterText(find.byType(TextField), 'zzz');
    await tester.pump();
    expect(
      find.text('Ningún movimiento coincide con tu búsqueda'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
