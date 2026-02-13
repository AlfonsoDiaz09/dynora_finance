import 'package:flutter/material.dart';
import 'upcoming_payment_item.dart';

class UpcomingPaymentsSection extends StatelessWidget {
  const UpcomingPaymentsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Próximos pagos",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        SizedBox(height: 16),

        UpcomingPaymentItem(
          cardName: "BBVA Azul",
          dueDate: "18 Feb",
          daysLeft: 3,
        ),

        SizedBox(height: 12),

        UpcomingPaymentItem(cardName: "Nu", dueDate: "22 Feb", daysLeft: 7),
      ],
    );
  }
}
