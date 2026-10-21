import 'package:dynora_finance/app/router/router.dart';
import 'package:dynora_finance/app/theme/app_colors.dart';
import 'package:dynora_finance/features/loans/domain/entities/loan_entity.dart';
import 'package:dynora_finance/features/loans/domain/entities/loan_summary.dart';
import 'package:dynora_finance/features/loans/presentation/cubit/loans_cubit.dart';
import 'package:dynora_finance/features/loans/presentation/utils/loan_labels.dart';
import 'package:dynora_finance/features/loans/presentation/widgets/loan_form_sheet.dart';
import 'package:dynora_finance/init_dependencies.dart';
import 'package:dynora_finance/shared/bloc/view_status.dart';
import 'package:dynora_finance/shared/utils/formatters.dart';
import 'package:dynora_finance/shared/widgets/app_bar/custom_appbar.dart';
import 'package:dynora_finance/shared/widgets/empty_state.dart';
import 'package:dynora_finance/shared/widgets/form/segment_option.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class LoansPage extends StatelessWidget {
  const LoansPage({super.key, this.initialDirection = LoanDirection.borrowed});

  /// Tab selected when the page opens.
  final LoanDirection initialDirection;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => serviceLocator<LoansCubit>()
        ..selectDirection(initialDirection)
        ..start(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: const CustomAppbar(title: 'Préstamos', canBack: true),
        floatingActionButton: Builder(
          builder: (context) => FloatingActionButton(
            backgroundColor: Colors.purpleAccent,
            tooltip: 'Nuevo préstamo',
            onPressed: () => LoanFormSheet.show(
              context,
              direction: context.read<LoansCubit>().state.direction,
            ),
            child: const Icon(Icons.add),
          ),
        ),
        body: BlocBuilder<LoansCubit, LoansState>(
          builder: (context, state) {
            switch (state.status) {
              case ViewStatus.loading:
                return const Center(child: CircularProgressIndicator());
              case ViewStatus.failure:
                return Padding(
                  padding: EdgeInsets.all(20.r),
                  child: EmptyState(
                    icon: Icons.error_outline_rounded,
                    message:
                        state.error ?? 'No se pudieron cargar los préstamos',
                  ),
                );
              case ViewStatus.loaded:
                return ListView(
                  padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 100.h),
                  children: [
                    Row(
                      children: [
                        for (final (index, direction)
                            in LoanDirection.values.indexed) ...[
                          if (index > 0) SizedBox(width: 8.w),
                          Expanded(
                            child: SegmentOption(
                              label: direction.tab,
                              color: AppColors.secondary,
                              selected: state.direction == direction,
                              onTap: () => context
                                  .read<LoansCubit>()
                                  .selectDirection(direction),
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 16.h),
                    _TotalCard(state: state),
                    SizedBox(height: 24.h),
                    if (state.loans.isEmpty)
                      EmptyState(
                        icon: Icons.account_balance_rounded,
                        message: state.direction.emptyMessage,
                      ),
                    for (final (index, loan) in state.active.indexed) ...[
                      if (index > 0) SizedBox(height: 12.h),
                      _LoanTile(summary: loan),
                    ],
                    if (state.settled.isNotEmpty) ...[
                      SizedBox(height: 28.h),
                      Text(
                        'Liquidados',
                        style: TextStyle(
                          color: AppColors.textPrimary70,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      for (final loan in state.settled) ...[
                        SizedBox(height: 12.h),
                        _LoanTile(summary: loan),
                      ],
                    ],
                  ],
                );
            }
          },
        ),
      ),
    );
  }
}

class _TotalCard extends StatelessWidget {
  const _TotalCard({required this.state});

  final LoansState state;

  @override
  Widget build(BuildContext context) {
    final dueThisMonth = state.dueThisMonth(DateTime.now());
    final overdue = state.overdueAmount;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            state.direction.totalTitle,
            style: TextStyle(color: AppColors.textPrimary70),
          ),
          SizedBox(height: 6.h),
          Text(
            Formatters.currency(state.totalRemaining),
            style: TextStyle(
              color: Colors.white,
              fontSize: 28.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            '${state.direction.monthTitle}: '
            '${Formatters.currency(dueThisMonth)}',
            style: TextStyle(color: AppColors.textPrimary85, fontSize: 13.sp),
          ),
          if (overdue > 0)
            Padding(
              padding: EdgeInsets.only(top: 4.h),
              child: Text(
                'Vencido: ${Formatters.currency(overdue)}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _LoanTile extends StatelessWidget {
  const _LoanTile({required this.summary});

  final LoanSummary summary;

  @override
  Widget build(BuildContext context) {
    final loan = summary.loan;
    final (status, statusColor) = loanStatusLine(summary);

    return InkWell(
      onTap: () => context.push(AppRoutes.loanDetailPath(loan.id)),
      borderRadius: BorderRadius.circular(18.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(18.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary40,
                  child: Icon(loan.kind.icon, color: Colors.white),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loan.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        loan.kind.label,
                        style: TextStyle(
                          color: AppColors.textPrimary70,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      Formatters.currency(summary.remaining),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      loan.direction.remainingShort,
                      style: TextStyle(
                        color: AppColors.textPrimary70,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: LinearProgressIndicator(
                value: summary.progress,
                minHeight: 8.h,
                backgroundColor: AppColors.surfaceVariant,
                valueColor: const AlwaysStoppedAnimation(AppColors.success),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              '${loan.direction.paidWord} '
              '${Formatters.currency(summary.paid)} de '
              '${Formatters.currency(summary.total)}',
              style: TextStyle(color: AppColors.textPrimary70, fontSize: 12.sp),
            ),
            SizedBox(height: 2.h),
            Text(
              status,
              style: TextStyle(color: statusColor, fontSize: 12.sp),
            ),
          ],
        ),
      ),
    );
  }
}
