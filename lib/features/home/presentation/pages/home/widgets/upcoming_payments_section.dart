import 'package:dynora_finance/features/cards/domain/entities/card_entity.dart';
import 'package:dynora_finance/features/cards/domain/entities/card_statement.dart';
import 'package:dynora_finance/features/cards/presentation/utils/card_labels.dart';
import 'package:dynora_finance/shared/utils/formatters.dart';
import 'package:dynora_finance/shared/widgets/empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'section_header.dart';
import 'upcoming_payment_item.dart';

class UpcomingPaymentsSection extends StatelessWidget {
  const UpcomingPaymentsSection({
    super.key,
    required this.payments,
    required this.onSeeCards,
    required this.onCardTap,
  });

  final List<UpcomingCardPayment> payments;
  final VoidCallback onSeeCards;
  final ValueChanged<CardEntity> onCardTap;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: "Próximos pagos",
          actionLabel: "Ver tarjetas",
          onAction: onSeeCards,
        ),
        SizedBox(height: 8.h),
        if (payments.isEmpty)
          const EmptyState(
            icon: Icons.credit_card_rounded,
            message:
                'Agrega tus tarjetas de crédito para ver sus próximos pagos',
          )
        else
          for (final (index, payment) in payments.indexed) ...[
            if (index > 0) SizedBox(height: 10.h),
            UpcomingPaymentItem(
              cardName: payment.card.shortLabel,
              dueDate: Formatters.shortDate(payment.dueDate),
              daysLeft: payment.statement.period.daysUntilPayment(now),
              amount: payment.amount,
              onTap: () => onCardTap(payment.card),
            ),
          ],
      ],
    );
  }
}
