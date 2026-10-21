import 'package:dynora_finance/core/error/failures.dart';
import 'package:dynora_finance/core/sync/sync_engine.dart';
import 'package:dynora_finance/features/debts/data/datasources/local/debt_local_data_source.dart';
import 'package:dynora_finance/features/debts/data/datasources/local/person_local_data_source.dart';
import 'package:dynora_finance/features/debts/data/dto/debt_dto.dart';
import 'package:dynora_finance/features/debts/data/models/debt_model.dart';
import 'package:dynora_finance/features/debts/data/models/person_model.dart';
import 'package:dynora_finance/features/debts/data/repositories/debt_repository_impl.dart';
import 'package:dynora_finance/features/debts/data/repositories/person_repository_impl.dart';
import 'package:dynora_finance/features/debts/domain/entities/debt_entity.dart';
import 'package:dynora_finance/features/debts/domain/entities/debt_split.dart';
import 'package:dynora_finance/features/debts/domain/entities/movement_debts.dart';
import 'package:dynora_finance/features/debts/domain/usecases/rename_person.dart';
import 'package:dynora_finance/features/debts/domain/usecases/set_movement_debts.dart';
import 'package:dynora_finance/features/home/domain/entities/cash_flow.dart';
import 'package:dynora_finance/features/movements/presentation/cubit/share_draft.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';

/// Stores copies, like Isar does.
class FakeDebtLocal implements DebtLocalDataSource {
  final Map<String, DebtModel> rows = {};

  DebtModel _copy(DebtModel m) =>
      DebtDto.fromModel(m).toModel(syncedAt: DateTime(2000))
        ..syncStatus = m.syncStatus;

  @override
  Stream<List<DebtModel>> watchDebts() =>
      Stream.value(rows.values.where((m) => !m.isDeleted).map(_copy).toList());

  @override
  Future<List<DebtModel>> getByMovement(String movementId) async =>
      rows.values.where((m) => m.movementId == movementId).map(_copy).toList();

  @override
  Future<List<DebtModel>> getByUids(List<String> uids) async => [
    for (final uid in uids)
      if (rows[uid] case final m?) _copy(m),
  ];

  @override
  Future<DebtModel?> getByUid(String uid) async =>
      rows[uid] == null ? null : _copy(rows[uid]!);

  @override
  Future<void> saveAll(List<DebtModel> models) async {
    for (final m in models) {
      rows[m.uid] = _copy(m);
    }
  }

  @override
  Future<void> purgeAll(List<String> uids) async => uids.forEach(rows.remove);

  @override
  Future<List<DebtModel>> getPendingSync() async => [];
}

class FakePersonLocal implements PersonLocalDataSource {
  final Map<String, PersonModel> rows = {};

  PersonModel _copy(PersonModel m) => PersonModel()
    ..uid = m.uid
    ..name = m.name
    ..createdAt = m.createdAt
    ..updatedAt = m.updatedAt
    ..syncStatus = m.syncStatus
    ..isDeleted = m.isDeleted;

  @override
  Stream<List<PersonModel>> watchPeople() =>
      Stream.value(rows.values.map(_copy).toList());

  @override
  Future<PersonModel?> findByName(String name) async => rows.values
      .where((m) => !m.isDeleted && m.name.toLowerCase() == name.toLowerCase())
      .map(_copy)
      .firstOrNull;

  @override
  Future<PersonModel?> getByUid(String uid) async =>
      rows[uid] == null ? null : _copy(rows[uid]!);

  @override
  Future<void> save(PersonModel model) async => rows[model.uid] = _copy(model);

  @override
  Future<void> saveAll(List<PersonModel> models) async => models.forEach(save);

  @override
  Future<void> purgeAll(List<String> uids) async => uids.forEach(rows.remove);

  @override
  Future<List<PersonModel>> getPendingSync() async => [];
}

DebtEntity debt(String person, double amount, {DateTime? paidAt}) => DebtEntity(
  id: 'debt_m_$person',
  movementId: 'm',
  personId: person,
  amount: amount,
  paidAt: paidAt,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);

