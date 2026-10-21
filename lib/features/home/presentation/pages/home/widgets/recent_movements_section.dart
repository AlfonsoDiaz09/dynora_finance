import 'package:dynora_finance/features/movements/domain/entities/movement_entity.dart';
import 'package:dynora_finance/features/movements/presentation/utils/movement_labels.dart';
import 'package:dynora_finance/shared/utils/formatters.dart';
import 'package:dynora_finance/shared/widgets/empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'recent_movement_item.dart';

class RecentMovementsSection extends StatelessWidget {
  const RecentMovementsSection({
    super.key,
    required this.movements,
    required this.onMovementTap,
  });

  final List<MovementEntity> movements;
  final ValueChanged<MovementEntity> onMovementTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Movimientos recientes",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16.h),
        if (movements.isEmpty)
          const EmptyState(
            icon: Icons.receipt_long_rounded,
            message: 'Aún no registras movimientos',
          )
        else
          for (final (index, movement) in movements.indexed) ...[
            if (index > 0) SizedBox(height: 12.h),
            RecentMovementItem(
              title: movement.title,
              date: Formatters.relativeDay(movement.date),
              amount: movement.amount,
              type: movement.displayType,
              onTap: () => onMovementTap(movement),
            ),
          ],
      ],
    );
  }
}
