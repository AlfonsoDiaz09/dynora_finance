import 'dart:async';

import 'package:dynora_finance/core/error/failures.dart';
import 'package:dynora_finance/core/usecase/usecase.dart';
import 'package:dynora_finance/core/utils/month_range.dart';
import 'package:dynora_finance/features/cards/domain/entities/billing_period.dart';
import 'package:dynora_finance/features/cards/domain/entities/card_entity.dart';
import 'package:dynora_finance/features/cards/domain/entities/card_statement.dart';
import 'package:dynora_finance/features/cards/domain/usecases/watch_cards.dart';
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

/// Movements of a debit card in one calendar month.
class MonthMovements extends Equatable {
  const MonthMovements({required this.month, required this.movements});

  final MonthRange month;
  final List<MovementEntity> movements;

  MovementSummary get summary => MovementSummary.of(movements);

  @override
  List<Object?> get props => [month, movements];
}

class CardDetailState extends Equatable {
  const CardDetailState({
    this.status = ViewStatus.loading,
    this.card,
    this.statements = const [],
    this.selectedPeriod,
    this.months = const [],
    this.selectedMonth,
    this.categories = const {},
    this.error,
  });

  final ViewStatus status;

  /// `null` once loaded means the card was deleted.
  final CardEntity? card;

  /// Billing periods, newest first (credit and departmental cards).
  final List<CardStatement> statements;
  final BillingPeriod? selectedPeriod;

  /// Calendar months, newest first (debit cards).
  final List<MonthMovements> months;
  final MonthRange? selectedMonth;
  final Map<String, CategoryEntity> categories;
  final String? error;

  CardStatement? get selectedStatement =>
      statements.where((s) => s.period == selectedPeriod).firstOrNull;

  MonthMovements? get selectedMonthMovements =>
      months.where((m) => m.month == selectedMonth).firstOrNull;

  CardDetailState copyWith({
    BillingPeriod? selectedPeriod,
    MonthRange? selectedMonth,
  }) {
    return CardDetailState(
      status: status,
      card: card,
      statements: statements,
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
      months: months,
      selectedMonth: selectedMonth ?? this.selectedMonth,
      categories: categories,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
    status,
    card,
    statements,
    selectedPeriod,
    months,
    selectedMonth,
    categories,
    error,
  ];
}

class CardDetailCubit extends Cubit<CardDetailState> {
  CardDetailCubit({
    required this.cardId,
    required WatchCards watchCards,
    required WatchMovements watchMovements,
    required WatchCategories watchCategories,
  }) : _watchCards = watchCards,
       _watchMovements = watchMovements,
       _watchCategories = watchCategories,
       super(const CardDetailState());

  final String cardId;
  final WatchCards _watchCards;
  final WatchMovements _watchMovements;
  final WatchCategories _watchCategories;
  StreamSubscription<CardDetailState>? _subscription;

  void start() {
    _subscription = Rx.combineLatest3(
      _watchCards(const NoParams()),
      _watchMovements(MovementFilter(cardId: cardId)),
      _watchCategories(null),
      _buildState,
    ).listen(emit);
  }

  void selectPeriod(BillingPeriod period) =>
      emit(state.copyWith(selectedPeriod: period));

  void selectMonth(MonthRange month) =>
      emit(state.copyWith(selectedMonth: month));

  CardDetailState _buildState(
    Either<Failure, List<CardEntity>> cards,
    Either<Failure, List<MovementEntity>> movements,
    Either<Failure, List<CategoryEntity>> categories,
  ) {
    return cards
        .flatMap(
          (c) => movements.flatMap((m) => categories.map((k) => (c, m, k))),
        )
        .match(
          (failure) => CardDetailState(
            status: ViewStatus.failure,
            error: failure.message,
          ),
          (data) {
            final card = data.$1.where((c) => c.id == cardId).firstOrNull;
            final categoriesById = {for (final c in data.$3) c.id: c};
            if (card == null) {
              return CardDetailState(
                status: ViewStatus.loaded,
                categories: categoriesById,
              );
            }

            final now = DateTime.now();
            if (card.hasBillingCycle) {
              final statements = CardStatement.build(card, data.$2, now);
              // Keep the user's selection while it still exists (it can
              // vanish when the cutoff day changes); otherwise show the next
              // payment.
              bool listed(BillingPeriod? p) =>
                  statements.any((s) => s.period == p);
              final previous = state.selectedPeriod;
              final upcoming = card.upcomingPeriod(now);
              return CardDetailState(
                status: ViewStatus.loaded,
                card: card,
                statements: statements,
                selectedPeriod: listed(previous)
                    ? previous
                    : listed(upcoming)
                    ? upcoming
                    : card.billingPeriodFor(now),
                categories: categoriesById,
              );
            }

            final months = _byMonth(data.$2, MonthRange(now));
            final previous = state.selectedMonth;
            final keep = months.any((m) => m.month == previous);
            return CardDetailState(
              status: ViewStatus.loaded,
              card: card,
              months: months,
              selectedMonth: keep ? previous : MonthRange(now),
              categories: categoriesById,
            );
          },
        );
  }

  /// Every month from the oldest movement up to [current] (or the newest
  /// movement), newest first. [movements] arrive sorted newest first.
  List<MonthMovements> _byMonth(
    List<MovementEntity> movements,
    MonthRange current,
  ) {
    final byMonth = <MonthRange, List<MovementEntity>>{};
    for (final movement in movements) {
      byMonth.putIfAbsent(MonthRange(movement.date), () => []).add(movement);
    }

    var first = current;
    var last = current;
    for (final month in byMonth.keys) {
      if (month.start.isBefore(first.start)) first = month;
      if (month.start.isAfter(last.start)) last = month;
    }

    final months = <MonthMovements>[];
    for (
      var month = last;
      !month.start.isBefore(first.start);
      month = month.previous
    ) {
      months.add(MonthMovements(month: month, movements: byMonth[month] ?? []));
    }
    return months;
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
