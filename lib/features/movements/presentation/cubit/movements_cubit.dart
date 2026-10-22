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
import 'package:dynora_finance/features/debts/domain/entities/debt_entity.dart';
import 'package:dynora_finance/features/debts/domain/entities/movement_debts.dart';
import 'package:dynora_finance/features/debts/domain/usecases/watch_debts.dart';
import 'package:dynora_finance/features/loans/domain/entities/loan_entity.dart';
import 'package:dynora_finance/features/loans/domain/entities/loan_payment_entity.dart';
import 'package:dynora_finance/features/loans/domain/usecases/loan_usecases.dart';
import 'package:dynora_finance/features/movements/domain/entities/month_ledger.dart';
import 'package:dynora_finance/features/movements/domain/entities/movement_entity.dart';
import 'package:dynora_finance/features/movements/domain/entities/movement_filter.dart';
import 'package:dynora_finance/features/movements/domain/usecases/watch_movements.dart';
import 'package:dynora_finance/shared/bloc/view_status.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:rxdart/rxdart.dart';

/// Which movements the list shows.
enum MovementTypeFilter { all, expenses, incomes }

/// A block of the monthly list: a day or a card statement.
sealed class MovementListGroup extends Equatable {
  const MovementListGroup();

  /// Date used to order the blocks (newest first).
  DateTime get sortDate;
}

/// Cash, transfer and debit movements of one day.
class MovementDayGroup extends MovementListGroup {
  const MovementDayGroup({required this.day, required this.movements});

  final DateTime day;
  final List<MovementEntity> movements;

  @override
  DateTime get sortDate => day;

  /// What came in minus what went out that day (withdrawals count as in).
  double get net => movements.fold(
    0,
    (sum, m) =>
        m.isExpense && !m.isCashWithdrawal ? sum - m.amount : sum + m.amount,
  );

  @override
  List<Object?> get props => [day, movements];
}

/// Charges of a credit card statement paid this month.
class MovementStatementGroup extends MovementListGroup {
  const MovementStatementGroup({
    required this.card,
    required this.statement,
    required this.charges,
  });

  final CardEntity card;

  /// Whole statement (its total and status don't depend on filters).
  final CardStatement statement;

  /// Charges shown, after filters.
  final List<StatementCharge> charges;

  @override
  DateTime get sortDate => statement.period.paymentDate;

  @override
  List<Object?> get props => [card, statement, charges];
}

/// Loan installments due this month, to pay or to collect.
class MovementLoanGroup extends MovementListGroup {
  const MovementLoanGroup({required this.installments});

  /// Latest due date first.
  final List<LedgerLoanInstallment> installments;

  @override
  DateTime get sortDate => installments.first.dueDate;

  /// Collections minus payments.
  double get net => installments.fold(
    0,
    (sum, l) => l.isIncome ? sum + l.amount : sum - l.amount,
  );

  @override
  List<Object?> get props => [installments];
}

class MovementsState extends Equatable {
  MovementsState({
    required this.month,
    this.status = ViewStatus.loading,
    MonthLedger? ledger,
    this.categories = const {},
    this.cards = const {},
    this.debts = const {},
    this.typeFilter = MovementTypeFilter.all,
    this.query = '',
    this.error,
  }) : ledger = ledger ?? MonthLedger.empty;

  final MonthRange month;
  final ViewStatus status;

  /// What belongs to [month] by payment method (see [MonthLedger]).
  final MonthLedger ledger;
  final Map<String, CategoryEntity> categories;
  final Map<String, CardEntity> cards;

  /// Movement id → what others owe you for it.
  final Map<String, MovementDebts> debts;
  final MovementTypeFilter typeFilter;

  /// Text searched in titles, notes, categories and cards.
  final String query;
  final String? error;

  bool get isFiltered =>
      typeFilter != MovementTypeFilter.all || query.trim().isNotEmpty;

  /// Days and card statements matching the filters, newest first.
  List<MovementListGroup> get groups {
    final byDay = <DateTime, List<MovementEntity>>{};
    for (final movement in ledger.direct.where(_matches)) {
      final day = DateTime(
        movement.date.year,
        movement.date.month,
        movement.date.day,
      );
      byDay.putIfAbsent(day, () => []).add(movement);
    }

    final statements = <MovementStatementGroup>[];
    if (typeFilter != MovementTypeFilter.incomes) {
      for (final entry in ledger.statements) {
        final charges = [
          for (final c in entry.statement.charges)
            if (_matchesText(c.movement)) c,
        ];
        if (charges.isEmpty) continue;
        statements.add(
          MovementStatementGroup(
            card: entry.card,
            statement: entry.statement,
            charges: charges,
          ),
        );
      }
    }

    final loans = [
      for (final l in ledger.loanInstallments)
        if (_matchesLoan(l)) l,
    ];

    return <MovementListGroup>[
      for (final entry in byDay.entries)
        MovementDayGroup(day: entry.key, movements: entry.value),
      ...statements,
      if (loans.isNotEmpty) MovementLoanGroup(installments: loans),
    ]..sort((a, b) => b.sortDate.compareTo(a.sortDate));
  }

