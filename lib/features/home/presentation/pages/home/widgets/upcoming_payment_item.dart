import 'package:dynora_finance/shared/utils/formatters.dart';
import 'package:dynora_finance/shared/widgets/info_row_card.dart';
import 'package:flutter/material.dart';

class UpcomingPaymentItem extends StatelessWidget {
  const UpcomingPaymentItem({
    super.key,
    required this.cardName,
    required this.dueDate,
    required this.daysLeft,
    required this.amount,
    this.onTap,
  });

  final String cardName;
  final String dueDate;
  final int daysLeft;

  /// Statement total to pay on [dueDate].
  final double amount;
  final VoidCallback? onTap;

  bool get isOverdue => daysLeft < 0;

  /// Short label for the pill: `Hoy`, `1 día`, `12 días`, `Vencido`.
  String get daysLeftLabel => switch (daysLeft) {
    < 0 => "Vencido",
    0 => "Hoy",
    1 => "1 día",
    _ => "$daysLeft días",
  };

  Color get urgencyColor {
    if (daysLeft <= 3) return Colors.redAccent;
    if (daysLeft <= 7) return Colors.orangeAccent;
    return Colors.greenAccent;
  }

  @override
  Widget build(BuildContext context) {
    return InfoRowCard(
      icon: Icons.credit_card_rounded,
      color: urgencyColor,
      title: cardName,
      subtitle:
          "${isOverdue ? 'Venció' : 'Vence'} $dueDate · "
          "${Formatters.currency(amount)}",
      trailing: StatusPill(label: daysLeftLabel, color: urgencyColor),
      onTap: onTap,
    );
  }
}
