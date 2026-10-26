import 'package:dynora_finance/app/theme/app_colors.dart';
import 'package:dynora_finance/features/cards/domain/entities/card_entity.dart';
import 'package:dynora_finance/features/cards/presentation/utils/card_labels.dart';
import 'package:dynora_finance/features/categories/domain/entities/category_entity.dart';
import 'package:dynora_finance/features/debts/domain/entities/movement_debts.dart';
import 'package:dynora_finance/features/debts/presentation/utils/debt_labels.dart';
import 'package:dynora_finance/features/movements/domain/entities/movement_entity.dart';
import 'package:dynora_finance/features/movements/presentation/cubit/movements_cubit.dart';
import 'package:dynora_finance/features/movements/presentation/utils/movement_labels.dart';
import 'package:dynora_finance/shared/utils/formatters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dynora_finance/features/movements/presentation/widgets/movement_actions_sheet.dart';
import 'movement_item.dart';

/// One day: its date, net total and movements.
class MovementGroup extends StatelessWidget {
  final MovementDayGroup group;
  final Map<String, CategoryEntity> categories;
  final Map<String, CardEntity> cards;
  final Map<String, MovementDebts> debts;
  final ValueChanged<MovementEntity> onMovementTap;

  const MovementGroup({
    super.key,
    required this.group,
    required this.categories,
    required this.cards,
    this.debts = const {},
    required this.onMovementTap,
  });

  @override
  Widget build(BuildContext context) {
    final net = group.net;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  Formatters.relativeDay(group.day),
                  style: TextStyle(
                    color: AppColors.textPrimary85,
                    fontWeight: FontWeight.bold,
                    fontSize: 13.sp,
                  ),
                ),
              ),
              Text(
                '${net >= 0 ? '+' : '-'}${Formatters.currency(net.abs())}',
                style: TextStyle(
                  color: AppColors.textPrimary70,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        for (final movement in group.movements) ...[
          SizedBox(height: 8.h),
          MovementItem(
            title: movement.title,
            category: _subtitle(movement),
            amount: movement.amount,
            isExpense: movement.showsAsExpense,
            icon: movement.categoryIcon(categories),
            iconColor: movement.categoryColor(categories),
            onTap: () => onMovementTap(movement),
            onLongPress: () => MovementActionsSheet.show(context, movement),
          ),
        ],
      ],
    );
  }

  /// `Comida · Nu •• 1234 · 12 MSI`, `Comida · Transferencia`, ...
  String _subtitle(MovementEntity movement) {
    final card = cards[movement.cardId];
    return [
      movement.categoryName(categories),
      card?.shortLabel ?? movement.paymentMethod.label,
      ?movement.installmentTag,
      ?debtTag(debts[movement.id]),
    ].join(' · ');
  }
}
