import 'dart:async';

import 'package:dynora_finance/core/enums/movement_type.dart';
import 'package:dynora_finance/core/enums/payment_method.dart';
import 'package:dynora_finance/core/error/failures.dart';
import 'package:dynora_finance/core/usecase/usecase.dart';
import 'package:dynora_finance/features/cards/domain/entities/card_entity.dart';
import 'package:dynora_finance/features/cards/domain/usecases/watch_cards.dart';
import 'package:dynora_finance/features/categories/domain/entities/category_entity.dart';
import 'package:dynora_finance/features/categories/domain/usecases/watch_categories.dart';
import 'package:dynora_finance/features/debts/domain/entities/person_entity.dart';
import 'package:dynora_finance/features/debts/domain/usecases/add_person.dart';
import 'package:dynora_finance/features/debts/domain/usecases/set_movement_debts.dart';
import 'package:dynora_finance/features/debts/domain/usecases/watch_debts.dart';
import 'package:dynora_finance/features/debts/domain/usecases/watch_people.dart';
import 'package:dynora_finance/features/movements/domain/entities/movement_entity.dart';
import 'package:dynora_finance/features/movements/domain/usecases/add_movement.dart';
import 'package:dynora_finance/features/movements/domain/usecases/delete_movement.dart';
import 'package:dynora_finance/features/movements/domain/usecases/update_movement.dart';
import 'package:dynora_finance/features/movements/presentation/cubit/share_draft.dart';
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
    this.people = const [],
    this.share = const ShareDraft(),
    this.isWithdrawal = false,
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
  final List<PersonEntity> people;

  /// Who owes you part of this expense.
  final ShareDraft share;

  /// Cash withdrawal from a credit card (an expense on the card, income
  /// for you).
  final bool isWithdrawal;

  /// Cards offered: only billed cards for withdrawals.
  List<CardEntity> get availableCards => isWithdrawal
      ? [
          for (final c in cards)
            if (c.hasBillingCycle) c,
        ]
      : cards;
  final FormStatus status;
  final String? error;

  List<CategoryEntity> get categoriesOfType =>
      categories.where((c) => c.type == type).toList();

  CardEntity? get selectedCard =>
      cards.where((c) => c.id == cardId).firstOrNull;

  /// Installments are only offered for expenses on billed cards.
  bool get canUseInstallments =>
      !isWithdrawal &&
      type == MovementType.expense &&
      (selectedCard?.hasBillingCycle ?? false);

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
    List<PersonEntity>? people,
    ShareDraft? share,
    bool? isWithdrawal,
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
      people: people ?? this.people,
      share: share ?? this.share,
      isWithdrawal: isWithdrawal ?? this.isWithdrawal,
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
    people,
    share,
    isWithdrawal,
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
    required WatchPeople watchPeople,
    required AddPerson addPerson,
    required WatchDebts watchDebts,
    required SetMovementDebts setMovementDebts,
    MovementType initialType = MovementType.expense,
    String? initialCardId,
    this.editing,
  }) : _watchCategories = watchCategories,
       _watchCards = watchCards,
       _addMovement = addMovement,
       _updateMovement = updateMovement,
       _deleteMovement = deleteMovement,
       _watchPeople = watchPeople,
       _addPerson = addPerson,
       _watchDebts = watchDebts,
       _setMovementDebts = setMovementDebts,
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
               : (editing?.isCashWithdrawal ?? false)
               ? 1
               : 3,
           isWithdrawal: editing?.isCashWithdrawal ?? false,
         ),
       );

  final WatchCategories _watchCategories;
  final WatchCards _watchCards;
  final AddMovement _addMovement;
  final UpdateMovement _updateMovement;
  final DeleteMovement _deleteMovement;
  final WatchPeople _watchPeople;
  final AddPerson _addPerson;
  final WatchDebts _watchDebts;
  final SetMovementDebts _setMovementDebts;

  /// Movement being edited, `null` when creating a new one.
  final MovementEntity? editing;

  StreamSubscription<void>? _subscription;
  StreamSubscription<void>? _peopleSubscription;

  void start() {
    _peopleSubscription = _watchPeople(const NoParams()).listen(
      (result) => result.match(
        (_) {},
        (people) => emit(state.copyWith(people: people)),
      ),
    );
    final current = editing;
    if (current != null) _loadShare(current);

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
    if (type == state.type && !state.isWithdrawal) return;
    emit(
      _normalized(
        state.copyWith(
          type: type,
          isWithdrawal: false,
          categoryId: () => null,
          error: () => null,
        ),
      ),
    );
  }

  /// Switches to a cash withdrawal from a credit card.
  void selectWithdrawal() {
    if (state.isWithdrawal) return;
    emit(
      _normalized(
        state.copyWith(
          type: MovementType.expense,
          isWithdrawal: true,
          categoryId: () => null,
          installmentCount: 1,
          share: state.share.copyWith(enabled: false),
          error: () => null,
        ),
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
  MovementFormState _normalized(MovementFormState next) {
    if (next.cards.isEmpty) return next;
    var result = next;
    // Withdrawals only come from credit or departmental cards.
    if (result.isWithdrawal &&
        !(result.selectedCard?.hasBillingCycle ?? false)) {
      result = result.copyWith(
        cardId: () => null,
        paymentMethod: PaymentMethod.cash,
      );
    }
    return result.canUseInstallments || result.isWithdrawal
        ? result
        : result.copyWith(installmentMode: InstallmentMode.single);
  }

  static InstallmentMode _modeOf(MovementEntity? movement) {
    if (movement == null || !movement.hasInstallments) {
      return InstallmentMode.single;
    }
    return movement.hasInterest
        ? InstallmentMode.withInterest
        : InstallmentMode.interestFree;
  }

  void changeDate(DateTime date) => emit(state.copyWith(date: date));

  void toggleSharing(bool enabled) =>
      emit(state.copyWith(share: state.share.copyWith(enabled: enabled)));

  void togglePerson(String id) {
    final ids = [...state.share.personIds];
    ids.contains(id) ? ids.remove(id) : ids.add(id);
    emit(state.copyWith(share: state.share.copyWith(personIds: ids)));
  }

  /// Creates (or reuses) a person by name and adds them to the split.
  Future<void> addPerson(String name) async {
    final result = await _addPerson(name);
    result.match(
      (failure) => emit(state.copyWith(error: () => failure.message)),
      (person) {
        final ids = state.share.personIds;
        emit(
          state.copyWith(
            error: () => null,
            share: state.share.copyWith(
              personIds: ids.contains(person.id) ? ids : [...ids, person.id],
            ),
          ),
        );
      },
    );
  }

  void selectSplitMode(SplitMode mode) =>
      emit(state.copyWith(share: state.share.copyWith(mode: mode)));

  void setIncludeMe(bool value) =>
      emit(state.copyWith(share: state.share.copyWith(includeMe: value)));

  Future<void> _loadShare(MovementEntity movement) async {
    final result = await _watchDebts(const NoParams()).first;
    result.match((_) {}, (debts) {
      if (isClosed) return;
      emit(
        state.copyWith(
          share: ShareDraft.fromDebts([
            for (final d in debts)
              if (d.movementId == movement.id) d,
          ], movement.amount),
        ),
      );
    });
  }

  Future<void> submit({
    required String title,
    required double? amount,
    required String note,
    double? interestRate,
    Map<String, double?> customShares = const {},
  }) async {
    if (amount == null) {
      emit(state.copyWith(error: () => 'Ingresa un monto válido'));
      return;
    }
    final withdrawal = state.isWithdrawal;
    if (withdrawal && state.cardId == null) {
      emit(state.copyWith(error: () => 'Elige la tarjeta de crédito'));
      return;
    }
    if (!withdrawal && state.categoryId == null) {
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
    final int? installmentCount;
    final double? installmentRate;
    if (withdrawal) {
      installmentCount = state.installmentCount > 1
          ? state.installmentCount
          : null;
      installmentRate = (interestRate ?? 0) > 0 ? interestRate : null;
    } else {
      installmentCount = mode == InstallmentMode.single
          ? null
          : state.installmentCount;
      installmentRate = mode == InstallmentMode.withInterest
          ? interestRate
          : null;
    }
    final categoryId = withdrawal
        ? MovementEntity.cashWithdrawalCategoryId
        : state.categoryId!;

    // Validated before saving so an invalid split doesn't leave the
    // movement half saved. Incomes are never shared.
    final sharesResult = state.type == MovementType.expense && !withdrawal
        ? state.share.shares(amount, customShares)
        : right<String, Map<String, double>>(const {});
    if (sharesResult case Left(value: final message)) {
      emit(state.copyWith(error: () => message));
      return;
    }
    final shares = sharesResult.getOrElse((_) => const {});

    emit(state.copyWith(status: FormStatus.submitting, error: () => null));
    final cleanNote = note.trim().isEmpty ? null : note.trim();
    final current = editing;

    final result = current == null
        ? await _addMovement(
            AddMovementParams(
              title: title,
              amount: amount,
              type: state.type,
              categoryId: categoryId,
              date: state.date,
              note: cleanNote,
              cardId: state.cardId,
              paymentMethod: state.paymentMethod,
              installmentCount: installmentCount,
              installmentRate: installmentRate,
              isCashWithdrawal: withdrawal,
            ),
          )
        : await _updateMovement(
            MovementEntity(
              id: current.id,
              title: title,
              amount: amount,
              type: state.type,
              categoryId: categoryId,
              date: state.date,
              note: cleanNote,
              cardId: state.cardId,
              paymentMethod: state.paymentMethod,
              installmentCount: installmentCount,
              installmentRate: installmentRate,
              isCashWithdrawal: withdrawal,
              createdAt: current.createdAt,
              updatedAt: current.updatedAt,
            ),
          );

    if (result case Right(
      value: final movement,
    ) when shares.isNotEmpty || current != null) {
      _emitResult(
        await _setMovementDebts(
          SetMovementDebtsParams(
            movementId: movement.id,
            movementAmount: amount,
            shares: shares,
          ),
        ),
      );
      return;
    }
    _emitResult(result);
  }

  Future<void> delete() async {
    final current = editing;
    if (current == null) return;
    emit(state.copyWith(status: FormStatus.submitting, error: () => null));
    final result = await _deleteMovement(current.id);
    if (result.isRight()) {
      _emitResult(
        await _setMovementDebts(SetMovementDebtsParams.clear(current.id)),
      );
      return;
    }
    _emitResult(result);
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
    await _peopleSubscription?.cancel();
    return super.close();
  }
}
