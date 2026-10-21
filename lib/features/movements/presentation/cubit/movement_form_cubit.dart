import 'dart:async';

import 'package:dynora_finance/core/enums/movement_type.dart';
import 'package:dynora_finance/core/error/failures.dart';
import 'package:dynora_finance/features/categories/domain/entities/category_entity.dart';
import 'package:dynora_finance/features/categories/domain/usecases/watch_categories.dart';
import 'package:dynora_finance/features/movements/domain/entities/movement_entity.dart';
import 'package:dynora_finance/features/movements/domain/usecases/add_movement.dart';
import 'package:dynora_finance/features/movements/domain/usecases/delete_movement.dart';
import 'package:dynora_finance/features/movements/domain/usecases/update_movement.dart';
import 'package:dynora_finance/shared/bloc/form_status.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

class MovementFormState extends Equatable {
  const MovementFormState({
    required this.type,
    required this.date,
    this.categories = const [],
    this.categoryId,
    this.status = FormStatus.idle,
    this.error,
  });

  final MovementType type;
  final DateTime date;
  final List<CategoryEntity> categories;
  final String? categoryId;
  final FormStatus status;
  final String? error;

  List<CategoryEntity> get categoriesOfType =>
      categories.where((c) => c.type == type).toList();

  MovementFormState copyWith({
    MovementType? type,
    DateTime? date,
    List<CategoryEntity>? categories,
    String? Function()? categoryId,
    FormStatus? status,
    String? Function()? error,
  }) {
    return MovementFormState(
      type: type ?? this.type,
      date: date ?? this.date,
      categories: categories ?? this.categories,
      categoryId: categoryId != null ? categoryId() : this.categoryId,
      status: status ?? this.status,
      error: error != null ? error() : this.error,
    );
  }

  @override
  List<Object?> get props => [
    type,
    date,
    categories,
    categoryId,
    status,
    error,
  ];
}

class MovementFormCubit extends Cubit<MovementFormState> {
  MovementFormCubit({
    required WatchCategories watchCategories,
    required AddMovement addMovement,
    required UpdateMovement updateMovement,
    required DeleteMovement deleteMovement,
    MovementType initialType = MovementType.expense,
    this.editing,
  }) : _watchCategories = watchCategories,
       _addMovement = addMovement,
       _updateMovement = updateMovement,
       _deleteMovement = deleteMovement,
       super(
         MovementFormState(
           type: editing?.type ?? initialType,
           date: editing?.date ?? DateTime.now(),
           categoryId: editing?.categoryId,
         ),
       );

  final WatchCategories _watchCategories;
  final AddMovement _addMovement;
  final UpdateMovement _updateMovement;
  final DeleteMovement _deleteMovement;

  /// Movement being edited, `null` when creating a new one.
  final MovementEntity? editing;

  StreamSubscription<Either<Failure, List<CategoryEntity>>>? _subscription;

  void start() {
    _subscription = _watchCategories(null).listen(
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

  void changeType(MovementType type) {
    if (type == state.type) return;
    emit(state.copyWith(type: type, categoryId: () => null, error: () => null));
  }

  void selectCategory(String id) =>
      emit(state.copyWith(categoryId: () => id, error: () => null));

  void changeDate(DateTime date) => emit(state.copyWith(date: date));

  Future<void> submit({
    required String title,
    required double? amount,
    required String note,
  }) async {
    if (amount == null) {
      emit(state.copyWith(error: () => 'Ingresa un monto válido'));
      return;
    }
    if (state.categoryId == null) {
      emit(state.copyWith(error: () => 'Selecciona una categoría'));
      return;
    }

    emit(state.copyWith(status: FormStatus.submitting, error: () => null));
    final cleanNote = note.trim().isEmpty ? null : note.trim();
    final current = editing;

    final result = current == null
        ? await _addMovement(
            AddMovementParams(
              title: title,
              amount: amount,
              type: state.type,
              categoryId: state.categoryId!,
              date: state.date,
              note: cleanNote,
            ),
          )
        : await _updateMovement(
            MovementEntity(
              id: current.id,
              title: title,
              amount: amount,
              type: state.type,
              categoryId: state.categoryId!,
              date: state.date,
              note: cleanNote,
              createdAt: current.createdAt,
              updatedAt: current.updatedAt,
            ),
          );

    _emitResult(result);
  }

  Future<void> delete() async {
    final current = editing;
    if (current == null) return;
    emit(state.copyWith(status: FormStatus.submitting, error: () => null));
    _emitResult(await _deleteMovement(current.id));
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
