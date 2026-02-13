import 'package:flutter/material.dart';

class UpcomingPaymentItem extends StatelessWidget {
  const UpcomingPaymentItem({
    super.key,
    required this.cardName,
    required this.dueDate,
    required this.daysLeft,
  });

  final String cardName;
  final String dueDate;
  final int daysLeft;

  Color get urgencyColor {
    if (daysLeft <= 3) return Colors.redAccent;
    if (daysLeft <= 7) return Colors.orangeAccent;
    return Colors.greenAccent;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: urgencyColor.withOpacity(0.2),
            child: Icon(Icons.credit_card, color: urgencyColor),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cardName,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  "Vence: $dueDate",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            "$daysLeft días",
            style: TextStyle(color: urgencyColor, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
