import 'package:dynora_finance/app/theme/app_colors.dart';
import 'package:dynora_finance/shared/utils/formatters.dart';
import 'package:dynora_finance/shared/widgets/info_row_card.dart';
import 'package:flutter/material.dart';

/// "Te deben" row: shared purchases people still owe you.
class DebtsSummaryCard extends StatelessWidget {
  const DebtsSummaryCard({
    super.key,
    required this.total,
    required this.people,
    required this.onTap,
  });

  final double total;
  final int people;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InfoRowCard(
      icon: Icons.handshake_rounded,
      color: AppColors.success,
      title: 'Te deben',
      subtitle: switch (people) {
        0 => 'Todos al corriente',
        1 => 'Compras compartidas · 1 persona',
        _ => 'Compras compartidas · $people personas',
      },
      trailing: AmountCaption(
        amount: Formatters.currency(total),
        caption: 'por cobrar',
        color: AppColors.success,
      ),
      onTap: onTap,
    );
  }
}
