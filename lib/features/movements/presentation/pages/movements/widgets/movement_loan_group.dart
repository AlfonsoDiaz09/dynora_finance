import 'package:dynora_finance/app/theme/app_colors.dart';
import 'package:dynora_finance/features/loans/domain/entities/loan_entity.dart';
import 'package:dynora_finance/features/loans/domain/entities/loan_summary.dart';
import 'package:dynora_finance/features/loans/presentation/utils/loan_labels.dart';
import 'package:dynora_finance/features/movements/domain/entities/month_ledger.dart';
import 'package:dynora_finance/features/movements/presentation/cubit/movements_cubit.dart';
import 'package:dynora_finance/shared/utils/formatters.dart';
import 'package:dynora_finance/shared/widgets/info_row_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'movement_item.dart';

/// "Préstamos": installments of the month you pay or collect.
class MovementLoanGroupView extends StatelessWidget {
  const MovementLoanGroupView({
    super.key,
    required this.group,
    required this.onLoanTap,
  });

  final MovementLoanGroup group;
  final ValueChanged<LoanEntity> onLoanTap;

  @override
  Widget build(BuildContext context) {
    final net = group.net;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Préstamos',
                  style: TextStyle(
                    color: AppColors.textPrimary85,
                    fontWeight: FontWeight.bold,
                    fontSize: 13.sp,
                  ),
                ),
              ),
              Text(
                '${net >= 0 ? '+' : '-'}${Formatters.currency(net.abs())}',
                style: TextStyle(
                  color: AppColors.textPrimary70,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        for (final item in group.installments) ...[
          SizedBox(height: 8.h),
          _LoanInstallmentItem(item: item, onTap: () => onLoanTap(item.loan)),
        ],
      ],
    );
  }
}

class _LoanInstallmentItem extends StatelessWidget {
  const _LoanInstallmentItem({required this.item, required this.onTap});

  final LedgerLoanInstallment item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final loan = item.loan;
    final number = item.installment.installment.number;
    final (status, color) = _status();

    return MovementItem(
      title: loan.name,
      // `Pago 3/12 · vence 15 Oct`
      category:
          '${loan.isLent ? 'Cobro' : 'Pago'} $number/${item.installmentCount}'
          ' · vence ${Formatters.shortDate(item.dueDate)}',
      amount: item.amount,
      isExpense: !item.isIncome,
      icon: loan.kind.icon,
      iconColor: color,
      onTap: onTap,
      footer: Padding(
        padding: EdgeInsets.only(top: 6.h),
        child: Align(
          alignment: Alignment.centerLeft,
          child: StatusPill(label: status, color: color),
        ),
      ),
    );
  }

  (String, Color) _status() {
    final style = installmentStatusStyle(item.installment);
    return item.installment.status == InstallmentStatus.paid
        ? (item.loan.direction.paidWord, style.$2)
        : style;
  }
}
