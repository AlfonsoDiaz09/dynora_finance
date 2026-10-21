import 'dart:async';

import 'package:dynora_finance/core/error/failures.dart';
import 'package:dynora_finance/core/utils/month_range.dart';
import 'package:dynora_finance/features/categories/domain/entities/category_entity.dart';
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

class CategoryExpense extends Equatable {
  const CategoryExpense({
    required this.name,
    required this.iconKey,
    required this.colorValue,
    required this.amount,
    required this.share,
  });

  final String name;

  /// Category icon (see `CategoryIcons`); empty for unknown categories.
  final String iconKey;
  final int colorValue;
  final double amount;

  /// Fraction (0-1) of the month expense.
  final double share;

  @override
  List<Object?> get props => [name, iconKey, colorValue, amount, share];
}

class StatsState extends Equatable {
  const StatsState({
    required this.month,
    this.status = ViewStatus.loading,
    this.summary = MovementSummary.empty,
    this.previousExpense = 0,
    this.categoryExpenses = const [],
    this.error,
  });

  final MonthRange month;
  final ViewStatus status;
  final MovementSummary summary;
  final double previousExpense;
  final List<CategoryExpense> categoryExpenses;
  final String? error;

  /// Expense change vs the previous month (0.12 = 12% more), or `null` when
  /// the previous month has no expenses.
  double? get expenseTrend => previousExpense == 0
      ? null
      : (summary.expense - previousExpense) / previousExpense;

  /// Share of the income not spent (0.25 = 25%), `null` without income.
  double? get savingsRate =>
      summary.income > 0 ? summary.balance / summary.income : null;

  /// Average expense per day: days elapsed for the current month, every day
  /// of the month otherwise.
  double dailyAverage(DateTime now) {
    final daysInMonth = DateTime(
      month.start.year,
      month.start.month + 1,
      0,
    ).day;
    final days = month.contains(now) ? now.day : daysInMonth;
    return summary.expense / days;
  }

  @override
  List<Object?> get props => [
    month,
    status,
    summary.income,
    summary.expense,
    previousExpense,
    categoryExpenses,
    error,
  ];
}

class StatsCubit extends Cubit<StatsState> {
  StatsCubit({
    required WatchMovements watchMovements,
    required WatchCategories watchCategories,
  }) : _watchMovements = watchMovements,
       _watchCategories = watchCategories,
       super(StatsState(month: MonthRange(DateTime.now())));

  final WatchMovements _watchMovements;
  final WatchCategories _watchCategories;
  late final BehaviorSubject<MonthRange> _month = BehaviorSubject.seeded(
    state.month,
  );
  StreamSubscription<StatsState>? _subscription;

  void start() {
    _subscription = _month
        .switchMap(
          (month) => Rx.combineLatest2(
            _watchMovements(
              MovementFilter(from: month.previous.start, to: month.end),
            ),
            _watchCategories(null),
            (movements, categories) =>
                _buildState(month, movements, categories),
          ),
        )
        .listen(emit);
  }

  void previousMonth() => _changeMonth(state.month.previous);

  void nextMonth() => _changeMonth(state.month.next);

  void currentMonth() => _changeMonth(MonthRange(DateTime.now()));

  void _changeMonth(MonthRange month) {
    if (month == state.month) return;
    emit(StatsState(month: month));
    _month.add(month);
  }

  StatsState _buildState(
    MonthRange month,
    Either<Failure, List<MovementEntity>> movements,
    Either<Failure, List<CategoryEntity>> categories,
  ) {
    return movements.flatMap((m) => categories.map((c) => (m, c))).match(
      (failure) => StatsState(
        month: month,
        status: ViewStatus.failure,
        error: failure.message,
      ),
      (data) {
        final current = MovementSummary.of(
          data.$1.where((m) => month.contains(m.date)),
        );
        final previous = MovementSummary.of(
          data.$1.where((m) => month.previous.contains(m.date)),
        );
        final categoriesById = {for (final c in data.$2) c.id: c};

        return StatsState(
          month: month,
          status: ViewStatus.loaded,
          summary: current,
          previousExpense: previous.expense,
          categoryExpenses: _categoryExpenses(current, categoriesById),
        );
      },
    );
  }

  List<CategoryExpense> _categoryExpenses(
    MovementSummary summary,
    Map<String, CategoryEntity> categories,
  ) {
    if (summary.expense == 0) return const [];
    final items = [
      for (final entry in summary.expenseByCategory.entries)
        CategoryExpense(
          name: categories[entry.key]?.name ?? 'Sin categoría',
          iconKey: categories[entry.key]?.iconKey ?? '',
          colorValue: categories[entry.key]?.colorValue ?? 0xFF9E9E9E,
          amount: entry.value,
          share: entry.value / summary.expense,
        ),
    ];
    items.sort((a, b) => b.amount.compareTo(a.amount));
    return items;
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    await _month.close();
    return super.close();
  }
}
