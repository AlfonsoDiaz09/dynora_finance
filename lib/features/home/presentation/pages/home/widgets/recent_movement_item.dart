import 'package:dynora_finance/core/enums/movement_type.dart';
import 'package:dynora_finance/shared/utils/formatters.dart';
import 'package:dynora_finance/shared/widgets/info_row_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RecentMovementItem extends StatelessWidget {
  const RecentMovementItem({
    super.key,
    required this.title,
    required this.date,
    required this.amount,
    required this.type,
    this.icon,
    this.iconColor,
    this.onTap,
  });

  final String title;

  /// Subtitle: when (and what) it was.
  final String date;
  final double amount;
  final MovementType type;

  /// Category icon and color; an in/out arrow when not given.
  final IconData? icon;
  final Color? iconColor;
  final VoidCallback? onTap;

  Color get amountColor => switch (type) {
    MovementType.income => Colors.greenAccent,
    MovementType.expense => Colors.redAccent,
  };

  String get formattedAmount {
    final prefix = type == MovementType.expense ? "-" : "+";
    return "$prefix${Formatters.currency(amount)}";
  }

  @override
  Widget build(BuildContext context) {
    return InfoRowCard(
      icon:
          icon ??
          (type == MovementType.income
              ? Icons.arrow_downward_rounded
              : Icons.arrow_upward_rounded),
      color: iconColor ?? amountColor,
      title: title,
      subtitle: date,
      trailing: Text(
        formattedAmount,
        style: TextStyle(
          color: amountColor,
          fontWeight: FontWeight.bold,
          fontSize: 14.sp,
        ),
      ),
      onTap: onTap,
    );
  }
}
