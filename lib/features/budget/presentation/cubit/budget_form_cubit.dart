import 'dart:async';

import 'package:dynora_finance/core/enums/movement_type.dart';
import 'package:dynora_finance/core/error/failures.dart';
import 'package:dynora_finance/features/budget/domain/entities/budget_entity.dart';
import 'package:dynora_finance/features/budget/domain/usecases/delete_budget.dart';
import 'package:dynora_finance/features/budget/domain/usecases/set_budget.dart';
import 'package:dynora_finance/features/categories/domain/entities/category_entity.dart';
import 'package:dynora_finance/features/categories/domain/usecases/watch_categories.dart';
import 'package:dynora_finance/shared/bloc/form_status.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

class BudgetFormState extends Equatable {
  const BudgetFormState({
    this.categories = const [],
    this.categoryId,
    this.status = FormStatus.idle,
    this.error,
  });

  final List<CategoryEntity> categories;
  final String? categoryId;
  final FormStatus status;
  final String? error;

  BudgetFormState copyWith({
    List<CategoryEntity>? categories,
    String? Function()? categoryId,
    FormStatus? status,
    String? Function()? error,
  }) {
    return BudgetFormState(
      categories: categories ?? this.categories,
      categoryId: categoryId != null ? categoryId() : this.categoryId,
      status: status ?? this.status,
      error: error != null ? error() : this.error,
    );
  }

  @override
  List<Object?> get props => [categories, categoryId, status, error];
}

class BudgetFormCubit extends Cubit<BudgetFormState> {
  BudgetFormCubit({
    required WatchCategories watchCategories,
    required SetBudget setBudget,
    required DeleteBudget deleteBudget,
    this.editing,
  }) : _watchCategories = watchCategories,
       _setBudget = setBudget,
       _deleteBudget = deleteBudget,
       super(BudgetFormState(categoryId: editing?.categoryId));

  final WatchCategories _watchCategories;
  final SetBudget _setBudget;
  final DeleteBudget _deleteBudget;

  /// Budget being edited, `null` when creating a new one.
  final BudgetEntity? editing;

  StreamSubscription<Either<Failure, List<CategoryEntity>>>? _subscription;

  void start() {
    _subscription = _watchCategories(MovementType.expense).listen(
      (result) => result.match(
        (failure) => emit(
          state.copyWith(
            status: FormStatus.failure,
            error: () => failure.message,
          ),
        ),
        (categories) => emit(state.copyWith(categories: categories)),
      ),
    );
  }

  void selectCategory(String id) {
    // The category identifies the budget, so it is fixed while editing.
    if (editing != null) return;
    emit(state.copyWith(categoryId: () => id, error: () => null));
  }

  Future<void> submit(double? amount) async {
    if (amount == null) {
      emit(state.copyWith(error: () => 'Ingresa un monto válido'));
      return;
    }
    if (state.categoryId == null) {
      emit(state.copyWith(error: () => 'Selecciona una categoría'));
      return;
    }

    emit(state.copyWith(status: FormStatus.submitting, error: () => null));
    _emitResult(
      await _setBudget(
        SetBudgetParams(categoryId: state.categoryId!, amount: amount),
      ),
    );
  }

  Future<void> delete() async {
    final current = editing;
    if (current == null) return;
    emit(state.copyWith(status: FormStatus.submitting, error: () => null));
    _emitResult(await _deleteBudget(current.id));
  }

  void _emitResult(Either<Failure, Object> result) {
    result.match(
      (failure) => emit(
        state.copyWith(
          status: FormStatus.failure,
          error: () => failure.message,
        ),
      ),
      (_) => emit(state.copyWith(status: FormStatus.success)),
    );
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
