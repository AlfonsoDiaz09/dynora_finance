import 'package:dynora_finance/features/stats/presentation/cubit/stats_cubit.dart';
import 'package:dynora_finance/features/stats/presentation/pages/stats/widgets/category_bar.dart';
import 'package:dynora_finance/shared/widgets/empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CategoryChart extends StatelessWidget {
  const CategoryChart({super.key, required this.items});

  final List<CategoryExpense> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Gastos por categoría",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 20.h),
        if (items.isEmpty)
          const EmptyState(message: 'Sin gastos este mes')
        else
          for (final (index, item) in items.indexed) ...[
            if (index > 0) SizedBox(height: 14.h),
            CategoryBar(
              category: item.name,
              percentage: item.share,
              color: Color(item.colorValue),
            ),
          ],
      ],
    );
  }
}
