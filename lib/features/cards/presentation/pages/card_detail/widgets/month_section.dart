import 'package:dynora_finance/app/theme/app_colors.dart';
import 'package:dynora_finance/features/cards/presentation/cubit/card_detail_cubit.dart';
import 'package:dynora_finance/features/categories/domain/entities/category_entity.dart';
import 'package:dynora_finance/features/debts/presentation/utils/debtor.dart';
import 'package:dynora_finance/features/debts/presentation/widgets/debtor_avatars.dart';
import 'package:dynora_finance/features/debts/presentation/widgets/debtors_sheet.dart';
import 'package:dynora_finance/features/movements/domain/entities/movement_entity.dart';
import 'package:dynora_finance/features/movements/presentation/pages/movements/widgets/movement_item.dart';
import 'package:dynora_finance/features/movements/presentation/utils/movement_labels.dart';
import 'package:dynora_finance/shared/utils/formatters.dart';
import 'package:dynora_finance/shared/utils/group_by_day.dart';
import 'package:dynora_finance/shared/widgets/day_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Movements of a debit card in one calendar month.
class MonthSection extends StatelessWidget {
  const MonthSection({
    super.key,
    required this.month,
    required this.categories,
    this.debtors = const {},
    required this.onMovementTap,
  });

  final MonthMovements month;
  final Map<String, CategoryEntity> categories;
  final Map<String, List<Debtor>> debtors;
  final ValueChanged<MovementEntity> onMovementTap;

  @override
  Widget build(BuildContext context) {
    final summary = month.summary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          Formatters.monthYear(month.month.start),
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          'Gastos ${Formatters.currency(summary.expense)} · '
          'Ingresos ${Formatters.currency(summary.income)}',
          style: TextStyle(color: AppColors.textPrimary70, fontSize: 12.sp),
        ),
        if (month.movements.isEmpty)
          Padding(
            padding: EdgeInsets.only(top: 12.h),
            child: Text(
              'Sin movimientos en este mes',
              style: TextStyle(color: AppColors.textPrimary38, fontSize: 13.sp),
            ),
          ),
        for (final (day, movements) in groupByDay(
          month.movements,
          (movement) => movement.date,
        )) ...[
          DayHeader(day: day),
          for (final movement in movements) ...[
            SizedBox(height: 10.h),
            MovementItem(
              title: movement.title,
              category: movement.categoryName(categories),
              amount: movement.amount,
              isExpense: movement.isExpense,
              onTap: () => onMovementTap(movement),
              footer: switch (debtors[movement.id]) {
                final list? when list.isNotEmpty => DebtorAvatars(
                  debtors: list,
                  onTap: () => DebtorsSheet.show(
                    context,
                    title: movement.title,
                    debtors: list,
                  ),
                ),
                _ => null,
              },
            ),
          ],
        ],
      ],
    );
  }
}
