import 'dart:async';

import 'package:dynora_finance/core/error/failures.dart';
import 'package:dynora_finance/core/usecase/usecase.dart';
import 'package:dynora_finance/features/debts/domain/entities/debt_entity.dart';
import 'package:dynora_finance/features/debts/domain/entities/person_entity.dart';
import 'package:dynora_finance/features/debts/domain/usecases/rename_person.dart';
import 'package:dynora_finance/features/debts/domain/usecases/set_debts_paid.dart';
import 'package:dynora_finance/features/debts/domain/usecases/watch_debts.dart';
import 'package:dynora_finance/features/debts/domain/usecases/watch_people.dart';
import 'package:dynora_finance/features/movements/domain/entities/movement_entity.dart';
import 'package:dynora_finance/features/movements/domain/entities/movement_filter.dart';
import 'package:dynora_finance/features/movements/domain/usecases/watch_movements.dart';
import 'package:dynora_finance/shared/bloc/view_status.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:rxdart/rxdart.dart';

enum DebtFilter { pending, paid, all }

class DebtItem extends Equatable {
  const DebtItem({required this.debt, this.movement});

  final DebtEntity debt;

  /// `null` if the movement no longer exists.
  final MovementEntity? movement;

  @override
  List<Object?> get props => [debt, movement];
}

/// Everything one person owes you.
class PersonDebts extends Equatable {
  const PersonDebts({required this.person, required this.items});

  final PersonEntity person;

  /// Pending first, then newest purchase first.
  final List<DebtItem> items;

  double get pending => items
      .where((i) => !i.debt.isPaid)
      .fold(0, (sum, i) => sum + i.debt.amount);

  List<String> get pendingIds => [
    for (final i in items)
      if (!i.debt.isPaid) i.debt.id,
  ];

  @override
  List<Object?> get props => [person, items];
}

class DebtsState extends Equatable {
  const DebtsState({
    this.status = ViewStatus.loading,
    this.people = const [],
    this.filter = DebtFilter.pending,
    this.error,
  });

  final ViewStatus status;

  /// Every person with debts, most owed first.
  final List<PersonDebts> people;
  final DebtFilter filter;
  final String? error;

  double get totalPending => people.fold(0, (sum, p) => sum + p.pending);

  int get peopleWithPending => people.where((p) => p.pending > 0).length;

  /// [people] reduced to the debts matching [filter].
  List<PersonDebts> get visible => [
    for (final person in people)
      if (_filtered(person).isNotEmpty)
        PersonDebts(person: person.person, items: _filtered(person)),
  ];

  List<DebtItem> _filtered(PersonDebts person) => switch (filter) {
    DebtFilter.all => person.items,
    DebtFilter.pending => [
      for (final i in person.items)
        if (!i.debt.isPaid) i,
    ],
    DebtFilter.paid => [
      for (final i in person.items)
        if (i.debt.isPaid) i,
    ],
  };

  DebtsState copyWith({DebtFilter? filter, String? Function()? error}) {
    return DebtsState(
      status: status,
      people: people,
      filter: filter ?? this.filter,
      error: error != null ? error() : this.error,
    );
  }

  @override
  List<Object?> get props => [status, people, filter, error];
}

class DebtsCubit extends Cubit<DebtsState> {
  DebtsCubit({
    required WatchDebts watchDebts,
    required WatchPeople watchPeople,
    required WatchMovements watchMovements,
    required SetDebtsPaid setDebtsPaid,
    required RenamePerson renamePerson,
  }) : _watchDebts = watchDebts,
       _watchPeople = watchPeople,
       _watchMovements = watchMovements,
       _setDebtsPaid = setDebtsPaid,
       _renamePerson = renamePerson,
       super(const DebtsState());

  final WatchDebts _watchDebts;
  final WatchPeople _watchPeople;
  final WatchMovements _watchMovements;
  final SetDebtsPaid _setDebtsPaid;
  final RenamePerson _renamePerson;
  StreamSubscription<DebtsState>? _subscription;

  void start() {
    _subscription = Rx.combineLatest3(
      _watchDebts(const NoParams()),
      _watchPeople(const NoParams()),
      _watchMovements(MovementFilter.all),
      _buildState,
    ).listen(emit);
  }

  void changeFilter(DebtFilter filter) => emit(state.copyWith(filter: filter));

  Future<void> markPaid(List<String> ids, DateTime paidAt) =>
      _setPaid(ids, paidAt);

  Future<void> markPending(List<String> ids) => _setPaid(ids, null);

  /// Returns an error message, or `null` when renamed.
  Future<String?> renamePerson(String id, String name) async {
    final result = await _renamePerson(RenamePersonParams(id: id, name: name));
    return result.match((failure) => failure.message, (_) => null);
  }

  Future<void> _setPaid(List<String> ids, DateTime? paidAt) async {
    final result = await _setDebtsPaid(
      SetDebtsPaidParams(ids: ids, paidAt: paidAt),
    );
    result.match(
      (failure) => emit(state.copyWith(error: () => failure.message)),
      (_) => emit(state.copyWith(error: () => null)),
    );
  }

  DebtsState _buildState(
    Either<Failure, List<DebtEntity>> debts,
    Either<Failure, List<PersonEntity>> people,
    Either<Failure, List<MovementEntity>> movements,
  ) {
    return debts
        .flatMap((d) => people.flatMap((p) => movements.map((m) => (d, p, m))))
        .match(
          (failure) =>
              DebtsState(status: ViewStatus.failure, error: failure.message),
          (data) {
            final movementsById = {for (final m in data.$3) m.id: m};
            final debtsByPerson = <String, List<DebtItem>>{};
            for (final debt in data.$1) {
              debtsByPerson
                  .putIfAbsent(debt.personId, () => [])
                  .add(
                    DebtItem(
                      debt: debt,
                      movement: movementsById[debt.movementId],
                    ),
                  );
            }

            final groups =
                [
                  for (final person in data.$2)
                    if (debtsByPerson[person.id] case final items?)
                      PersonDebts(
                        person: person,
                        items: items..sort(_byStatusThenDate),
                      ),
                ]..sort((a, b) {
                  final byPending = b.pending.compareTo(a.pending);
                  return byPending != 0
                      ? byPending
                      : a.person.name.compareTo(b.person.name);
                });

            return DebtsState(
              status: ViewStatus.loaded,
              people: groups,
              filter: state.filter,
            );
          },
        );
  }

  static int _byStatusThenDate(DebtItem a, DebtItem b) {
    if (a.debt.isPaid != b.debt.isPaid) return a.debt.isPaid ? 1 : -1;
    final dateA = a.movement?.date ?? a.debt.createdAt;
    final dateB = b.movement?.date ?? b.debt.createdAt;
    return dateB.compareTo(dateA);
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
