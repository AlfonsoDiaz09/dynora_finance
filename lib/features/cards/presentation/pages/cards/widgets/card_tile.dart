import 'package:dynora_finance/app/theme/app_colors.dart';
import 'package:dynora_finance/features/cards/domain/entities/card_statement.dart';
import 'package:dynora_finance/features/cards/presentation/cubit/cards_cubit.dart';
import 'package:dynora_finance/features/cards/presentation/utils/statement_status_style.dart';
import 'package:dynora_finance/features/cards/presentation/utils/card_labels.dart';
import 'package:dynora_finance/shared/utils/formatters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CardTile extends StatelessWidget {
  const CardTile({super.key, required this.overview, required this.onTap});

  final CardOverview overview;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final card = overview.card;
    final color = Color(card.colorValue);
    final upcoming = overview.upcoming;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(18.r),
          border: Border(left: BorderSide(color: color, width: 4)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.2),
              child: Icon(Icons.credit_card_rounded, color: color),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    card.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${card.type.label} · ${card.maskedDigits}',
                    style: TextStyle(
                      color: AppColors.textPrimary70,
                      fontSize: 12.sp,
                    ),
                  ),
                  if (card.hasBillingCycle)
                    Text(
                      'Corte día ${card.cutoffDay} · Pago día ${card.paymentDueDay}',
                      style: TextStyle(
                        color: AppColors.textPrimary38,
                        fontSize: 12.sp,
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  upcoming != null
                      ? Formatters.currency(
                          upcoming.remaining > 0
                              ? upcoming.remaining
                              : upcoming.total,
                        )
                      : Formatters.currency(overview.monthExpense),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (upcoming != null)
                  _StatusText(statement: upcoming)
                else
                  Text(
                    'Gastos del mes',
                    style: TextStyle(
                      color: AppColors.textPrimary70,
                      fontSize: 12.sp,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusText extends StatelessWidget {
  const _StatusText({required this.statement});

  final CardStatement statement;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final status = statement.status(now);
    final (label, color) = statementStatusStyle(statement, now);
    final text = switch (status) {
      StatementStatus.open || StatementStatus.pending =>
        'Pagar el ${Formatters.shortDate(statement.period.paymentDate)}',
      _ => label,
    };
    return Text(
      text,
      style: TextStyle(
        color: status == StatementStatus.open ? AppColors.textPrimary70 : color,
        fontSize: 12.sp,
      ),
    );
  }
}
