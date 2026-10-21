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
import 'package:dynora_finance/features/debts/domain/entities/debt_entity.dart';
import 'package:dynora_finance/features/debts/domain/usecases/watch_debts.dart';
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
    this.debtsPending = 0,
    this.debtorsCount = 0,
    this.hasDebts = false,
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

  /// What people still owe you and how many of them.
  final double debtsPending;
  final int debtorsCount;

  /// Any debt was ever registered (pending or paid).
  final bool hasDebts;
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
    debtsPending,
    debtorsCount,
    hasDebts,
    error,
  ];
}

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({
    required WatchMovements watchMovements,
    required WatchCategories watchCategories,
    required WatchCards watchCards,
    required WatchCardPayments watchCardPayments,
    required WatchDebts watchDebts,
  }) : _watchMovements = watchMovements,
       _watchCategories = watchCategories,
       _watchCards = watchCards,
       _watchCardPayments = watchCardPayments,
       _watchDebts = watchDebts,
       super(const HomeState());

  static const int recentLimit = 5;

  final WatchMovements _watchMovements;
  final WatchCategories _watchCategories;
  final WatchCards _watchCards;
  final WatchCardPayments _watchCardPayments;
  final WatchDebts _watchDebts;
  StreamSubscription<HomeState>? _subscription;

  void start() {
    _subscription = Rx.combineLatest5(
      _watchMovements(MovementFilter.all),
      _watchCategories(null),
      _watchCards(const NoParams()),
      _watchCardPayments(const NoParams()),
      _watchDebts(const NoParams()),
      _buildState,
    ).listen(emit);
  }

  HomeState _buildState(
    Either<Failure, List<MovementEntity>> movements,
    Either<Failure, List<CategoryEntity>> categories,
    Either<Failure, List<CardEntity>> cards,
    Either<Failure, List<CardPaymentEntity>> payments,
    Either<Failure, List<DebtEntity>> debts,
  ) {
    return movements
        .flatMap(
          (m) => categories.flatMap(
            (c) => cards.flatMap(
              (k) => payments.flatMap((p) => debts.map((d) => (m, c, k, p, d))),
            ),
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
                debts: data.$5,
              ).balance,
              monthCashFlow: CashFlow.of(
                movements: data.$1,
                cards: data.$3,
                payments: data.$4,
                debts: data.$5,
                month: month,
              ),
              recentMovements: data.$1.take(recentLimit).toList(),
              categories: {for (final c in data.$2) c.id: c},
              debtsPending: [
                for (final d in data.$5)
                  if (!d.isPaid) d.amount,
              ].fold(0, (sum, a) => sum + a),
              debtorsCount: {
                for (final d in data.$5)
                  if (!d.isPaid) d.personId,
              }.length,
              hasDebts: data.$5.isNotEmpty,
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
