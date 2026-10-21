import 'package:dynora_finance/app/theme/app_colors.dart';
import 'package:dynora_finance/features/cards/domain/entities/card_entity.dart';
import 'package:dynora_finance/features/cards/presentation/utils/card_labels.dart';
import 'package:dynora_finance/features/categories/domain/entities/category_entity.dart';
import 'package:dynora_finance/features/movements/domain/entities/movement_entity.dart';
import 'package:dynora_finance/features/movements/presentation/cubit/movements_cubit.dart';
import 'package:dynora_finance/features/movements/presentation/utils/movement_labels.dart';
import 'package:dynora_finance/shared/utils/formatters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'movement_item.dart';

class MovementGroup extends StatelessWidget {
  final String date;
  final List<MovementEntity> movements;
  final Map<String, CategoryEntity> categories;
  final Map<String, CardEntity> cards;
  final Map<String, MovementDebts> debts;
  final ValueChanged<MovementEntity> onMovementTap;

  const MovementGroup({
    super.key,
    required this.date,
    required this.movements,
    required this.categories,
    required this.cards,
    this.debts = const {},
    required this.onMovementTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          date,
          style: TextStyle(
            color: AppColors.textPrimary70,
            fontWeight: FontWeight.bold,
          ),
        ),
        for (final movement in movements) ...[
          SizedBox(height: 12.h),
          MovementItem(
            title: movement.title,
            category: _subtitle(movement),
            amount: movement.amount,
            isExpense: movement.isExpense,
            onTap: () => onMovementTap(movement),
          ),
        ],
      ],
    );
  }

  /// `Comida · Nu •• 1234 · 12 MSI`, `Comida · Transferencia`, ...
  String _subtitle(MovementEntity movement) {
    final card = cards[movement.cardId];
    return [
      categories[movement.categoryId]?.name ?? 'Sin categoría',
      card?.shortLabel ?? movement.paymentMethod.label,
      ?movement.installmentTag,
      ?_debtTag(debts[movement.id]),
    ].join(' · ');
  }

  static String? _debtTag(MovementDebts? debts) {
    if (debts == null) return null;
    return debts.pending > 0
        ? 'Te deben ${Formatters.currency(debts.pending)}'
        : 'Saldado';
  }
}
