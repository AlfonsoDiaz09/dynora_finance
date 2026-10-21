import 'package:dynora_finance/app/theme/app_colors.dart';
import 'package:dynora_finance/features/categories/domain/entities/category_entity.dart';
import 'package:dynora_finance/features/movements/domain/entities/movement_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'movement_item.dart';

class MovementGroup extends StatelessWidget {
  final String date;
  final List<MovementEntity> movements;
  final Map<String, CategoryEntity> categories;
  final ValueChanged<MovementEntity> onMovementTap;

  const MovementGroup({
    super.key,
    required this.date,
    required this.movements,
    required this.categories,
    required this.onMovementTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          date,
          style: TextStyle(color: AppColors.textPrimary70, fontWeight: FontWeight.bold),
        ),
        for (final movement in movements) ...[
          SizedBox(height: 12.h),
          MovementItem(
            title: movement.title,
            category: categories[movement.categoryId]?.name ?? 'Sin categoría',
            amount: movement.amount,
            isExpense: movement.isExpense,
            onTap: () => onMovementTap(movement),
          ),
        ],
      ],
    );
  }
}
