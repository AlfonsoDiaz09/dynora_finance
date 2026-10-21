import 'package:dynora_finance/features/stats/presentation/cubit/stats_cubit.dart';
import 'package:dynora_finance/init_dependencies.dart';
import 'package:dynora_finance/shared/bloc/view_status.dart';
import 'package:dynora_finance/shared/widgets/empty_state.dart';
import 'package:dynora_finance/shared/widgets/month_switcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'widgets/category_chart.dart';
import 'widgets/statistics_summary_card.dart';
import 'widgets/trend_section.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => serviceLocator<StatsCubit>()..start(),
      child: BlocBuilder<StatsCubit, StatsState>(
        builder: (context, state) {
          final cubit = context.read<StatsCubit>();

          return ListView(
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 110.h),
            children: [
              MonthSwitcher(
                month: state.month.start,
                onPrevious: cubit.previousMonth,
                onNext: cubit.nextMonth,
                onToday: cubit.currentMonth,
              ),
              SizedBox(height: 16.h),
              ...switch (state.status) {
                ViewStatus.loading => [
                  Padding(
                    padding: EdgeInsets.only(top: 40.h),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                ],
                ViewStatus.failure => [
                  EmptyState(
                    icon: Icons.error_outline_rounded,
                    message:
                        state.error ?? 'No se pudieron cargar las estadísticas',
                  ),
                ],
                ViewStatus.loaded => [
                  StatisticsSummaryCard(
                    income: state.summary.income,
                    expense: state.summary.expense,
                    savingsRate: state.savingsRate,
                  ),
                  SizedBox(height: 16.h),
                  CategoryChart(
                    items: state.categoryExpenses,
                    total: state.summary.expense,
                  ),
                  SizedBox(height: 16.h),
                  TrendSection(
                    expense: state.summary.expense,
                    previousExpense: state.previousExpense,
                    trend: state.expenseTrend,
                    dailyAverage: state.dailyAverage(DateTime.now()),
                  ),
                ],
              },
            ],
          );
        },
      ),
    );
  }
}
