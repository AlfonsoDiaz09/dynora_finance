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
    this.error,
  });

  final MonthRange month;
  final ViewStatus status;
  final MovementSummary summary;
  final List<MovementDayGroup> groups;
  final Map<String, CategoryEntity> categories;
  final String? error;

  @override
  List<Object?> get props => [
    month,
    status,
    summary.income,
    summary.expense,
    groups,
    categories,
    error,
  ];
}

class MovementsCubit extends Cubit<MovementsState> {
  MovementsCubit({
    required WatchMovements watchMovements,
    required WatchCategories watchCategories,
  }) : _watchMovements = watchMovements,
       _watchCategories = watchCategories,
       super(MovementsState(month: MonthRange(DateTime.now())));

  final WatchMovements _watchMovements;
  final WatchCategories _watchCategories;
  late final BehaviorSubject<MonthRange> _month = BehaviorSubject.seeded(
    state.month,
  );
  StreamSubscription<MovementsState>? _subscription;

  void start() {
    _subscription = _month
        .switchMap(
          (month) => Rx.combineLatest2(
            _watchMovements(MovementFilter(from: month.start, to: month.end)),
            _watchCategories(null),
            (movements, categories) =>
                _buildState(month, movements, categories),
          ),
        )
        .listen(emit);
  }

  void previousMonth() => _changeMonth(state.month.previous);

  void nextMonth() => _changeMonth(state.month.next);

  void _changeMonth(MonthRange month) {
    emit(MovementsState(month: month, categories: state.categories));
    _month.add(month);
  }

  MovementsState _buildState(
    MonthRange month,
    Either<Failure, List<MovementEntity>> movements,
    Either<Failure, List<CategoryEntity>> categories,
  ) {
    return movements
        .flatMap((m) => categories.map((c) => (m, c)))
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
