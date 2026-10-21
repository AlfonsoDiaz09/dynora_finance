import 'package:dynora_finance/app/theme/app_colors.dart';
import 'package:dynora_finance/features/cards/presentation/cubit/cards_cubit.dart';
import 'package:dynora_finance/features/cards/presentation/utils/card_labels.dart';
import 'package:dynora_finance/shared/utils/formatters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Income of the month vs the card payments funded with it.
class MonthlyPlanCard extends StatelessWidget {
  const MonthlyPlanCard({super.key, required this.plan});

  final MonthlyCardPlan plan;

  @override
  Widget build(BuildContext context) {
    final remaining = plan.remaining;

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
            'Plan de ${Formatters.monthYear(plan.month.start)}',
            style: TextStyle(color: AppColors.textPrimary70),
          ),
          SizedBox(height: 6.h),
          Text(
            remaining >= 0
                ? '${Formatters.currency(remaining)} disponibles'
                : '${Formatters.currency(-remaining)} faltantes',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),
          _Row(
            label: 'Ingresos del mes',
            value: '+${Formatters.currency(plan.income)}',
            color: Colors.greenAccent,
          ),
          if (plan.payments.isEmpty)
            Padding(
              padding: EdgeInsets.only(top: 10.h),
              child: Text(
                'Sin pagos de tarjeta que cubrir con este ingreso',
                style: TextStyle(
                  color: AppColors.textPrimary70,
                  fontSize: 13.sp,
                ),
              ),
            )
          else
            for (final payment in plan.payments)
              _Row(
                label:
                    '${payment.amount == 0 && payment.statement.payment != null ? '✓ ' : ''}'
                    '${payment.card.shortLabel} · ${Formatters.shortDate(payment.dueDate)}',
                value: payment.statement.total > 0
                    ? '-${Formatters.currency(payment.statement.total)}'
                    : Formatters.currency(payment.statement.total),
                color: Colors.white,
              ),
          Divider(height: 24.h, color: Colors.white24),
          _Row(
            label: 'Total de tarjetas del mes',
            value: Formatters.currency(plan.totalPayments),
            color: Colors.white,
            bold: true,
          ),
          _Row(
            label: 'Pendiente por pagar',
            value: Formatters.currency(plan.pendingPayments),
            color: plan.pendingPayments > 0 ? Colors.white : Colors.greenAccent,
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.label,
    required this.value,
    required this.color,
    this.bold = false,
  });

  final String label;
  final String value;
  final Color color;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 8.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: AppColors.textPrimary85),
            ),
          ),
          SizedBox(width: 12.w),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: bold ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