void main() {
  group('Equal split', () {
    test('including me: each person and I pay the same', () {
      expect(DebtSplit.equal(total: 900, people: 2, includeMe: true), [
        300,
        300,
      ]);
    });

    test('not including me: they cover everything', () {
      expect(DebtSplit.equal(total: 900, people: 1, includeMe: false), [900]);
      expect(DebtSplit.equal(total: 100, people: 3, includeMe: false), [
        33.34,
        33.33,
        33.33,
      ]);
    });

    test('leftover cents stay with me when I am included', () {
      final owed = DebtSplit.equal(total: 10, people: 2, includeMe: true);
      expect(owed, [3.33, 3.33]);
      expect(DebtSplit.myShare(10, owed), 3.34);
    });
  });

  group('Share draft', () {
    test('custom amounts must be positive and not exceed the total', () {
      const draft = ShareDraft(
        enabled: true,
        personIds: ['ana', 'luis'],
        mode: SplitMode.custom,
      );
      expect(draft.shares(1000, {'ana': 400, 'luis': 250}).isRight(), isTrue);
      expect(draft.shares(1000, {'ana': 400, 'luis': null}).isLeft(), isTrue);
      expect(draft.shares(1000, {'ana': 800, 'luis': 300}).isLeft(), isTrue);
    });

    test('disabled sharing produces no debts', () {
      const draft = ShareDraft(personIds: ['ana']);
      expect(draft.shares(1000, const {}).getOrElse((_) => {'x': 1}), isEmpty);
    });

    test('rebuilds equal and custom splits from saved debts', () {
      final equalWithMe = ShareDraft.fromDebts([
        debt('ana', 300),
        debt('luis', 300),
      ], 900);
      expect(equalWithMe.mode, SplitMode.equal);
      expect(equalWithMe.includeMe, isTrue);

      final fullDebt = ShareDraft.fromDebts([debt('ana', 900)], 900);
      expect(fullDebt.mode, SplitMode.equal);
      expect(fullDebt.includeMe, isFalse);

      final custom = ShareDraft.fromDebts([
        debt('ana', 500),
        debt('luis', 100),
      ], 900);
      expect(custom.mode, SplitMode.custom);
      expect(custom.initialAmounts, {'ana': 500, 'luis': 100});
    });
  });

  group('Debt repository', () {
    late FakeDebtLocal local;
    late DebtRepositoryImpl repository;

    setUp(() {
      local = FakeDebtLocal();
      repository = DebtRepositoryImpl(
        local: local,
        syncEngine: const OfflineSyncEngine(),
      );
    });

    test(
      'changing a split keeps who already paid and drops removed people',
      () async {
        await repository.setMovementDebts('m', {'ana': 300, 'luis': 300});
        await repository.setPaid([
          DebtModel.uidFor('m', 'ana'),
        ], DateTime(2026, 10, 20));

        await repository.setMovementDebts('m', {'ana': 250, 'sofi': 250});

        final ana = local.rows[DebtModel.uidFor('m', 'ana')]!;
        expect(ana.amount, 250);
        expect(ana.paidAt, DateTime(2026, 10, 20));
        expect(local.rows.containsKey(DebtModel.uidFor('m', 'luis')), isFalse);
        expect(local.rows[DebtModel.uidFor('m', 'sofi')]!.paidAt, isNull);
      },
    );

    test('clearing removes every debt of the movement', () async {
      await repository.setMovementDebts('m', {'ana': 300});
      await repository.setMovementDebts('m', const {});
      expect(local.rows, isEmpty);
    });

    test('use case rejects debts larger than the movement', () async {
      final result = await SetMovementDebts(repository)(
        const SetMovementDebtsParams(
          movementId: 'm',
          movementAmount: 100,
          shares: {'ana': 150},
        ),
      );
      expect(result.getLeft().toNullable(), isA<ValidationFailure>());
    });
  });

  test('money paid back counts as income on the day it was paid', () {
    final flow = CashFlow.of(
      movements: const [],
      cards: const [],
      payments: const [],
      debts: [
        debt('ana', 300, paidAt: DateTime(2026, 10, 20)),
        debt('luis', 300),
      ],
    );
    expect(flow.income, 300);
  });

  test('debts summary per movement separates owed and pending', () {
    final summary = MovementDebts.byMovement([
      debt('ana', 300, paidAt: DateTime(2026, 10, 20)),
      debt('luis', 300),
    ]);
    expect(summary['m'], const MovementDebts(owed: 600, pending: 300));
  });

  group('Renaming people', () {
    late PersonRepositoryImpl repository;

    setUp(() {
      repository = PersonRepositoryImpl(
        local: FakePersonLocal(),
        syncEngine: const OfflineSyncEngine(),
        uuid: const Uuid(),
      );
    });

    test('renames and rejects a name another person already has', () async {
      final ana = (await repository.findOrCreate(
        'Ana',
      )).getOrElse((f) => throw f);
      await repository.findOrCreate('Luis');
      final rename = RenamePerson(repository);

      final renamed = await rename(
        RenamePersonParams(id: ana.id, name: '  Ana   María '),
      );
      expect(renamed.getOrElse((f) => throw f).name, 'Ana María');

      final clash = await rename(RenamePersonParams(id: ana.id, name: 'luis'));
      expect(clash.getLeft().toNullable(), isA<ValidationFailure>());

      // Changing only the case of your own name is allowed.
      final sameCase = await rename(
        RenamePersonParams(id: ana.id, name: 'ana maría'),
      );
      expect(sameCase.isRight(), isTrue);
    });
  });
}
