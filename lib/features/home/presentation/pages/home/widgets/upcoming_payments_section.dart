import 'package:dynora_finance/features/cards/domain/entities/card_entity.dart';
import 'package:dynora_finance/features/home/presentation/cubit/home_cubit.dart';
import 'package:dynora_finance/shared/utils/formatters.dart';
import 'package:dynora_finance/shared/widgets/empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'upcoming_payment_item.dart';

class UpcomingPaymentsSection extends StatelessWidget {
  const UpcomingPaymentsSection({
    super.key,
    required this.payments,
    required this.onAddCard,
    required this.onCardTap,
  });

  final List<UpcomingPayment> payments;
  final VoidCallback onAddCard;
  final ValueChanged<CardEntity> onCardTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Próximos pagos",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              onPressed: onAddCard,
              tooltip: 'Agregar tarjeta',
              icon: Icon(Icons.add_card_rounded, color: Colors.white),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        if (payments.isEmpty)
          const EmptyState(
            icon: Icons.credit_card_rounded,
            message: 'Agrega tus tarjetas para ver sus próximos pagos',
          )
        else
          for (final (index, payment) in payments.indexed) ...[
            if (index > 0) SizedBox(height: 12.h),
            UpcomingPaymentItem(
              cardName: payment.card.name,
              dueDate: Formatters.shortDate(payment.dueDate),
              daysLeft: payment.daysLeft,
              onTap: () => onCardTap(payment.card),
            ),
          ],
      ],
    );
  }
}