  bool _matches(MovementEntity movement) {
    final isOut = movement.isExpense && !movement.isCashWithdrawal;
    final typeOk = switch (typeFilter) {
      MovementTypeFilter.all => true,
      MovementTypeFilter.expenses => isOut,
      MovementTypeFilter.incomes => !isOut,
    };
    return typeOk && _matchesText(movement);
  }

  bool _matchesLoan(LedgerLoanInstallment installment) {
    final typeOk = switch (typeFilter) {
      MovementTypeFilter.all => true,
      MovementTypeFilter.expenses => !installment.isIncome,
      MovementTypeFilter.incomes => installment.isIncome,
    };
    return typeOk &&
        _containsQuery([
          installment.loan.name,
          installment.loan.note ?? '',
          'Préstamo',
        ]);
  }

  bool _matchesText(MovementEntity movement) => _containsQuery([
    movement.title,
    movement.note ?? '',
    movement.isCashWithdrawal
        ? 'Disposición de efectivo'
        : categories[movement.categoryId]?.name ?? '',
    cards[movement.cardId]?.name ?? '',
  ]);

  bool _containsQuery(List<String> fields) {
    final text = _normalize(query);
    if (text.isEmpty) return true;
    return _normalize(fields.join(' ')).contains(text);
  }

  /// Lowercase without accents, so "nomina" finds "Nómina".
  static String _normalize(String value) {
    const from = 'áéíóúüñ';
    const to = 'aeiouun';
    final buffer = StringBuffer();
    for (final char in value.trim().toLowerCase().split('')) {
      final index = from.indexOf(char);
      buffer.write(index >= 0 ? to[index] : char);
    }
    return buffer.toString();
  }

  MovementsState copyWith({
    MonthRange? month,
    ViewStatus? status,
    MonthLedger? ledger,
    MovementTypeFilter? typeFilter,
    String? query,
  }) {
    return MovementsState(
      month: month ?? this.month,
      status: status ?? this.status,
      ledger: ledger ?? this.ledger,
      categories: categories,
      cards: cards,
      debts: debts,
      typeFilter: typeFilter ?? this.typeFilter,
      query: query ?? this.query,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
    month,
    status,
    ledger,
    categories,
    cards,
    debts,
    typeFilter,
    query,
    error,
  ];
}

class MovementsCubit extends Cubit<MovementsState> {
  MovementsCubit({
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
       super(MovementsState(month: MonthRange(DateTime.now())));

  final WatchMovements _watchMovements;
  final WatchCategories _watchCategories;
  final WatchCards _watchCards;
  final WatchCardPayments _watchCardPayments;
  final WatchDebts _watchDebts;
  final WatchLoans _watchLoans;
  final WatchLoanPayments _watchLoanPayments;
  late final BehaviorSubject<MonthRange> _month = BehaviorSubject.seeded(
    state.month,
  );
  StreamSubscription<MovementsState>? _subscription;

  void start() {
    // All movements: installments of older purchases land in later months.
    final data = Rx.combineLatest5(
      _watchMovements(MovementFilter.all),
      _watchCategories(null),
      _watchCards(const NoParams()),
      _watchCardPayments(const NoParams()),
      _watchDebts(const NoParams()),
      (movements, categories, cards, payments, debts) =>
          (movements, categories, cards, payments, debts),
    );
    final loans = Rx.combineLatest2(
      _watchLoans(const NoParams()),
      _watchLoanPayments(const NoParams()),
      (loans, payments) => (loans, payments),
    );
    _subscription = Rx.combineLatest3(
      _month,
      data,
      loans,
      (month, d, l) =>
          _buildState(month, d.$1, d.$2, d.$3, d.$4, d.$5, l.$1, l.$2),
    ).listen(emit);
  }

  void previousMonth() => _changeMonth(state.month.previous);

  void nextMonth() => _changeMonth(state.month.next);

  void currentMonth() => _changeMonth(MonthRange(DateTime.now()));

  void changeTypeFilter(MovementTypeFilter filter) =>
      emit(state.copyWith(typeFilter: filter));

  void search(String query) => emit(state.copyWith(query: query));

  void _changeMonth(MonthRange month) {
    if (month == state.month) return;
    _month.add(month);
  }

  MovementsState _buildState(
    MonthRange month,
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
          (failure) => MovementsState(
            month: month,
            status: ViewStatus.failure,
            typeFilter: state.typeFilter,
            query: state.query,
            error: failure.message,
          ),
          (data) => MovementsState(
            month: month,
            status: ViewStatus.loaded,
            ledger: MonthLedger.build(
              month: month,
              movements: data.$1,
              cards: data.$3,
              cardPayments: data.$4,
              loans: data.$6,
              loanPayments: data.$7,
            ),
            categories: {for (final c in data.$2) c.id: c},
            cards: {for (final k in data.$3) k.id: k},
            debts: MovementDebts.byMovement(data.$5),
            typeFilter: state.typeFilter,
            query: state.query,
          ),
        );
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    await _month.close();
    return super.close();
  }
}
