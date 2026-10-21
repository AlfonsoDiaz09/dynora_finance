import 'package:dynora_finance/app/theme/app_colors.dart';
import 'package:dynora_finance/features/cards/domain/entities/card_statement.dart';
import 'package:dynora_finance/features/categories/domain/entities/category_entity.dart';
import 'package:dynora_finance/features/movements/domain/entities/movement_entity.dart';
import 'package:dynora_finance/features/movements/presentation/pages/movements/widgets/movement_item.dart';
import 'package:dynora_finance/shared/utils/formatters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// One billing period: dates, payment info, total and its movements.
class StatementSection extends StatelessWidget {
  const StatementSection({
    super.key,
    required this.statement,
    required this.categories,
    required this.onMovementTap,
  });

  final CardStatement statement;
  final Map<String, CategoryEntity> categories;
  final ValueChanged<MovementEntity> onMovementTap;

  @override
  Widget build(BuildContext context) {
    final period = statement.period;
    final (statusLabel, statusColor) = _status(DateTime.now());
    final fundingMonth = Formatters.monthYear(period.fundingMonth().start);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '${Formatters.shortDate(period.start)} – ${Formatters.shortDate(period.end)}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                statusLabel,
                style: TextStyle(color: statusColor, fontSize: 12.sp),
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        Row(
          children: [
            Expanded(
              child: Text(
                'Pago el ${Formatters.shortDate(period.paymentDate)} · '
                'con tu ingreso de $fundingMonth',
                style: TextStyle(
                  color: AppColors.textPrimary70,
                  fontSize: 12.sp,
                ),
              ),
            ),
            Text(
              Formatters.currency(statement.total),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        if (statement.movements.isEmpty)
          Padding(
            padding: EdgeInsets.only(top: 12.h),
            child: Text(
              'Sin movimientos en este periodo',
              style: TextStyle(color: AppColors.textPrimary38, fontSize: 13.sp),
            ),
          )
        else
          for (final movement in statement.movements) ...[
            SizedBox(height: 12.h),
            MovementItem(
              title: movement.title,
              category:
                  '${categories[movement.categoryId]?.name ?? 'Sin categoría'} · '
                  '${Formatters.shortDate(movement.date)}',
              amount: movement.amount,
              isExpense: movement.isExpense,
              onTap: () => onMovementTap(movement),
            ),
          ],
      ],
    );
  }

  (String, Color) _status(DateTime now) {
    final period = statement.period;
    if (period.isOpen(now)) return ('Periodo actual', AppColors.info);
    if (period.isAwaitingPayment(now)) {
      final days = period.daysUntilPayment(now);
      final label = switch (days) {
        0 => 'Por pagar · hoy',
        1 => 'Por pagar · 1 día',
        _ => 'Por pagar · $days días',
      };
      return (label, days <= 3 ? AppColors.error : AppColors.warning);
    }
    return ('Cerrado', AppColors.textPrimary70);
  }
}
