import 'package:dynora_finance/app/theme/app_colors.dart';
import 'package:dynora_finance/features/cards/domain/entities/card_entity.dart';
import 'package:dynora_finance/features/cards/presentation/utils/card_labels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CardHeader extends StatelessWidget {
  const CardHeader({super.key, required this.card, required this.onEdit});

  final CardEntity card;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final color = Color(card.colorValue);

    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 8.w, 20.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        gradient: LinearGradient(
          colors: [color, Color.lerp(color, AppColors.background, 0.55)!],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  card.type.label,
                  style: TextStyle(color: AppColors.textPrimary85),
                ),
              ),
              IconButton(
                onPressed: onEdit,
                tooltip: 'Editar tarjeta',
                icon: const Icon(Icons.edit_rounded, color: Colors.white),
              ),
            ],
          ),
          Text(
            card.maskedDigits,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            card.hasBillingCycle
                ? 'Corte día ${card.cutoffDay} · Pago día ${card.paymentDueDay}'
                : 'Sin fecha de corte',
            style: TextStyle(color: AppColors.textPrimary85),
          ),
        ],
      ),
    );
  }
}
