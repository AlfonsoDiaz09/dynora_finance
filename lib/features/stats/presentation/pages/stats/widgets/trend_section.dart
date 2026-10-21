import 'package:dynora_finance/app/theme/app_colors.dart';
import 'package:dynora_finance/shared/utils/formatters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// This month's expenses vs the previous month, and the daily average.
class TrendSection extends StatelessWidget {
  const TrendSection({
    super.key,
    required this.expense,
    required this.previousExpense,
    required this.trend,
    required this.dailyAverage,
  });

  final double expense;
  final double previousExpense;

  /// Change vs the previous month, `null` without previous expenses.
  final double? trend;
  final double dailyAverage;

  @override
  Widget build(BuildContext context) {
    final (message, color, icon) = _describe();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tendencia',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _Figure(
                  label: 'Este mes',
                  value: Formatters.currency(expense),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _Figure(
                  label: 'Mes anterior',
                  value: Formatters.currency(previousExpense),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Icon(icon, color: color, size: 18.sp),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(color: color, fontSize: 13.sp),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            'Gasto diario promedio: ${Formatters.currency(dailyAverage)}',
            style: TextStyle(color: AppColors.textPrimary70, fontSize: 12.sp),
          ),
        ],
      ),
    );
  }

  (String, Color, IconData) _describe() {
    final value = trend;
    if (value == null) {
      return (
        'Sin gastos el mes anterior para comparar',
        AppColors.textPrimary70,
        Icons.remove_rounded,
      );
    }
    final percent = (value.abs() * 100).round();
    if (percent == 0) {
      return (
        'Mismo gasto que el mes anterior',
        AppColors.textPrimary70,
        Icons.drag_handle_rounded,
      );
    }
    return value > 0
        ? (
            '$percent% más gasto que el mes anterior',
            Colors.orangeAccent,
            Icons.trending_up_rounded,
          )
        : (
            '$percent% menos gasto que el mes anterior',
            Colors.greenAccent,
            Icons.trending_down_rounded,
          );
  }
}

class _Figure extends StatelessWidget {
  const _Figure({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: AppColors.textPrimary70, fontSize: 12.sp),
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
    );
  }
}
