import 'dart:async';

import 'package:dynora_finance/core/error/failures.dart';
import 'package:dynora_finance/core/utils/month_range.dart';
import 'package:dynora_finance/core/usecase/usecase.dart';
import 'package:dynora_finance/features/cards/domain/entities/card_entity.dart';
import 'package:dynora_finance/features/cards/domain/usecases/watch_cards.dart';
import 'package:dynora_finance/features/categories/domain/entities/category_entity.dart';
import 'package:dynora_finance/features/debts/domain/entities/debt_entity.dart';
import 'package:dynora_finance/features/debts/domain/entities/movement_debts.dart';
import 'package:dynora_finance/features/debts/domain/usecases/watch_debts.dart';
import 'package:dynora_finance/features/categories/domain/usecases/watch_categories.dart';
import 'package:dynora_finance/features/movements/domain/entities/movement_entity.dart';
import 'package:dynora_finance/features/movements/domain/entities/movement_filter.dart';
import 'package:dynora_finance/features/movements/domain/entities/movement_summary.dart';
import 'package:dynora_finance/features/movements/domain/usecases/watch_movements.dart';
import 'package:dynora_finance/shared/bloc/view_status.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:rxdart/rxdart.dart';

class MovementDayGroup extends Equatable {
  const MovementDayGroup({required this.day, required this.movements});

  final DateTime day;
  final List<MovementEntity> movements;

  @override
  List<Object?> get props => [day, movements];
}

class MovementsState extends Equatable {
  const MovementsState({
    required this.month,
    this.status = ViewStatus.loading,
    this.summary = MovementSummary.empty,
    this.groups = const [],
    this.categories = const {},
    this.cards = const {},
    this.debts = const {},
    this.error,
  });

  final MonthRange month;
  final ViewStatus status;
  final MovementSummary summary;
  final List<MovementDayGroup> groups;
  final Map<String, CategoryEntity> categories;
  final Map<String, CardEntity> cards;

  /// Movement id → what others owe you for it.
  final Map<String, MovementDebts> debts;
  final String? error;

  @override
  List<Object?> get props => [
    month,
    status,
    summary.income,
    summary.expense,
    groups,
    categories,
    cards,
    debts,
    error,
  ];
}

class MovementsCubit extends Cubit<MovementsState> {
  MovementsCubit({
    required WatchMovements watchMovements,
    required WatchCategories watchCategories,
    required WatchCards watchCards,
    required WatchDebts watchDebts,
  }) : _watchMovements = watchMovements,
       _watchCategories = watchCategories,
       _watchCards = watchCards,
       _watchDebts = watchDebts,
       super(MovementsState(month: MonthRange(DateTime.now())));

  final WatchMovements _watchMovements;
  final WatchCategories _watchCategories;
  final WatchCards _watchCards;
  final WatchDebts _watchDebts;
  late final BehaviorSubject<MonthRange> _month = BehaviorSubject.seeded(
    state.month,
  );
  StreamSubscription<MovementsState>? _subscription;

  void start() {
    _subscription = _month
        .switchMap(
          (month) => Rx.combineLatest4(
            _watchMovements(MovementFilter(from: month.start, to: month.end)),
            _watchCategories(null),
            _watchCards(const NoParams()),
            _watchDebts(const NoParams()),
            (movements, categories, cards, debts) =>
                _buildState(month, movements, categories, cards, debts),
          ),
        )
        .listen(emit);
  }

  void previousMonth() => _changeMonth(state.month.previous);

  void nextMonth() => _changeMonth(state.month.next);

  void _changeMonth(MonthRange month) {
    emit(
      MovementsState(
        month: month,
        categories: state.categories,
        cards: state.cards,
        debts: state.debts,
      ),
    );
    _month.add(month);
  }

  MovementsState _buildState(
    MonthRange month,
    Either<Failure, List<MovementEntity>> movements,
    Either<Failure, List<CategoryEntity>> categories,
    Either<Failure, List<CardEntity>> cards,
    Either<Failure, List<DebtEntity>> debts,
  ) {
    return movements
        .flatMap(
          (m) => categories.flatMap(
            (c) => cards.flatMap((k) => debts.map((d) => (m, c, k, d))),
          ),
        )
        .match(
          (failure) => MovementsState(
            month: month,
            status: ViewStatus.failure,
            error: failure.message,
          ),
          (data) => MovementsState(
            month: month,
            status: ViewStatus.loaded,
            summary: MovementSummary.of(data.$1),
            groups: _groupByDay(data.$1),
            categories: {for (final c in data.$2) c.id: c},
            cards: {for (final k in data.$3) k.id: k},
            debts: MovementDebts.byMovement(data.$4),
          ),
        );
  }

  /// [movements] arrive sorted by date (newest first).
  List<MovementDayGroup> _groupByDay(List<MovementEntity> movements) {
    final groups = <DateTime, List<MovementEntity>>{};
    for (final movement in movements) {
      final day = DateTime(
        movement.date.year,
        movement.date.month,
        movement.date.day,
      );
      groups.putIfAbsent(day, () => []).add(movement);
    }
    return [
      for (final entry in groups.entries)
        MovementDayGroup(day: entry.key, movements: entry.value),
    ];
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    await _month.close();
    return super.close();
  }
}
