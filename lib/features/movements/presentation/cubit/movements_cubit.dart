import 'dart:async';

import 'package:dynora_finance/core/error/failures.dart';
import 'package:dynora_finance/core/usecase/usecase.dart';
import 'package:dynora_finance/core/utils/month_range.dart';
import 'package:dynora_finance/features/cards/domain/entities/card_entity.dart';
import 'package:dynora_finance/features/cards/domain/usecases/watch_cards.dart';
import 'package:dynora_finance/features/categories/domain/entities/category_entity.dart';
import 'package:dynora_finance/features/categories/domain/usecases/watch_categories.dart';
import 'package:dynora_finance/features/debts/domain/entities/debt_entity.dart';
import 'package:dynora_finance/features/debts/domain/entities/movement_debts.dart';
import 'package:dynora_finance/features/debts/domain/usecases/watch_debts.dart';
import 'package:dynora_finance/features/movements/domain/entities/movement_entity.dart';
import 'package:dynora_finance/features/movements/domain/entities/movement_filter.dart';
import 'package:dynora_finance/features/movements/domain/entities/movement_summary.dart';
import 'package:dynora_finance/features/movements/domain/usecases/watch_movements.dart';
import 'package:dynora_finance/shared/bloc/view_status.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:rxdart/rxdart.dart';

/// Which movements the list shows.
enum MovementTypeFilter { all, expenses, incomes }

class MovementDayGroup extends Equatable {
  const MovementDayGroup({required this.day, required this.movements});

  final DateTime day;
  final List<MovementEntity> movements;

  /// What came in minus what went out that day (withdrawals count as in).
  double get net => movements.fold(
    0,
    (sum, m) =>
        m.isExpense && !m.isCashWithdrawal ? sum - m.amount : sum + m.amount,
  );

  @override
  List<Object?> get props => [day, movements];
}

class MovementsState extends Equatable {
  const MovementsState({
    required this.month,
    this.status = ViewStatus.loading,
    this.movements = const [],
    this.categories = const {},
    this.cards = const {},
    this.debts = const {},
    this.typeFilter = MovementTypeFilter.all,
    this.query = '',
    this.error,
  });

  final MonthRange month;
  final ViewStatus status;

  /// Every movement of [month], newest first.
  final List<MovementEntity> movements;
  final Map<String, CategoryEntity> categories;
  final Map<String, CardEntity> cards;

  /// Movement id → what others owe you for it.
  final Map<String, MovementDebts> debts;
  final MovementTypeFilter typeFilter;

  /// Text searched in titles, notes, categories and cards.
  final String query;
  final String? error;

  /// Totals of the whole month (filters don't change them).
  MovementSummary get summary => MovementSummary.of(movements);

  bool get isFiltered =>
      typeFilter != MovementTypeFilter.all || query.trim().isNotEmpty;

  /// Movements matching the filters, grouped by day (newest first).
  List<MovementDayGroup> get groups {
    final groups = <DateTime, List<MovementEntity>>{};
    for (final movement in movements.where(_matches)) {
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

  bool _matches(MovementEntity movement) {
    final isOut = movement.isExpense && !movement.isCashWithdrawal;
    final typeOk = switch (typeFilter) {
      MovementTypeFilter.all => true,
      MovementTypeFilter.expenses => isOut,
      MovementTypeFilter.incomes => !isOut,
    };
    if (!typeOk) return false;

    final text = _normalize(query);
    if (text.isEmpty) return true;
    final haystack = _normalize(
      [
        movement.title,
        movement.note ?? '',
        movement.isCashWithdrawal
            ? 'Disposición de efectivo'
            : categories[movement.categoryId]?.name ?? '',
        cards[movement.cardId]?.name ?? '',
      ].join(' '),
    );
    return haystack.contains(text);
  }

  /// Lowercase without accents, so "nomina" finds "Nómina".
  static String _normalize(String value) {
    const from = 'áéíóúüñ';
    const to = 'aeiouun';
    final lower = value.trim().toLowerCase();
    final buffer = StringBuffer();
    for (final char in lower.split('')) {
      final index = from.indexOf(char);
      buffer.write(index >= 0 ? to[index] : char);
    }
    return buffer.toString();
  }

  MovementsState copyWith({
    MonthRange? month,
    ViewStatus? status,
    List<MovementEntity>? movements,
    MovementTypeFilter? typeFilter,
    String? query,
  }) {
    return MovementsState(
      month: month ?? this.month,
      status: status ?? this.status,
      movements: movements ?? this.movements,
      categories: categories,
      cards: cards,
      debts: debts,
      typeFilter: typeFilter ?? this.typeFilter,
      query: query ?? this.query,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
    month,
    status,
    movements,
    categories,
    cards,
    debts,
    typeFilter,
    query,
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

  void currentMonth() => _changeMonth(MonthRange(DateTime.now()));

  void changeTypeFilter(MovementTypeFilter filter) =>
      emit(state.copyWith(typeFilter: filter));

  void search(String query) => emit(state.copyWith(query: query));

  void _changeMonth(MonthRange month) {
    if (month == state.month) return;
    emit(
      state.copyWith(
        month: month,
        status: ViewStatus.loading,
        movements: const [],
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
            typeFilter: state.typeFilter,
            query: state.query,
            error: failure.message,
          ),
          (data) => MovementsState(
            month: month,
            status: ViewStatus.loaded,
            movements: data.$1,
            categories: {for (final c in data.$2) c.id: c},
            cards: {for (final k in data.$3) k.id: k},
            debts: MovementDebts.byMovement(data.$4),
            typeFilter: state.typeFilter,
            query: state.query,
          ),
        );
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    await _month.close();
    return super.close();
  }
}
