import 'package:dynora_finance/app/theme/app_colors.dart';
import 'package:dynora_finance/features/loans/domain/entities/loan_summary.dart';
import 'package:dynora_finance/features/loans/presentation/cubit/loans_cubit.dart';
import 'package:dynora_finance/features/loans/presentation/utils/loan_labels.dart';
import 'package:dynora_finance/features/loans/presentation/widgets/loan_form_sheet.dart';
import 'package:dynora_finance/features/loans/presentation/widgets/loan_payment_sheet.dart';
import 'package:dynora_finance/init_dependencies.dart';
import 'package:dynora_finance/shared/bloc/view_status.dart';
import 'package:dynora_finance/shared/utils/formatters.dart';
import 'package:dynora_finance/shared/widgets/app_bar/custom_appbar.dart';
import 'package:dynora_finance/shared/widgets/empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class LoanDetailPage extends StatelessWidget {
  const LoanDetailPage({super.key, required this.loanId});

  final String loanId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoanDetailCubit(
        loanId: loanId,
        watchLoans: serviceLocator(),
        watchLoanPayments: serviceLocator(),
      )..start(),
      child: BlocConsumer<LoanDetailCubit, LoanDetailState>(
        // Leave the page once the loan is deleted from its edit form.
        listenWhen: (prev, curr) =>
            prev.summary != null &&
            curr.status == ViewStatus.loaded &&
            curr.summary == null,
        listener: (context, _) => context.pop(),
        builder: (context, state) {
          final summary = state.summary;

          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: CustomAppbar(
              title: summary?.loan.name ?? 'Préstamo',
              canBack: true,
            ),
            floatingActionButton: summary == null || summary.isSettled
                ? null
                : FloatingActionButton.extended(
                    backgroundColor: Colors.purpleAccent,
                    onPressed: () =>
                        LoanPaymentSheet.show(context, summary: summary),
                    icon: const Icon(Icons.payments_rounded),
                    label: const Text('Registrar pago'),
                  ),
            body: switch (state.status) {
              ViewStatus.loading => const Center(
                child: CircularProgressIndicator(),
              ),
              ViewStatus.failure => Padding(
                padding: EdgeInsets.all(20.r),
                child: const EmptyState(
                  icon: Icons.error_outline_rounded,
                  message: 'No se pudo cargar el préstamo',
                ),
              ),
              ViewStatus.loaded when summary == null => Padding(
                padding: EdgeInsets.all(20.r),
                child: const EmptyState(message: 'Este préstamo ya no existe'),
              ),
              ViewStatus.loaded => ListView(
                padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 100.h),
                children: [
                  _Header(summary: summary!),
                  if (summary.installments.isNotEmpty) ...[
                    SizedBox(height: 24.h),
                    const _Title('Calendario de pagos'),
                    for (final installment in summary.installments)
                      _InstallmentRow(
                        state: installment,
                        isNext:
                            installment == summary.nextInstallment &&
                            !summary.isSettled,
                      ),
                  ],
                  SizedBox(height: 24.h),
                  const _Title('Pagos realizados'),
                  if (summary.payments.isEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: 8.h),
                      child: Text(
                        'Aún no registras pagos',
                        style: TextStyle(
                          color: AppColors.textPrimary38,
                          fontSize: 13.sp,
                        ),
                      ),
                    )
                  else
                    for (final payment in summary.payments)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        onTap: () => LoanPaymentSheet.show(
                          context,
                          summary: summary,
                          payment: payment,
                        ),
                        leading: const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.success,
                        ),
                        title: Text(
                          Formatters.currency(payment.amount),
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          [
                            '${payment.paidAt.day} '
                                '${Formatters.shortMonthYear(payment.paidAt)}',
                            ?payment.note,
                          ].join(' · '),
                          style: TextStyle(color: AppColors.textPrimary70),
                        ),
                        trailing: Icon(
                          Icons.edit_rounded,
                          color: AppColors.textPrimary38,
                          size: 18.sp,
                        ),
                      ),
                ],
              ),
            },
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.summary});

  final LoanSummary summary;

  @override
  Widget build(BuildContext context) {
    final loan = summary.loan;
    final (status, statusColor) = loanStatusLine(summary);

    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 8.w, 20.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(loan.kind.icon, color: AppColors.textPrimary85, size: 18.sp),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  loan.kind.label,
                  style: TextStyle(color: AppColors.textPrimary85),
                ),
              ),
              IconButton(
                onPressed: () => LoanFormSheet.show(context, loan: loan),
                tooltip: 'Editar préstamo',
                icon: const Icon(Icons.edit_rounded, color: Colors.white),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(right: 12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Restante',
                  style: TextStyle(color: AppColors.textPrimary85),
                ),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: Formatters.currency(summary.remaining),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: '  / ${Formatters.currency(summary.total)}',
                        style: TextStyle(
                          color: AppColors.textPrimary70,
                          fontSize: 15.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
                  child: LinearProgressIndicator(
                    value: summary.progress,
                    minHeight: 10.h,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation(Colors.white),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  '${(summary.progress * 100).round()}% pagado · '
                  '${Formatters.currency(summary.paid)}',
                  style: TextStyle(
                    color: AppColors.textPrimary85,
                    fontSize: 12.sp,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  status,
                  style: TextStyle(
                    color: statusColor == AppColors.error
                        ? Colors.white
                        : AppColors.textPrimary85,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 14.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: [
                    _Chip('Prestado ${Formatters.currency(loan.principal)}'),
                    _Chip('Intereses ${Formatters.currency(loan.interest)}'),
                    if (loan.installmentAmount case final amount?)
                      _Chip('Pago mensual ${Formatters.currency(amount)}'),
                    if (loan.firstPaymentDate case final first?)
                      _Chip('Día de pago ${first.day}'),
                    _Chip(
                      'Recibido ${loan.startDate.day} '
                      '${Formatters.shortMonthYear(loan.startDate)}',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        label,
        style: TextStyle(color: Colors.white, fontSize: 12.sp),
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white,
        fontSize: 16.sp,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _InstallmentRow extends StatelessWidget {
  const _InstallmentRow({required this.state, required this.isNext});

  final InstallmentState state;
  final bool isNext;

  @override
  Widget build(BuildContext context) {
    final installment = state.installment;
    final (label, color) = installmentStatusStyle(state);

    return Container(
      margin: EdgeInsets.only(top: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: isNext ? 0.1 : 0.04),
        borderRadius: BorderRadius.circular(14.r),
        border: isNext ? Border.all(color: AppColors.secondary) : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 32.w,
            child: Text(
              '${installment.number}',
              style: TextStyle(
                color: AppColors.textPrimary70,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              '${installment.dueDate.day} '
              '${Formatters.shortMonthYear(installment.dueDate)}',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          Text(
            Formatters.currency(installment.amount),
            style: const TextStyle(color: Colors.white),
          ),
          SizedBox(width: 12.w),
          SizedBox(
            width: 92.w,
            child: Text(
              label,
              textAlign: TextAlign.end,
              style: TextStyle(color: color, fontSize: 12.sp),
            ),
          ),
        ],
      ),
    );
  }
}
