import 'package:dynora_finance/app/theme/app_colors.dart';
import 'package:dynora_finance/features/stats/presentation/cubit/stats_cubit.dart';
import 'package:dynora_finance/shared/utils/category_icons.dart';
import 'package:dynora_finance/shared/utils/formatters.dart';
import 'package:dynora_finance/shared/widgets/empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Expenses of the month by category: amount, share and bar.
class CategoryChart extends StatelessWidget {
  const CategoryChart({super.key, required this.items, required this.total});

  final List<CategoryExpense> items;
  final double total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Gastos por categoría',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                Formatters.currency(total),
                style: TextStyle(
                  color: AppColors.textPrimary70,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          if (items.isEmpty)
            const EmptyState(
              icon: Icons.pie_chart_outline_rounded,
              message: 'Sin gastos este mes',
            )
          else
            for (final (index, item) in items.indexed) ...[
              if (index > 0) SizedBox(height: 14.h),
              _CategoryRow(item: item),
            ],
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({required this.item});

  final CategoryExpense item;

  @override
  Widget build(BuildContext context) {
    final color = Color(item.colorValue);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 30.r,
              height: 30.r,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(9.r),
              ),
              child: Icon(
                CategoryIcons.of(item.iconKey),
                color: color,
                size: 16.sp,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                item.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.white, fontSize: 14.sp),
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              Formatters.currency(item.amount),
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13.sp,
              ),
            ),
            SizedBox(
              width: 44.w,
              child: Text(
                '${(item.share * 100).round()}%',
                textAlign: TextAlign.end,
                style: TextStyle(
                  color: AppColors.textPrimary70,
                  fontSize: 12.sp,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(6.r),
          child: LinearProgressIndicator(
            value: item.share.clamp(0, 1).toDouble(),
            minHeight: 6.h,
            backgroundColor: Colors.white10,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }
}
