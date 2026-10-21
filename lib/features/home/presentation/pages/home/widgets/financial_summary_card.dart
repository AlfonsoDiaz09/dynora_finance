import 'package:dynora_finance/app/theme/app_colors.dart';
import 'package:dynora_finance/features/home/domain/entities/spending_overview.dart';
import 'package:dynora_finance/shared/utils/formatters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// What you can spend right now and where that number comes from.
class FinancialSummaryCard extends StatelessWidget {
  const FinancialSummaryCard({super.key, required this.overview});

  final SpendingOverview overview;

  @override
  Widget build(BuildContext context) {
    final available = overview.available;

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
            'Disponible para gastar',
            style: TextStyle(color: AppColors.textPrimary85),
          ),
          SizedBox(height: 6.h),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              _signed(available),
              style: TextStyle(
                fontSize: 30.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          if (available < 0)
            Padding(
              padding: EdgeInsets.only(top: 2.h),
              child: Text(
                'Tus compromisos superan lo que tienes',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          SizedBox(height: 12.h),
          _Line(label: 'Efectivo y cuentas', value: _signed(overview.cash)),
          if (overview.cardDebt > 0)
            _Line(
              label: 'Por pagar en tarjetas',
              value: '-${Formatters.currency(overview.cardDebt)}',
            ),
          if (overview.futureInstallments > 0)
            _Line(
              label: 'Mensualidades futuras',
              value: Formatters.currency(overview.futureInstallments),
              muted: true,
            ),
          SizedBox(height: 14.h),
          Row(
            children: [
              Expanded(
                child: _MonthFigure(
                  icon: Icons.south_west_rounded,
                  label: 'Ingresos del mes',
                  value: Formatters.currency(overview.monthIncome),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _MonthFigure(
                  icon: Icons.north_east_rounded,
                  label: 'Gastos del mes',
                  value: Formatters.currency(overview.monthExpense),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _signed(double value) =>
      '${value < 0 ? '-' : ''}${Formatters.currency(value.abs())}';
}

class _Line extends StatelessWidget {
  const _Line({required this.label, required this.value, this.muted = false});

  final String label;
  final String value;

  /// Informative only (not part of the available amount).
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final color = muted ? AppColors.textPrimary70 : AppColors.textPrimary85;
    return Padding(
      padding: EdgeInsets.only(top: 4.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: color, fontSize: 13.sp),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: muted ? color : Colors.white,
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthFigure extends StatelessWidget {
  const _MonthFigure({
    required this.icon,
    required this.label,
    required this.value,
  });

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
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    label,
                    maxLines: 1,
                    style: TextStyle(
                      color: AppColors.textPrimary85,
                      fontSize: 12.sp,
                    ),
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
