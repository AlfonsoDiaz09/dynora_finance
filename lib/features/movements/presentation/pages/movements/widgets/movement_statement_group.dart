import 'package:dynora_finance/app/theme/app_colors.dart';
import 'package:dynora_finance/features/cards/domain/entities/card_statement.dart';
import 'package:dynora_finance/features/cards/presentation/utils/card_labels.dart';
import 'package:dynora_finance/features/cards/presentation/utils/statement_status_style.dart';
import 'package:dynora_finance/features/categories/domain/entities/category_entity.dart';
import 'package:dynora_finance/features/debts/domain/entities/movement_debts.dart';
import 'package:dynora_finance/features/debts/presentation/utils/debt_labels.dart';
import 'package:dynora_finance/features/movements/domain/entities/movement_entity.dart';
import 'package:dynora_finance/features/movements/presentation/cubit/movements_cubit.dart';
import 'package:dynora_finance/features/movements/presentation/utils/movement_labels.dart';
import 'package:dynora_finance/shared/utils/formatters.dart';
import 'package:dynora_finance/shared/widgets/info_row_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dynora_finance/features/movements/presentation/widgets/movement_actions_sheet.dart';
import 'movement_item.dart';

/// A credit card statement paid this month: card, period, payment date,
/// total and its charges.
class MovementStatementView extends StatelessWidget {
  const MovementStatementView({
    super.key,
    required this.group,
    required this.categories,
    this.debts = const {},
    required this.onMovementTap,
    this.onCardTap,
  });

  final MovementStatementGroup group;
  final Map<String, CategoryEntity> categories;
  final Map<String, MovementDebts> debts;
  final ValueChanged<MovementEntity> onMovementTap;
  final VoidCallback? onCardTap;

  @override
  Widget build(BuildContext context) {
    final card = group.card;
    final statement = group.statement;
    final period = statement.period;
    final color = Color(card.colorValue);
    final (statusLabel, statusColor) = statementStatusStyle(
      statement,
      DateTime.now(),
    );

    return Container(
      padding: EdgeInsets.fromLTRB(10.w, 10.h, 10.w, 10.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: color.withValues(alpha: 0.45)),
        color: color.withValues(alpha: 0.06),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: onCardTap,
            borderRadius: BorderRadius.circular(12.r),
            child: Padding(
              padding: EdgeInsets.all(4.r),
              child: Row(
                children: [
                  Container(
                    width: 36.r,
                    height: 36.r,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      Icons.credit_card_rounded,
                      color: color,
                      size: 18.sp,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          card.shortLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14.sp,
                          ),
                        ),
                        Text(
                          'Periodo ${Formatters.shortDate(period.start)} – '
                          '${Formatters.shortDate(period.end)} · '
                          'Pago ${Formatters.shortDate(period.paymentDate)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.textPrimary70,
                            fontSize: 11.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '-${Formatters.currency(statement.total)}',
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      StatusPill(label: statusLabel, color: statusColor),
                    ],
                  ),
                ],
              ),
            ),
          ),
          for (final charge in group.charges) ...[
            SizedBox(height: 8.h),
            MovementItem(
              title: charge.movement.title,
              category: _subtitle(charge),
              amount: charge.amount,
              isExpense: charge.movement.isExpense,
              icon: charge.movement.categoryIcon(categories),
              iconColor: charge.movement.categoryColor(categories),
              onTap: () => onMovementTap(charge.movement),
              onLongPress: () =>
                  MovementActionsSheet.show(context, charge.movement),
            ),
          ],
        ],
      ),
    );
  }

  /// `Hogar · 25 Sep · 2/12`
  String _subtitle(StatementCharge charge) {
    final movement = charge.movement;
    return [
      movement.categoryName(categories),
      Formatters.shortDate(movement.date),
      if (charge.isInstallment)
        '${charge.installmentNumber}/${movement.installmentCount}',
      ?debtTag(debts[movement.id]),
    ].join(' · ');
  }
}
