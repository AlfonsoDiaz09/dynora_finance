import 'package:dynora_finance/shared/utils/formatters.dart';
import 'package:dynora_finance/shared/widgets/info_row_card.dart';
import 'package:flutter/material.dart';

/// Loans row: what is owed and what's next.
class LoansSummaryCard extends StatelessWidget {
  const LoansSummaryCard({
    super.key,
    required this.title,
    required this.amountLabel,
    required this.remaining,
    required this.status,
    required this.statusColor,
    required this.onTap,
  });

  final String title;

  /// `debes` or `te deben`.
  final String amountLabel;
  final double remaining;
  final String status;
  final Color statusColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InfoRowCard(
      icon: Icons.account_balance_rounded,
      color: statusColor,
      title: title,
      subtitle: status,
      subtitleColor: statusColor,
      trailing: AmountCaption(
        amount: Formatters.currency(remaining),
        caption: amountLabel,
      ),
      onTap: onTap,
    );
  }
}
