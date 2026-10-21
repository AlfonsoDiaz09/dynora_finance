import 'package:dynora_finance/app/theme/app_colors.dart';
import 'package:dynora_finance/shared/utils/formatters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// ‹ Octubre 2026 › selector, with a "Hoy" shortcut when another month is
/// shown. The label shrinks instead of overflowing on narrow screens.
class MonthSwitcher extends StatelessWidget {
  const MonthSwitcher({
    super.key,
    required this.month,
    required this.onPrevious,
    required this.onNext,
    required this.onToday,
  });

  /// Any day of the shown month.
  final DateTime month;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onToday;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isCurrent = month.year == now.year && month.month == now.month;

    return Container(
      height: 48.h,
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onPrevious,
            tooltip: 'Mes anterior',
            icon: const Icon(Icons.chevron_left_rounded, color: Colors.white),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      Formatters.monthYear(month),
                      maxLines: 1,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                if (!isCurrent) ...[
                  SizedBox(width: 8.w),
                  ActionChip(
                    label: const Text('Hoy'),
                    onPressed: onToday,
                    visualDensity: VisualDensity.compact,
                    labelStyle: TextStyle(color: Colors.white, fontSize: 12.sp),
                    backgroundColor: AppColors.primary40,
                    side: BorderSide.none,
                    padding: EdgeInsets.zero,
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: onNext,
            tooltip: 'Mes siguiente',
            icon: const Icon(Icons.chevron_right_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
