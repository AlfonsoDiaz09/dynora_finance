import 'package:dynora_finance/features/categories/domain/entities/category_entity.dart';
import 'package:dynora_finance/features/movements/domain/entities/movement_entity.dart';
import 'package:dynora_finance/features/movements/presentation/utils/movement_labels.dart';
import 'package:dynora_finance/shared/utils/formatters.dart';
import 'package:dynora_finance/shared/widgets/empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'recent_movement_item.dart';
import 'section_header.dart';

class RecentMovementsSection extends StatelessWidget {
  const RecentMovementsSection({
    super.key,
    required this.movements,
    required this.categories,
    required this.onMovementTap,
    required this.onSeeAll,
  });

  final List<MovementEntity> movements;
  final Map<String, CategoryEntity> categories;
  final ValueChanged<MovementEntity> onMovementTap;

  /// Opens the movements tab.
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: "Movimientos recientes",
          actionLabel: "Ver movimientos",
          onAction: onSeeAll,
        ),
        SizedBox(height: 8.h),
        if (movements.isEmpty)
          const EmptyState(
            icon: Icons.receipt_long_rounded,
            message: 'Aún no registras movimientos',
          )
        else
          for (final (index, movement) in movements.indexed) ...[
            if (index > 0) SizedBox(height: 10.h),
            RecentMovementItem(
              title: movement.title,
              date:
                  '${Formatters.relativeDay(movement.date)} · '
                  '${movement.categoryName(categories)}',
              amount: movement.amount,
              type: movement.displayType,
              icon: movement.categoryIcon(categories),
              iconColor: movement.categoryColor(categories),
              onTap: () => onMovementTap(movement),
            ),
          ],
      ],
    );
  }
}
