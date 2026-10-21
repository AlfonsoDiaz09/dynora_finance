import 'dart:async';

import 'package:dynora_finance/core/enums/movement_type.dart';
import 'package:dynora_finance/core/error/failures.dart';
import 'package:dynora_finance/core/usecase/usecase.dart';
import 'package:dynora_finance/core/utils/month_range.dart';
import 'package:dynora_finance/features/budget/domain/entities/budget_entity.dart';
import 'package:dynora_finance/features/budget/domain/usecases/watch_budgets.dart';
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

class BudgetItem extends Equatable {
  const BudgetItem({
    required this.budget,
    required this.category,
    required this.spent,
  });

  final BudgetEntity budget;
  final CategoryEntity category;

  /// Expenses of the current month in [category].
  final double spent;

  @override
  List<Object?> get props => [budget, category, spent];
}

class BudgetState extends Equatable {
  const BudgetState({
    this.status = ViewStatus.loading,
    this.items = const [],
    this.error,
  });

  final ViewStatus status;
  final List<BudgetItem> items;
  final String? error;

  double get totalLimit => items.fold(0, (sum, i) => sum + i.budget.amount);

  double get totalSpent => items.fold(0, (sum, i) => sum + i.spent);

  @override
  List<Object?> get props => [status, items, error];
}

class BudgetCubit extends Cubit<BudgetState> {
  BudgetCubit({
    required WatchBudgets watchBudgets,
    required WatchCategories watchCategories,
    required WatchMovements watchMovements,
  }) : _watchBudgets = watchBudgets,
       _watchCategories = watchCategories,
       _watchMovements = watchMovements,
       super(const BudgetState());

  final WatchBudgets _watchBudgets;
  final WatchCategories _watchCategories;
  final WatchMovements _watchMovements;
  StreamSubscription<BudgetState>? _subscription;

  void start() {
    final month = MonthRange(DateTime.now());
    _subscription = Rx.combineLatest3(
      _watchBudgets(const NoParams()),
      _watchCategories(MovementType.expense),
      _watchMovements(
        MovementFilter(
          from: month.start,
          to: month.end,
          type: MovementType.expense,
        ),
      ),
      _buildState,
    ).listen(emit);
  }

  BudgetState _buildState(
    Either<Failure, List<BudgetEntity>> budgets,
    Either<Failure, List<CategoryEntity>> categories,
    Either<Failure, List<MovementEntity>> movements,
  ) {
    return budgets
        .flatMap(
          (b) => categories.flatMap((c) => movements.map((m) => (b, c, m))),
        )
        .match(
          (failure) =>
              BudgetState(status: ViewStatus.failure, error: failure.message),
          (data) {
            final categoriesById = {for (final c in data.$2) c.id: c};
            final spent = MovementSummary.of(data.$3).expenseByCategory;
            final items = [
              for (final budget in data.$1)
                if (categoriesById[budget.categoryId] case final category?)
                  BudgetItem(
                    budget: budget,
                    category: category,
                    spent: spent[budget.categoryId] ?? 0,
                  ),
            ]..sort((a, b) => a.category.name.compareTo(b.category.name));

            return BudgetState(status: ViewStatus.loaded, items: items);
          },
        );
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
