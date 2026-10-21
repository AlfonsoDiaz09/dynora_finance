import 'dart:async';

import 'package:dynora_finance/core/error/failures.dart';
import 'package:dynora_finance/core/usecase/usecase.dart';
import 'package:dynora_finance/core/utils/month_range.dart';
import 'package:dynora_finance/features/cards/domain/entities/card_entity.dart';
import 'package:dynora_finance/features/cards/domain/entities/card_payment_entity.dart';
import 'package:dynora_finance/features/cards/domain/entities/card_statement.dart';
import 'package:dynora_finance/features/cards/domain/usecases/watch_card_payments.dart';
import 'package:dynora_finance/features/cards/domain/usecases/watch_cards.dart';
import 'package:dynora_finance/features/categories/domain/entities/category_entity.dart';
import 'package:dynora_finance/features/categories/domain/usecases/watch_categories.dart';
import 'package:dynora_finance/features/movements/domain/entities/movement_entity.dart';
import 'package:dynora_finance/features/movements/domain/entities/movement_filter.dart';
import 'package:dynora_finance/features/home/domain/entities/cash_flow.dart';
import 'package:dynora_finance/features/movements/domain/usecases/watch_movements.dart';
import 'package:dynora_finance/shared/bloc/view_status.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:rxdart/rxdart.dart';

class HomeState extends Equatable {
  const HomeState({
    this.status = ViewStatus.loading,
    this.balance = 0,
    this.monthCashFlow = CashFlow.empty,
    this.recentMovements = const [],
    this.categories = const {},
    this.upcomingPayments = const [],
    this.error,
  });

  final ViewStatus status;

  /// All-time cash balance (see [CashFlow]).
  final double balance;

  /// Cash in and out during the current month.
  final CashFlow monthCashFlow;
  final List<MovementEntity> recentMovements;
  final Map<String, CategoryEntity> categories;

  /// Unpaid card statements with something to pay, overdue first.
  final List<UpcomingCardPayment> upcomingPayments;
  final String? error;

  @override
  List<Object?> get props => [
    status,
    balance,
    monthCashFlow.income,
    monthCashFlow.expense,
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
    required WatchCardPayments watchCardPayments,
  }) : _watchMovements = watchMovements,
       _watchCategories = watchCategories,
       _watchCards = watchCards,
       _watchCardPayments = watchCardPayments,
       super(const HomeState());

  static const int recentLimit = 5;

  final WatchMovements _watchMovements;
  final WatchCategories _watchCategories;
  final WatchCards _watchCards;
  final WatchCardPayments _watchCardPayments;
  StreamSubscription<HomeState>? _subscription;

  void start() {
    _subscription = Rx.combineLatest4(
      _watchMovements(MovementFilter.all),
      _watchCategories(null),
      _watchCards(const NoParams()),
      _watchCardPayments(const NoParams()),
      _buildState,
    ).listen(emit);
  }

  HomeState _buildState(
    Either<Failure, List<MovementEntity>> movements,
    Either<Failure, List<CategoryEntity>> categories,
    Either<Failure, List<CardEntity>> cards,
    Either<Failure, List<CardPaymentEntity>> payments,
  ) {
    return movements
        .flatMap(
          (m) => categories.flatMap(
            (c) => cards.flatMap((k) => payments.map((p) => (m, c, k, p))),
          ),
        )
        .match(
          (failure) =>
              HomeState(status: ViewStatus.failure, error: failure.message),
          (data) {
            final now = DateTime.now();
            final month = MonthRange(now);

            return HomeState(
              status: ViewStatus.loaded,
              balance: CashFlow.of(
                movements: data.$1,
                cards: data.$3,
                payments: data.$4,
              ).balance,
              monthCashFlow: CashFlow.of(
                movements: data.$1,
                cards: data.$3,
                payments: data.$4,
                month: month,
              ),
              recentMovements: data.$1.take(recentLimit).toList(),
              categories: {for (final c in data.$2) c.id: c},
              upcomingPayments: UpcomingCardPayment.pending(
                data.$3,
                data.$1,
                data.$4,
                now,
              ),
            );
          },
        );
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
