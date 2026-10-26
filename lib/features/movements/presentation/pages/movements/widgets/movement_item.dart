import 'package:dynora_finance/app/theme/app_colors.dart';
import 'package:dynora_finance/shared/utils/formatters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MovementItem extends StatelessWidget {
  final String title;
  final String category;
  final double amount;
  final bool isExpense;
  final VoidCallback? onTap;

  /// Opens the movement's options.
  final VoidCallback? onLongPress;

  /// Category icon and color; an in/out arrow when not given.
  final IconData? icon;
  final Color? iconColor;

  /// Extra content under the subtitle (e.g. who owes you for it).
  final Widget? footer;

  const MovementItem({
    super.key,
    required this.title,
    required this.category,
    required this.amount,
    required this.isExpense,
    this.onTap,
    this.onLongPress,
    this.icon,
    this.iconColor,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    final amountColor = isExpense ? Colors.redAccent : Colors.greenAccent;
    final prefix = isExpense ? "-" : "+";
    final badgeColor = iconColor ?? amountColor;

    return Material(
      color: Colors.white.withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(16.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          child: Row(
            children: [
              Container(
                width: 40.r,
                height: 40.r,
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  icon ??
                      (isExpense
                          ? Icons.arrow_upward_rounded
                          : Icons.arrow_downward_rounded),
                  color: badgeColor,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14.sp,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      category,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textPrimary70,
                        fontSize: 12.sp,
                      ),
                    ),
                    ?footer,
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                "$prefix${Formatters.currency(amount)}",
                style: TextStyle(
                  color: amountColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
