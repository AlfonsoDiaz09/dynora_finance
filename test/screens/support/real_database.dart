import 'dart:ffi';
import 'dart:io';

import 'package:dynora_finance/core/enums/movement_type.dart';
import 'package:dynora_finance/core/enums/payment_method.dart';
import 'package:dynora_finance/core/usecase/usecase.dart';
import 'package:dynora_finance/features/cards/domain/entities/card_type.dart';
import 'package:dynora_finance/features/cards/domain/usecases/add_card.dart';
import 'package:dynora_finance/features/categories/domain/usecases/ensure_default_categories.dart';
import 'package:dynora_finance/features/debts/domain/usecases/add_person.dart';
import 'package:dynora_finance/features/debts/domain/usecases/set_movement_debts.dart';
import 'package:dynora_finance/features/loans/domain/entities/loan_entity.dart';
import 'package:dynora_finance/features/loans/domain/usecases/loan_usecases.dart';
import 'package:dynora_finance/features/movements/domain/usecases/add_movement.dart';
import 'package:dynora_finance/init_dependencies.dart';
import 'package:isar_community/isar.dart';

/// Opens a real (temporary) Isar database with the app schemas and
/// registers every dependency on it. Uses the Windows Isar binary shipped
/// with isar_community_flutter_libs, so it runs in `flutter test`.
Future<Isar> openTestDatabase() async {
  final cache =
      Platform.environment['PUB_CACHE'] ??
      '${Platform.environment['LOCALAPPDATA']}/Pub/Cache';
  await Isar.initializeIsarCore(
    libraries: {
      Abi.windowsX64:
          '$cache/hosted/pub.dev/isar_community_flutter_libs-3.3.0/windows/libisar.dll',
    },
  );
  final dir = await Directory.systemTemp.createTemp('dynora_test_');
  final isar = await Isar.open(isarSchemas, directory: dir.path);
  await serviceLocator.reset();
  await initDependencies(isar: isar);
  return isar;
}

/// Data shaped like a real user's: cards, installments, a withdrawal,
/// shared expenses and long texts.
Future<void> seedSampleData(DateTime today) async {
  await serviceLocator<EnsureDefaultCategories>()(const NoParams());
  final addCard = serviceLocator<AddCard>();
  final bbva = (await addCard(
    const AddCardParams(
      name: 'BBVA Azul',
      type: CardType.credit,
      lastFourDigits: '5690',
      cutoffDay: 2,
      paymentDueDay: 20,
      creditLimit: 30000,
      colorValue: 0xFF448AFF,
    ),
  )).getOrElse((f) => throw f);
  final debit = (await addCard(
    const AddCardParams(
      name: 'Nu débito',
      type: CardType.debit,
      lastFourDigits: '4859',
      colorValue: 0xFF7F00FF,
    ),
  )).getOrElse((f) => throw f);

  final add = serviceLocator<AddMovement>();
  Future<String> movement(AddMovementParams params) async =>
      (await add(params)).getOrElse((f) => throw f).id;

  await movement(
    AddMovementParams(
      title: 'Nómina',
      amount: 15000,
      type: MovementType.income,
      categoryId: 'default_salary',
      date: DateTime(today.year, today.month, 1),
      paymentMethod: PaymentMethod.transfer,
    ),
  );
  await movement(
    AddMovementParams(
      title: 'Despensa',
      amount: 2369,
      type: MovementType.expense,
      categoryId: 'default_home',
      date: today,
    ),
  );
  final moto = await movement(
    AddMovementParams(
      title: 'Moto',
      amount: 13599,
      type: MovementType.expense,
      categoryId: 'default_shopping',
      date: today.subtract(const Duration(days: 12)),
      cardId: bbva.id,
      installmentCount: 12,
    ),
  );
  await movement(
    AddMovementParams(
      title: 'Disposición de efectivo',
      amount: 5000,
      type: MovementType.expense,
      categoryId: 'cash_withdrawal',
      date: today.subtract(const Duration(days: 3)),
      cardId: bbva.id,
      installmentCount: 6,
      installmentRate: 15,
      isCashWithdrawal: true,
    ),
  );
  await movement(
    AddMovementParams(
      title:
          'Suscripción anual de servicios de streaming y almacenamiento '
          'en la nube para toda la familia',
      amount: 1899.99,
      type: MovementType.expense,
      categoryId: 'default_subscriptions',
      date: today.subtract(const Duration(days: 1)),
      cardId: debit.id,
    ),
  );

  final ana = (await serviceLocator<AddPerson>()(
    'Ana',
  )).getOrElse((f) => throw f);
  await serviceLocator<SetMovementDebts>()(
    SetMovementDebtsParams(
      movementId: moto,
      movementAmount: 13599,
      shares: {ana.id: 6799.5},
    ),
  );

  (await serviceLocator<SaveLoan>()(
    LoanEntity(
      id: '',
      name: 'Crédito personal Banco Azteca con un nombre largo',
      kind: LoanKind.institution,
      principal: 12000,
      startDate: today.subtract(const Duration(days: 40)),
      installmentAmount: 1500,
      installmentCount: 10,
      firstPaymentDate: today,
      affectsCash: false,
      createdAt: today,
      updatedAt: today,
    ),
  )).getOrElse((f) => throw f);
}
