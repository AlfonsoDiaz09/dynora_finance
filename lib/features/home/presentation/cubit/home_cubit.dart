import 'dart:async';

import 'package:dynora_finance/core/error/failures.dart';
import 'package:dynora_finance/core/usecase/usecase.dart';
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
import 'package:dynora_finance/features/home/domain/entities/spending_overview.dart';
import 'package:dynora_finance/features/loans/domain/entities/loan_entity.dart';
import 'package:dynora_finance/features/loans/domain/entities/loan_payment_entity.dart';
import 'package:dynora_finance/features/loans/domain/entities/loan_summary.dart';
import 'package:dynora_finance/features/loans/domain/usecases/loan_usecases.dart';
import 'package:dynora_finance/features/movements/domain/usecases/watch_movements.dart';
import 'package:dynora_finance/shared/bloc/view_status.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:rxdart/rxdart.dart';

class HomeState extends Equatable {
  const HomeState({
    this.status = ViewStatus.loading,
    this.overview = SpendingOverview.empty,
    this.recentMovements = const [],
    this.categories = const {},
    this.upcomingPayments = const [],
    this.debtsPending = 0,
    this.debtorsCount = 0,
    this.hasDebts = false,
    this.loans = const [],
    this.error,
  });

  final ViewStatus status;

  /// Money available to spend, card debt deducted as it is incurred.
  final SpendingOverview overview;
  final List<MovementEntity> recentMovements;
  final Map<String, CategoryEntity> categories;

  /// Unpaid card statements with something to pay, overdue first.
  final List<UpcomingCardPayment> upcomingPayments;

  /// What people still owe you and how many of them.
  final double debtsPending;
  final int debtorsCount;

  /// Any debt was ever registered (pending or paid).
  final bool hasDebts;

  /// Summaries of your loans, most urgent first.
  final List<LoanSummary> loans;
  final String? error;

  @override
  List<Object?> get props => [
    status,
    overview.available,
    overview.cash,
    overview.cardDebt,
    overview.futureInstallments,
    overview.monthIncome,
    overview.monthExpense,
    recentMovements,
    categories,
    upcomingPayments,
    debtsPending,
    debtorsCount,
    hasDebts,
    loans,
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
    required WatchLoans watchLoans,
    required WatchLoanPayments watchLoanPayments,
  }) : _watchMovements = watchMovements,
       _watchCategories = watchCategories,
       _watchCards = watchCards,
       _watchCardPayments = watchCardPayments,
       _watchDebts = watchDebts,
       _watchLoans = watchLoans,
       _watchLoanPayments = watchLoanPayments,
       super(const HomeState());

  static const int recentLimit = 5;

  final WatchMovements _watchMovements;
  final WatchCategories _watchCategories;
  final WatchCards _watchCards;
  final WatchCardPayments _watchCardPayments;
  final WatchDebts _watchDebts;
  final WatchLoans _watchLoans;
  final WatchLoanPayments _watchLoanPayments;
  StreamSubscription<HomeState>? _subscription;

  void start() {
    _subscription = Rx.combineLatest7(
      _watchMovements(MovementFilter.all),
      _watchCategories(null),
      _watchCards(const NoParams()),
      _watchCardPayments(const NoParams()),
      _watchDebts(const NoParams()),
      _watchLoans(const NoParams()),
      _watchLoanPayments(const NoParams()),
      _buildState,
    ).listen(emit);
  }

  HomeState _buildState(
    Either<Failure, List<MovementEntity>> movements,
    Either<Failure, List<CategoryEntity>> categories,
    Either<Failure, List<CardEntity>> cards,
    Either<Failure, List<CardPaymentEntity>> payments,
    Either<Failure, List<DebtEntity>> debts,
    Either<Failure, List<LoanEntity>> loans,
    Either<Failure, List<LoanPaymentEntity>> loanPayments,
  ) {
    return movements
        .flatMap(
          (m) => categories.flatMap(
            (c) => cards.flatMap(
              (k) => payments.flatMap(
                (p) => debts.flatMap(
                  (d) => loans.flatMap(
                    (l) => loanPayments.map((lp) => (m, c, k, p, d, l, lp)),
                  ),
                ),
              ),
            ),
          ),
        )
        .match(
          (failure) =>
              HomeState(status: ViewStatus.failure, error: failure.message),
          (data) {
            final now = DateTime.now();

            return HomeState(
              status: ViewStatus.loaded,
              overview: SpendingOverview.of(
                movements: data.$1,
                cards: data.$3,
                cardPayments: data.$4,
                debts: data.$5,
                loans: data.$6,
                loanPayments: data.$7,
                now: now,
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
              loans: [
                for (final loan in data.$6) LoanSummary.of(loan, data.$7, now),
              ]..sort((a, b) => b.overdueAmount.compareTo(a.overdueAmount)),
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
