import 'dart:async';

import 'package:dynora_finance/core/error/failures.dart';
import 'package:dynora_finance/core/usecase/usecase.dart';
import 'package:dynora_finance/core/utils/month_range.dart';
import 'package:dynora_finance/features/loans/domain/entities/loan_entity.dart';
import 'package:dynora_finance/features/loans/domain/entities/loan_payment_entity.dart';
import 'package:dynora_finance/features/loans/domain/entities/loan_summary.dart';
import 'package:dynora_finance/features/loans/domain/usecases/loan_usecases.dart';
import 'package:dynora_finance/shared/bloc/view_status.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:rxdart/rxdart.dart';

class LoansState extends Equatable {
  const LoansState({
    this.status = ViewStatus.loading,
    this.loans = const [],
    this.error,
  });

  final ViewStatus status;

  /// Active loans first (overdue, then by next due date), settled last.
  final List<LoanSummary> loans;
  final String? error;

  List<LoanSummary> get active => [
    for (final l in loans)
      if (!l.isSettled) l,
  ];

  List<LoanSummary> get settled => [
    for (final l in loans)
      if (l.isSettled) l,
  ];

  double get totalRemaining => loans.fold(0, (sum, l) => sum + l.remaining);

  double get overdueAmount => loans.fold(0, (sum, l) => sum + l.overdueAmount);

  /// Unpaid part of the installments due this month.
  double dueThisMonth(DateTime now) {
    final month = MonthRange(now);
    return loans.fold(
      0,
      (sum, l) =>
          sum +
          l.installments
              .where((i) => month.contains(i.installment.dueDate))
              .fold<double>(0, (s, i) => s + i.missing),
    );
  }

  @override
  List<Object?> get props => [status, loans, error];
}

class LoansCubit extends Cubit<LoansState> {
  LoansCubit({
    required WatchLoans watchLoans,
    required WatchLoanPayments watchLoanPayments,
  }) : _watchLoans = watchLoans,
       _watchLoanPayments = watchLoanPayments,
       super(const LoansState());

  final WatchLoans _watchLoans;
  final WatchLoanPayments _watchLoanPayments;
  StreamSubscription<LoansState>? _subscription;

  void start() {
    _subscription = Rx.combineLatest2(
      _watchLoans(const NoParams()),
      _watchLoanPayments(const NoParams()),
      _buildState,
    ).listen(emit);
  }

  LoansState _buildState(
    Either<Failure, List<LoanEntity>> loans,
    Either<Failure, List<LoanPaymentEntity>> payments,
  ) {
    return loans.flatMap((l) => payments.map((p) => (l, p))).match(
      (failure) =>
          LoansState(status: ViewStatus.failure, error: failure.message),
      (data) {
        final now = DateTime.now();
        final summaries = [
          for (final loan in data.$1) LoanSummary.of(loan, data.$2, now),
        ]..sort(_byUrgency);
        return LoansState(status: ViewStatus.loaded, loans: summaries);
      },
    );
  }

  static int _byUrgency(LoanSummary a, LoanSummary b) {
    if (a.isSettled != b.isSettled) return a.isSettled ? 1 : -1;
    if ((a.overdueAmount > 0) != (b.overdueAmount > 0)) {
      return a.overdueAmount > 0 ? -1 : 1;
    }
    final dueA = a.nextInstallment?.installment.dueDate;
    final dueB = b.nextInstallment?.installment.dueDate;
    if (dueA != null && dueB != null) return dueA.compareTo(dueB);
    if (dueA != null) return -1;
    if (dueB != null) return 1;
    return a.loan.startDate.compareTo(b.loan.startDate);
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}

class LoanDetailState extends Equatable {
  const LoanDetailState({this.status = ViewStatus.loading, this.summary});

  final ViewStatus status;

  /// `null` once loaded means the loan was deleted.
  final LoanSummary? summary;

  @override
  List<Object?> get props => [status, summary];
}

class LoanDetailCubit extends Cubit<LoanDetailState> {
  LoanDetailCubit({
    required this.loanId,
    required WatchLoans watchLoans,
    required WatchLoanPayments watchLoanPayments,
  }) : _watchLoans = watchLoans,
       _watchLoanPayments = watchLoanPayments,
       super(const LoanDetailState());

  final String loanId;
  final WatchLoans _watchLoans;
  final WatchLoanPayments _watchLoanPayments;
  StreamSubscription<LoanDetailState>? _subscription;

  void start() {
    _subscription = Rx.combineLatest2(
      _watchLoans(const NoParams()),
      _watchLoanPayments(const NoParams()),
      (
        Either<Failure, List<LoanEntity>> loans,
        Either<Failure, List<LoanPaymentEntity>> payments,
      ) => loans.flatMap((l) => payments.map((p) => (l, p))).match(
        (_) => const LoanDetailState(status: ViewStatus.failure),
        (data) {
          final loan = data.$1.where((l) => l.id == loanId).firstOrNull;
          return LoanDetailState(
            status: ViewStatus.loaded,
            summary: loan == null
                ? null
                : LoanSummary.of(loan, data.$2, DateTime.now()),
          );
        },
      ),
    ).listen(emit);
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
