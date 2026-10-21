import 'package:dynora_finance/app/theme/app_colors.dart';
import 'package:dynora_finance/shared/utils/formatters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Income, expenses and balance of the month, with the savings rate.
class StatisticsSummaryCard extends StatelessWidget {
  const StatisticsSummaryCard({
    super.key,
    required this.income,
    required this.expense,
    required this.savingsRate,
  });

  final double income;
  final double expense;

  /// Share of the income not spent; `null` without income.
  final double? savingsRate;

  @override
  Widget build(BuildContext context) {
    final balance = income - expense;
    final rate = savingsRate;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 18.h),
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
            'Balance del mes',
            style: TextStyle(color: AppColors.textPrimary85),
          ),
          SizedBox(height: 4.h),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '${balance < 0 ? '-' : ''}${Formatters.currency(balance.abs())}',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 14.h),
          Row(
            children: [
              Expanded(
                child: _Figure(
                  icon: Icons.south_west_rounded,
                  label: 'Ingresos',
                  value: Formatters.currency(income),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _Figure(
                  icon: Icons.north_east_rounded,
                  label: 'Gastos',
                  value: Formatters.currency(expense),
                ),
              ),
            ],
          ),
          if (rate != null) ...[
            SizedBox(height: 14.h),
            Text(
              rate >= 0
                  ? 'Ahorraste el ${(rate * 100).round()}% de tus ingresos'
                  : 'Gastaste ${(-rate * 100).round()}% más de lo que ingresó',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Figure extends StatelessWidget {
  const _Figure({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 18.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: AppColors.textPrimary85,
                    fontSize: 12.sp,
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    maxLines: 1,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
