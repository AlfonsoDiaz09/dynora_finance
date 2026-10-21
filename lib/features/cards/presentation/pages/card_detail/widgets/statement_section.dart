import 'package:dynora_finance/app/theme/app_colors.dart';
import 'package:dynora_finance/features/cards/domain/entities/card_statement.dart';
import 'package:dynora_finance/features/cards/presentation/utils/statement_status_style.dart';
import 'package:dynora_finance/features/categories/domain/entities/category_entity.dart';
import 'package:dynora_finance/features/movements/domain/entities/movement_entity.dart';
import 'package:dynora_finance/features/movements/presentation/pages/movements/widgets/movement_item.dart';
import 'package:dynora_finance/shared/utils/formatters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// One billing period: dates, payment info, total and its movements.
class StatementSection extends StatelessWidget {
  const StatementSection({
    super.key,
    required this.statement,
    required this.categories,
    required this.onMovementTap,
    required this.onPaymentTap,
  });

  final CardStatement statement;
  final Map<String, CategoryEntity> categories;
  final ValueChanged<MovementEntity> onMovementTap;

  /// Opens the form to register or edit the payment of [statement].
  final VoidCallback onPaymentTap;

  @override
  Widget build(BuildContext context) {
    final period = statement.period;
    final now = DateTime.now();
    final (statusLabel, statusColor) = statementStatusStyle(statement, now);
    final payment = statement.payment;
    final canPay = payment != null || statement.total > 0;
    final fundingMonth = Formatters.monthYear(period.fundingMonth().start);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '${Formatters.shortDate(period.start)} – ${Formatters.shortDate(period.end)}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                statusLabel,
                style: TextStyle(color: statusColor, fontSize: 12.sp),
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        Row(
          children: [
            Expanded(
              child: Text(
                'Pago el ${Formatters.shortDate(period.paymentDate)} · '
                'con tu ingreso de $fundingMonth',
                style: TextStyle(
                  color: AppColors.textPrimary70,
                  fontSize: 12.sp,
                ),
              ),
            ),
            Text(
              Formatters.currency(statement.total),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        if (payment != null) ...[
          SizedBox(height: 12.h),
          _PaymentBanner(
            icon: Icons.check_circle_rounded,
            color: statement.remaining == 0
                ? AppColors.success
                : AppColors.warning,
            text: statement.remaining == 0
                ? 'Pagado el ${Formatters.shortDate(payment.paidAt)} · '
                      '${Formatters.currency(payment.amount)}'
                : 'Pago parcial de ${Formatters.currency(payment.amount)} '
                      'el ${Formatters.shortDate(payment.paidAt)} · '
                      'faltan ${Formatters.currency(statement.remaining)}',
            action: 'Editar',
            onTap: onPaymentTap,
          ),
        ] else if (canPay) ...[
          SizedBox(height: 12.h),
          _PaymentBanner(
            icon: Icons.payments_rounded,
            color: statusColor,
            text: statement.status(now) == StatementStatus.overdue
                ? '¿Ya lo pagaste? Regístralo para llevar el control'
                : 'Registra el pago cuando lo hagas',
            action: 'Registrar pago',
            onTap: onPaymentTap,
          ),
        ],
        if (statement.movements.isEmpty)
          Padding(
            padding: EdgeInsets.only(top: 12.h),
            child: Text(
              'Sin movimientos en este periodo',
              style: TextStyle(color: AppColors.textPrimary38, fontSize: 13.sp),
            ),
          )
        else
          for (final movement in statement.movements) ...[
            SizedBox(height: 12.h),
            MovementItem(
              title: movement.title,
              category:
                  '${categories[movement.categoryId]?.name ?? 'Sin categoría'} · '
                  '${Formatters.shortDate(movement.date)}',
              amount: movement.amount,
              isExpense: movement.isExpense,
              onTap: () => onMovementTap(movement),
            ),
          ],
      ],
    );
  }
}

class _PaymentBanner extends StatelessWidget {
  const _PaymentBanner({
    required this.icon,
    required this.color,
    required this.text,
    required this.action,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String text;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(14.w, 6.h, 4.w, 6.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: AppColors.textPrimary85, fontSize: 12.sp),
            ),
          ),
          TextButton(
            onPressed: onTap,
            child: Text(action, style: TextStyle(color: color)),
          ),
        ],
      ),
    );
  }
}
