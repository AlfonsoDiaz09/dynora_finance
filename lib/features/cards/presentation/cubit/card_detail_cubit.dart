import 'dart:async';

import 'package:dynora_finance/core/error/failures.dart';
import 'package:dynora_finance/core/usecase/usecase.dart';
import 'package:dynora_finance/core/utils/month_range.dart';
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
    this.months = const [],
    this.categories = const {},
    this.error,
  });

  final ViewStatus status;

  /// `null` once loaded means the card was deleted.
  final CardEntity? card;

  /// Billing periods, newest first (credit and departmental cards).
  final List<CardStatement> statements;

  /// Calendar months, newest first (debit cards).
  final List<MonthMovements> months;
  final Map<String, CategoryEntity> categories;
  final String? error;

  @override
  List<Object?> get props => [
    status,
    card,
    statements,
    months,
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

            return CardDetailState(
              status: ViewStatus.loaded,
              card: card,
              statements: card.hasBillingCycle
                  ? CardStatement.build(card, data.$2, DateTime.now())
                  : const [],
              months: card.hasBillingCycle ? const [] : _byMonth(data.$2),
              categories: categoriesById,
            );
          },
        );
  }

  /// [movements] arrive sorted by date (newest first).
  List<MonthMovements> _byMonth(List<MovementEntity> movements) {
    final months = <MonthRange, List<MovementEntity>>{};
    for (final movement in movements) {
      months.putIfAbsent(MonthRange(movement.date), () => []).add(movement);
    }
    return [
      for (final entry in months.entries)
        MonthMovements(month: entry.key, movements: entry.value),
    ];
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
