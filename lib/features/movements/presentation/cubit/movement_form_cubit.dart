import 'dart:async';

import 'package:dynora_finance/core/enums/movement_type.dart';
import 'package:dynora_finance/core/error/failures.dart';
import 'package:dynora_finance/core/usecase/usecase.dart';
import 'package:dynora_finance/features/cards/domain/entities/card_entity.dart';
import 'package:dynora_finance/features/cards/domain/usecases/watch_cards.dart';
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
import 'package:rxdart/rxdart.dart';

class MovementFormState extends Equatable {
  const MovementFormState({
    required this.type,
    required this.date,
    this.categories = const [],
    this.categoryId,
    this.cards = const [],
    this.cardId,
    this.status = FormStatus.idle,
    this.error,
  });

  final MovementType type;
  final DateTime date;
  final List<CategoryEntity> categories;
  final String? categoryId;
  final List<CardEntity> cards;

  /// Card used to pay, `null` for cash or transfers.
  final String? cardId;
  final FormStatus status;
  final String? error;

  List<CategoryEntity> get categoriesOfType =>
      categories.where((c) => c.type == type).toList();

  CardEntity? get selectedCard =>
      cards.where((c) => c.id == cardId).firstOrNull;

  MovementFormState copyWith({
    MovementType? type,
    DateTime? date,
    List<CategoryEntity>? categories,
    String? Function()? categoryId,
    List<CardEntity>? cards,
    String? Function()? cardId,
    FormStatus? status,
    String? Function()? error,
  }) {
    return MovementFormState(
      type: type ?? this.type,
      date: date ?? this.date,
      categories: categories ?? this.categories,
      categoryId: categoryId != null ? categoryId() : this.categoryId,
      cards: cards ?? this.cards,
      cardId: cardId != null ? cardId() : this.cardId,
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
    cards,
    cardId,
    status,
    error,
  ];
}

class MovementFormCubit extends Cubit<MovementFormState> {
  MovementFormCubit({
    required WatchCategories watchCategories,
    required WatchCards watchCards,
    required AddMovement addMovement,
    required UpdateMovement updateMovement,
    required DeleteMovement deleteMovement,
    MovementType initialType = MovementType.expense,
    String? initialCardId,
    this.editing,
  }) : _watchCategories = watchCategories,
       _watchCards = watchCards,
       _addMovement = addMovement,
       _updateMovement = updateMovement,
       _deleteMovement = deleteMovement,
       super(
         MovementFormState(
           type: editing?.type ?? initialType,
           date: editing?.date ?? DateTime.now(),
           categoryId: editing?.categoryId,
           cardId: editing != null ? editing.cardId : initialCardId,
         ),
       );

  final WatchCategories _watchCategories;
  final WatchCards _watchCards;
  final AddMovement _addMovement;
  final UpdateMovement _updateMovement;
  final DeleteMovement _deleteMovement;

  /// Movement being edited, `null` when creating a new one.
  final MovementEntity? editing;

  StreamSubscription<void>? _subscription;

  void start() {
    _subscription =
        Rx.combineLatest2(
          _watchCategories(null),
          _watchCards(const NoParams()),
          (categories, cards) =>
              categories.flatMap((c) => cards.map((k) => (c, k))),
        ).listen(
          (result) => result.match(
            (failure) => emit(
              state.copyWith(
                status: FormStatus.failure,
                error: () => failure.message,
              ),
            ),
            (data) {
              final cardStillExists = data.$2.any((c) => c.id == state.cardId);
              emit(
                state.copyWith(
                  categories: data.$1,
                  cards: data.$2,
                  cardId: cardStillExists ? null : () => null,
                ),
              );
            },
          ),
        );
  }

  void changeType(MovementType type) {
    if (type == state.type) return;
    emit(state.copyWith(type: type, categoryId: () => null, error: () => null));
  }

  void selectCategory(String id) =>
      emit(state.copyWith(categoryId: () => id, error: () => null));

  /// Pass `null` for cash or transfers.
  void selectCard(String? id) =>
      emit(state.copyWith(cardId: () => id, error: () => null));

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
              cardId: state.cardId,
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
              cardId: state.cardId,
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
