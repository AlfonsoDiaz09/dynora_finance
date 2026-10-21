import 'dart:async';

import 'package:dynora_finance/core/error/failures.dart';
import 'package:dynora_finance/core/usecase/usecase.dart';
import 'package:dynora_finance/core/utils/month_range.dart';
import 'package:dynora_finance/features/cards/domain/entities/card_entity.dart';
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

class UpcomingPayment extends Equatable {
  const UpcomingPayment({
    required this.card,
    required this.dueDate,
    required this.daysLeft,
  });

  final CardEntity card;
  final DateTime dueDate;
  final int daysLeft;

  @override
  List<Object?> get props => [card, dueDate, daysLeft];
}

class HomeState extends Equatable {
  const HomeState({
    this.status = ViewStatus.loading,
    this.balance = 0,
    this.monthSummary = MovementSummary.empty,
    this.recentMovements = const [],
    this.categories = const {},
    this.upcomingPayments = const [],
    this.error,
  });

  final ViewStatus status;

  /// All-time income minus expenses.
  final double balance;

  /// Totals of the current month.
  final MovementSummary monthSummary;
  final List<MovementEntity> recentMovements;
  final Map<String, CategoryEntity> categories;
  final List<UpcomingPayment> upcomingPayments;
  final String? error;

  @override
  List<Object?> get props => [
    status,
    balance,
    monthSummary.income,
    monthSummary.expense,
    recentMovements,
    categories,
    upcomingPayments,
    error,
  ];
}

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({
    required WatchMovements watchMovements,
    required WatchCategories watchCategories,
    required WatchCards watchCards,
  }) : _watchMovements = watchMovements,
       _watchCategories = watchCategories,
       _watchCards = watchCards,
       super(const HomeState());

  static const int recentLimit = 5;
  static const int upcomingLimit = 3;

  final WatchMovements _watchMovements;
  final WatchCategories _watchCategories;
  final WatchCards _watchCards;
  StreamSubscription<HomeState>? _subscription;

  void start() {
    _subscription = Rx.combineLatest3(
      _watchMovements(MovementFilter.all),
      _watchCategories(null),
      _watchCards(const NoParams()),
      _buildState,
    ).listen(emit);
  }

  HomeState _buildState(
    Either<Failure, List<MovementEntity>> movements,
    Either<Failure, List<CategoryEntity>> categories,
    Either<Failure, List<CardEntity>> cards,
  ) {
    return movements
        .flatMap((m) => categories.flatMap((c) => cards.map((k) => (m, c, k))))
        .match(
          (failure) =>
              HomeState(status: ViewStatus.failure, error: failure.message),
          (data) {
            final now = DateTime.now();
            final month = MonthRange(now);

            return HomeState(
              status: ViewStatus.loaded,
              balance: MovementSummary.of(data.$1).balance,
              monthSummary: MovementSummary.of(
                data.$1.where((m) => month.contains(m.date)),
              ),
              recentMovements: data.$1.take(recentLimit).toList(),
              categories: {for (final c in data.$2) c.id: c},
              upcomingPayments: _upcoming(data.$3, now),
            );
          },
        );
  }

  List<UpcomingPayment> _upcoming(List<CardEntity> cards, DateTime now) {
    final payments = [
      for (final card in cards)
        UpcomingPayment(
          card: card,
          dueDate: card.nextPaymentDate(now),
          daysLeft: card.daysUntilPayment(now),
        ),
    ]..sort((a, b) => a.daysLeft.compareTo(b.daysLeft));
    return payments.take(upcomingLimit).toList();
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
