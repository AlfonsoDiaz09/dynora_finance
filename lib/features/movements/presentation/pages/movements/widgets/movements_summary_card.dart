import 'package:dynora_finance/app/theme/app_colors.dart';
import 'package:dynora_finance/shared/utils/formatters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Income, expenses and balance of the month.
class MovementsSummaryCard extends StatelessWidget {
  const MovementsSummaryCard({
    super.key,
    required this.income,
    required this.expense,
  });

  final double income;
  final double expense;

  @override
  Widget build(BuildContext context) {
    final balance = income - expense;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        gradient: const LinearGradient(
          colors: [AppColors.surface, AppColors.surfaceVariant],
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _Figure(
              label: 'Ingresos',
              value: Formatters.currency(income),
              color: Colors.greenAccent,
            ),
          ),
          _Divider(),
          Expanded(
            child: _Figure(
              label: 'Gastos',
              value: Formatters.currency(expense),
              color: Colors.redAccent,
            ),
          ),
          _Divider(),
          Expanded(
            child: _Figure(
              label: 'Balance',
              value:
                  '${balance < 0 ? '-' : ''}${Formatters.currency(balance.abs())}',
              color: balance < 0 ? Colors.redAccent : Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _Figure extends StatelessWidget {
  const _Figure({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(color: AppColors.textPrimary70, fontSize: 12.sp),
        ),
        SizedBox(height: 4.h),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            maxLines: 1,
            style: TextStyle(
              color: color,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 32.h,
      margin: EdgeInsets.symmetric(horizontal: 6.w),
      color: Colors.white12,
    );
  }
}
