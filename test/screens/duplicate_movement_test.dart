import 'package:dynora_finance/core/usecase/usecase.dart';
import 'package:dynora_finance/features/debts/domain/usecases/watch_debts.dart';
import 'package:dynora_finance/features/movements/domain/entities/movement_entity.dart';
import 'package:dynora_finance/features/movements/domain/entities/movement_filter.dart';
import 'package:dynora_finance/features/movements/domain/usecases/watch_movements.dart';
import 'package:dynora_finance/features/movements/presentation/cubit/movement_form_cubit.dart';
import 'package:dynora_finance/features/movements/presentation/pages/movements/movements_page.dart';
import 'package:dynora_finance/init_dependencies.dart';
import 'package:dynora_finance/shared/bloc/form_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';

import 'screens_layout_test.dart' show pumpScreen, settle;
import 'support/real_database.dart';

void main() {
  late Isar isar;
  final today = DateTime.now();

  setUp(() async {
    isar = await openTestDatabase();
    await seedSampleData(today);
  });

  tearDown(() => isar.close(deleteFromDisk: true));

  Future<List<MovementEntity>> movements() async =>
      (await serviceLocator<WatchMovements>()(
        MovementFilter.all,
      ).first).getOrElse((f) => throw f);

  test('duplicating saves a new movement and keeps the original', () async {
    final all = await movements();
    final moto = all.firstWhere((m) => m.title == 'Moto');

    final cubit = MovementFormCubit(
      watchCategories: serviceLocator(),
      watchCards: serviceLocator(),
      addMovement: serviceLocator(),
      updateMovement: serviceLocator(),
      deleteMovement: serviceLocator(),
      watchPeople: serviceLocator(),
      addPerson: serviceLocator(),
      watchDebts: serviceLocator(),
      setMovementDebts: serviceLocator(),
      template: moto,
    )..start();

    // Same card, category and plan; dated today.
    expect(cubit.state.cardId, moto.cardId);
    expect(cubit.state.categoryId, moto.categoryId);
    expect(cubit.state.installmentCount, 12);
    expect(DateUtils.isSameDay(cubit.state.date, today), isTrue);

    // Who owes you is copied too.
    await cubit.stream
        .firstWhere((s) => s.share.enabled && s.cards.isNotEmpty)
        .timeout(const Duration(seconds: 5));

    await cubit.submit(title: 'Moto 2', amount: 13599, note: '');
    expect(cubit.state.status, FormStatus.success, reason: cubit.state.error);
    await cubit.close();

    final after = await movements();
    expect(after, hasLength(all.length + 1));
    final copy = after.firstWhere((m) => m.title == 'Moto 2');
    expect(copy.id, isNot(moto.id));
    expect(copy.cardId, moto.cardId);
    expect(copy.installmentCount, 12);
    expect(after.where((m) => m.title == 'Moto'), hasLength(1));

    final debts = (await serviceLocator<WatchDebts>()(
      const NoParams(),
    ).first).getOrElse((f) => throw f);
    final copied = debts.where((d) => d.movementId == copy.id).toList();
    expect(copied, hasLength(1));
    expect(copied.single.amount, 6799.5);
    expect(copied.single.isPaid, isFalse);
  });

  testWidgets('long press opens the options and duplicates', (tester) async {
    await pumpScreen(tester, const MovementsPage(), 320);

    await tester.longPress(find.text('Despensa'));
    await tester.pumpAndSettle();
    expect(find.text('Editar'), findsOneWidget);

    await tester.tap(find.text('Duplicar'));
    await settle(tester);
    expect(find.text('Duplicar transacción'), findsOneWidget);
    expect(
      find.widgetWithText(TextField, 'Despensa'),
      findsOneWidget,
      reason: 'the form comes pre-filled',
    );
    expect(tester.takeException(), isNull);
  });
}
