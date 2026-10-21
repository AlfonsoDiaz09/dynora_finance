import 'package:dynora_finance/app/bloc/navigation_cubit/navigation_cubit.dart';
import 'package:dynora_finance/core/enums/movement_type.dart';
import 'package:dynora_finance/app/router/router.dart';
import 'package:dynora_finance/app/theme/app_colors.dart';
import 'package:dynora_finance/shared/utils/formatters.dart';
import 'package:dynora_finance/features/home/presentation/cubit/home_cubit.dart';
import 'package:dynora_finance/features/loans/domain/entities/loan_entity.dart';
import 'package:dynora_finance/features/loans/presentation/utils/loan_labels.dart';
import 'package:dynora_finance/features/movements/presentation/widgets/movement_form_sheet.dart';
import 'package:dynora_finance/init_dependencies.dart';
import 'package:dynora_finance/shared/bloc/view_status.dart';
import 'package:dynora_finance/shared/widgets/empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'widgets/financial_summary_card.dart';
import 'widgets/debts_summary_card.dart';
import 'widgets/loans_summary_card.dart';
import 'widgets/upcoming_payments_section.dart';
import 'widgets/recent_movements_section.dart';
import 'widgets/quick_actions_section.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  /// Branch index of the stats tab in the bottom navigation.
  static const int _statsBranch = 1;

  /// Préstamos card while some loan is not paid off.
  /// Loans card of [direction] while some loan of it is not settled.
  Widget? _loansCard(
    BuildContext context,
    HomeState state,
    LoanDirection direction,
  ) {
    final active = [
      for (final l in state.loans)
        if (!l.isSettled && l.loan.direction == direction) l,
    ];
    if (active.isEmpty) return null;

    final overdue = active.fold<double>(0, (sum, l) => sum + l.overdueAmount);
    final nextDue = [
      for (final l in active)
        if (l.nextInstallment case final next?) next,
    ]..sort((a, b) => a.installment.dueDate.compareTo(b.installment.dueDate));

    final (String status, Color color) = overdue > 0
        ? ('Vencido ${Formatters.currency(overdue)}', AppColors.error)
        : nextDue.isNotEmpty
        ? (
            '${direction.nextPayment} '
                '${Formatters.shortDate(nextDue.first.installment.dueDate)} · '
                '${Formatters.currency(nextDue.first.missing)}',
            AppColors.warning,
          )
        : ('Sin pagos fijos', AppColors.textPrimary70);

    final lent = direction == LoanDirection.lent;
    return LoansSummaryCard(
      title: lent ? 'Préstamos que hiciste' : 'Préstamos que debes',
      amountLabel: lent ? 'te deben' : 'debes',
      remaining: active.fold(0, (sum, l) => sum + l.remaining),
      status: status,
      statusColor: color,
      onTap: () => context.push(lent ? AppRoutes.lentLoans : AppRoutes.loans),
    );
  }

  void _openStats(BuildContext context) {
    context.read<NavigationCubit>().changeIndex(_statsBranch);
    StatefulNavigationShell.of(context).goBranch(_statsBranch);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => serviceLocator<HomeCubit>()..start(),
      child: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          if (state.status == ViewStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10.h),
                if (state.status == ViewStatus.failure) ...[
                  EmptyState(
                    icon: Icons.error_outline_rounded,
                    message: state.error ?? 'No se pudo cargar tu resumen',
                  ),
                  SizedBox(height: 28.h),
                ],
                FinancialSummaryCard(
                  balance: state.balance,
                  monthIncome: state.monthCashFlow.income,
                  monthExpense: state.monthCashFlow.expense,
                ),
                SizedBox(height: 28.h),
                UpcomingPaymentsSection(
                  payments: state.upcomingPayments,
                  onSeeCards: () => context.push(AppRoutes.cards),
                  onCardTap: (card) =>
                      context.push(AppRoutes.cardDetailPath(card.id)),
                ),
                if (state.hasDebts) ...[
                  SizedBox(height: 20.h),
                  DebtsSummaryCard(
                    total: state.debtsPending,
                    people: state.debtorsCount,
                    onTap: () => context.push(AppRoutes.debts),
                  ),
                ],
                for (final direction in LoanDirection.values)
                  if (_loansCard(context, state, direction)
                      case final card?) ...[
                    SizedBox(height: 20.h),
                    card,
                  ],
                SizedBox(height: 28.h),
                RecentMovementsSection(
                  movements: state.recentMovements,
                  onMovementTap: (movement) =>
                      MovementFormSheet.show(context, movement: movement),
                ),
                SizedBox(height: 28.h),
                QuickActionsSection(
                  onAddExpense: () => MovementFormSheet.show(context),
                  onAddIncome: () => MovementFormSheet.show(
                    context,
                    initialType: MovementType.income,
                  ),
                  onCards: () => context.push(AppRoutes.cards),
                  onDebts: () => context.push(AppRoutes.debts),
                  onLoans: () => context.push(AppRoutes.loans),
                  onStats: () => _openStats(context),
                ),
                SizedBox(height: 50.h),
              ],
            ),
          );
        },
      ),
    );
  }
}
