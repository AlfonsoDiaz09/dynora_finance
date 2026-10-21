import 'package:dynora_finance/features/stats/presentation/cubit/stats_cubit.dart';
import 'package:dynora_finance/init_dependencies.dart';
import 'package:dynora_finance/shared/bloc/view_status.dart';
import 'package:dynora_finance/shared/utils/formatters.dart';
import 'package:dynora_finance/shared/widgets/empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'widgets/month_selector.dart';
import 'widgets/statistics_summary_card.dart';
import 'widgets/category_chart.dart';
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
            padding: EdgeInsets.only(
              left: 20.w,
              right: 20.w,
              top: 20.h,
              bottom: 40.h,
            ),
            children: [
              MonthSelector(
                label: Formatters.monthYear(state.month.start),
                onPrevious: cubit.previousMonth,
                onNext: cubit.nextMonth,
              ),
              SizedBox(height: 20.h),
              if (state.status == ViewStatus.failure)
                EmptyState(
                  icon: Icons.error_outline_rounded,
                  message:
                      state.error ?? 'No se pudieron cargar las estadísticas',
                )
              else ...[
                StatisticsSummaryCard(
                  income: state.summary.income,
                  expense: state.summary.expense,
                  balance: state.summary.balance,
                ),
                SizedBox(height: 30.h),
                CategoryChart(items: state.categoryExpenses),
                SizedBox(height: 30.h),
                TrendSection(trend: state.expenseTrend),
              ],
            ],
          );
        },
      ),
    );
  }
}
