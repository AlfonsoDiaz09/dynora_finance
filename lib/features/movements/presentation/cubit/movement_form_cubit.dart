import 'dart:async';

import 'package:dynora_finance/core/enums/movement_type.dart';
import 'package:dynora_finance/core/enums/payment_method.dart';
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

enum InstallmentMode { single, interestFree, withInterest }

class MovementFormState extends Equatable {
  const MovementFormState({
    required this.type,
    required this.date,
    this.categories = const [],
    this.categoryId,
    this.cards = const [],
    this.cardId,
    this.paymentMethod = PaymentMethod.cash,
    this.installmentMode = InstallmentMode.single,
    this.installmentCount = 3,
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

  /// Cash or transfer when [cardId] is `null`; card otherwise.
  final PaymentMethod paymentMethod;
  final InstallmentMode installmentMode;
  final int installmentCount;
  final FormStatus status;
  final String? error;

  List<CategoryEntity> get categoriesOfType =>
      categories.where((c) => c.type == type).toList();

  CardEntity? get selectedCard =>
      cards.where((c) => c.id == cardId).firstOrNull;

  /// Installments are only offered for expenses on billed cards.
  bool get canUseInstallments =>
      type == MovementType.expense && (selectedCard?.hasBillingCycle ?? false);

  MovementFormState copyWith({
    MovementType? type,
    DateTime? date,
    List<CategoryEntity>? categories,
    String? Function()? categoryId,
    List<CardEntity>? cards,
    String? Function()? cardId,
    PaymentMethod? paymentMethod,
    InstallmentMode? installmentMode,
    int? installmentCount,
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
      paymentMethod: paymentMethod ?? this.paymentMethod,
      installmentMode: installmentMode ?? this.installmentMode,
      installmentCount: installmentCount ?? this.installmentCount,
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
    paymentMethod,
    installmentMode,
    installmentCount,
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
           paymentMethod:
               editing?.paymentMethod ??
               (initialCardId != null
                   ? PaymentMethod.card
                   : PaymentMethod.cash),
           installmentMode: _modeOf(editing),
           installmentCount: (editing?.installmentCount ?? 1) > 1
               ? editing!.installmentCount!
               : 3,
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
                _normalized(
                  state.copyWith(
                    categories: data.$1,
                    cards: data.$2,
                    cardId: cardStillExists ? null : () => null,
                    paymentMethod: cardStillExists || state.cardId == null
                        ? null
                        : PaymentMethod.cash,
                  ),
                ),
              );
            },
          ),
        );
  }

  void changeType(MovementType type) {
    if (type == state.type) return;
    emit(
      _normalized(
        state.copyWith(type: type, categoryId: () => null, error: () => null),
      ),
    );
  }

  void selectCategory(String id) =>
      emit(state.copyWith(categoryId: () => id, error: () => null));

  void selectCard(String id) => emit(
    _normalized(
      state.copyWith(
        cardId: () => id,
        paymentMethod: PaymentMethod.card,
        error: () => null,
      ),
    ),
  );

  /// Cash or transfer (no card).
  void selectMethod(PaymentMethod method) {
    assert(method != PaymentMethod.card, 'Use selectCard for cards');
    emit(
      _normalized(
        state.copyWith(
          cardId: () => null,
          paymentMethod: method,
          error: () => null,
        ),
      ),
    );
  }

  void selectInstallmentMode(InstallmentMode mode) =>
      emit(state.copyWith(installmentMode: mode, error: () => null));

  void selectInstallmentCount(int count) =>
      emit(state.copyWith(installmentCount: count, error: () => null));

  /// Falls back to a single charge when installments stop being possible
  /// (cards not loaded yet are not a reason to drop an edited plan).
  MovementFormState _normalized(MovementFormState next) =>
      next.canUseInstallments || next.cards.isEmpty
      ? next
      : next.copyWith(installmentMode: InstallmentMode.single);

  static InstallmentMode _modeOf(MovementEntity? movement) {
    if (movement == null || !movement.hasInstallments) {
      return InstallmentMode.single;
    }
    return movement.hasInterest
        ? InstallmentMode.withInterest
        : InstallmentMode.interestFree;
  }

  void changeDate(DateTime date) => emit(state.copyWith(date: date));

  Future<void> submit({
    required String title,
    required double? amount,
    required String note,
    double? interestRate,
  }) async {
    if (amount == null) {
      emit(state.copyWith(error: () => 'Ingresa un monto válido'));
      return;
    }
    if (state.categoryId == null) {
      emit(state.copyWith(error: () => 'Selecciona una categoría'));
      return;
    }
    final mode = state.canUseInstallments
        ? state.installmentMode
        : InstallmentMode.single;
    if (mode == InstallmentMode.withInterest &&
        (interestRate == null || interestRate <= 0)) {
      emit(state.copyWith(error: () => 'Ingresa la tasa de interés'));
      return;
    }
    final installmentCount = mode == InstallmentMode.single
        ? null
        : state.installmentCount;
    final installmentRate = mode == InstallmentMode.withInterest
        ? interestRate
        : null;

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
              paymentMethod: state.paymentMethod,
              installmentCount: installmentCount,
              installmentRate: installmentRate,
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
              paymentMethod: state.paymentMethod,
              installmentCount: installmentCount,
              installmentRate: installmentRate,
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
