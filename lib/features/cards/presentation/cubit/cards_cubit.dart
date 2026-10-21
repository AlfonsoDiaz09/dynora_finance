import 'dart:async';

import 'package:dynora_finance/core/enums/movement_type.dart';
import 'package:dynora_finance/core/error/failures.dart';
import 'package:dynora_finance/core/usecase/usecase.dart';
import 'package:dynora_finance/core/utils/month_range.dart';
import 'package:dynora_finance/features/cards/domain/entities/card_entity.dart';
import 'package:dynora_finance/features/cards/domain/entities/card_statement.dart';
import 'package:dynora_finance/features/cards/domain/usecases/watch_cards.dart';
import 'package:dynora_finance/features/movements/domain/entities/movement_entity.dart';
import 'package:dynora_finance/features/movements/domain/entities/movement_filter.dart';
import 'package:dynora_finance/features/movements/domain/entities/movement_summary.dart';
import 'package:dynora_finance/features/movements/domain/usecases/watch_movements.dart';
import 'package:dynora_finance/shared/bloc/view_status.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:rxdart/rxdart.dart';

class CardOverview extends Equatable {
  const CardOverview({
    required this.card,
    this.upcoming,
    this.monthExpense = 0,
  });

  final CardEntity card;

  /// Next statement to pay, `null` for cards without billing cycle.
  final CardStatement? upcoming;

  /// Expenses of the current month (used for debit cards).
  final double monthExpense;

  @override
  List<Object?> get props => [card, upcoming, monthExpense];
}

/// Card payments funded with the salary of [month].
class MonthlyCardPlan extends Equatable {
  const MonthlyCardPlan({
    required this.month,
    required this.income,
    required this.payments,
  });

  final MonthRange month;

  /// Income registered in [month].
  final double income;
  final List<UpcomingCardPayment> payments;

  double get totalPayments => payments.fold(0, (sum, p) => sum + p.amount);

  double get remaining => income - totalPayments;

  @override
  List<Object?> get props => [month, income, payments];
}

class CardsState extends Equatable {
  const CardsState({
    this.status = ViewStatus.loading,
    this.cards = const [],
    this.plan,
    this.error,
  });

  final ViewStatus status;
  final List<CardOverview> cards;
  final MonthlyCardPlan? plan;
  final String? error;

  @override
  List<Object?> get props => [status, cards, plan, error];
}

class CardsCubit extends Cubit<CardsState> {
  CardsCubit({
    required WatchCards watchCards,
    required WatchMovements watchMovements,
  }) : _watchCards = watchCards,
       _watchMovements = watchMovements,
       super(const CardsState());

  final WatchCards _watchCards;
  final WatchMovements _watchMovements;
  StreamSubscription<CardsState>? _subscription;

  void start() {
    _subscription = Rx.combineLatest2(
      _watchCards(const NoParams()),
      _watchMovements(MovementFilter.all),
      _buildState,
    ).listen(emit);
  }

  CardsState _buildState(
    Either<Failure, List<CardEntity>> cards,
    Either<Failure, List<MovementEntity>> movements,
  ) {
    return cards.flatMap((c) => movements.map((m) => (c, m))).match(
      (failure) =>
          CardsState(status: ViewStatus.failure, error: failure.message),
      (data) {
        final now = DateTime.now();
        final month = MonthRange(now);
        final monthMovements = data.$2.where((m) => month.contains(m.date));

        return CardsState(
          status: ViewStatus.loaded,
          cards: [
            for (final card in data.$1)
              CardOverview(
                card: card,
                upcoming: card.hasBillingCycle
                    ? CardStatement.upcoming(card, data.$2, now)
                    : null,
                monthExpense: monthMovements
                    .where(
                      (m) =>
                          m.cardId == card.id && m.type == MovementType.expense,
                    )
                    .fold(0, (sum, m) => sum + m.amount),
              ),
          ],
          plan: MonthlyCardPlan(
            month: month,
            income: MovementSummary.of(monthMovements).income,
            payments: _paymentsFundedIn(month, data.$1, data.$2),
          ),
        );
      },
    );
  }

  /// Statements of every card whose payment is funded with [month]'s salary.
  List<UpcomingCardPayment> _paymentsFundedIn(
    MonthRange month,
    List<CardEntity> cards,
    List<MovementEntity> movements,
  ) {
    return [
      for (final card in cards)
        if (card.hasBillingCycle)
          for (final statement in CardStatement.fundedIn(
            card,
            movements,
            month,
          ))
            UpcomingCardPayment(card: card, statement: statement),
    ]..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
