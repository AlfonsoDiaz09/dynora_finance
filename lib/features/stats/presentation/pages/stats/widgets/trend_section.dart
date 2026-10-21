import 'package:dynora_finance/app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TrendSection extends StatelessWidget {
  const TrendSection({super.key, required this.trend});

  /// Expense change vs the previous month, `null` without previous data.
  final double? trend;

  @override
  Widget build(BuildContext context) {
    final (message, color) = _describe();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        color: Colors.white.withValues(alpha: 0.05),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Tendencia mensual",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12.sp),
          Text(message, style: TextStyle(color: color)),
        ],
      ),
    );
  }

  (String, Color) _describe() {
    final value = trend;
    if (value == null) {
      return ('Sin gastos el mes anterior para comparar', AppColors.textPrimary70);
    }
    final percent = (value.abs() * 100).round();
    if (percent == 0) {
      return ('Mismo gasto que el mes anterior', AppColors.textPrimary70);
    }
    return value > 0
        ? ('⬆ $percent% más gasto que el mes anterior', Colors.orangeAccent)
        : ('⬇ $percent% menos gasto que el mes anterior', Colors.greenAccent);
  }
}
