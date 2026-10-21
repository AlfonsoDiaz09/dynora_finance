import 'package:dynora_finance/app/router/router.dart';
import 'package:dynora_finance/app/theme/app_colors.dart';
import 'package:dynora_finance/features/debts/presentation/utils/debtor.dart';
import 'package:dynora_finance/shared/utils/formatters.dart';
import 'package:dynora_finance/shared/widgets/form/form_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

/// Who owes you, how much, and whether and when they paid.
class DebtorsSheet extends StatelessWidget {
  const DebtorsSheet({super.key, required this.title, required this.debtors});

  final String title;
  final List<Debtor> debtors;

  static Future<void> show(
    BuildContext context, {
    required String title,
    required List<Debtor> debtors,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => DebtorsSheet(title: title, debtors: debtors),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pending = debtors
        .where((d) => !d.isPaid)
        .fold<double>(0, (sum, d) => sum + d.amount);
    final paid = debtors
        .where((d) => d.isPaid)
        .fold<double>(0, (sum, d) => sum + d.amount);

    return FormSheet(
      title: title,
      children: [
        for (final debtor in debtors) _DebtorRow(debtor: debtor),
        Divider(height: 28.h, color: Colors.white24),
        _Total(label: 'Pendiente', value: pending, color: AppColors.warning),
        SizedBox(height: 6.h),
        _Total(label: 'Ya te pagaron', value: paid, color: AppColors.success),
        SizedBox(height: 16.h),
        TextButton.icon(
          onPressed: () {
            Navigator.of(context).pop();
            context.push(AppRoutes.debts);
          },
          icon: const Icon(Icons.handshake_rounded),
          label: const Text('Ver todo en Me deben'),
        ),
      ],
    );
  }
}

class _DebtorRow extends StatelessWidget {
  const _DebtorRow({required this.debtor});

  final Debtor debtor;

  @override
  Widget build(BuildContext context) {
    final paidAt = debtor.paidAt;
    final color = paidAt != null ? AppColors.success : AppColors.warning;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Container(
            width: 40.r,
            height: 40.r,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 2),
            ),
            child: Text(
              debtor.initial,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  debtor.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (debtor.detail case final detail?)
                  Text(
                    detail,
                    style: TextStyle(
                      color: AppColors.textPrimary70,
                      fontSize: 12.sp,
                    ),
                  ),
                Text(
                  paidAt != null
                      ? 'Pagado el ${Formatters.shortDate(paidAt)}'
                      : 'Pendiente',
                  style: TextStyle(color: color, fontSize: 12.sp),
                ),
              ],
            ),
          ),
          Text(
            Formatters.currency(debtor.amount),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _Total extends StatelessWidget {
  const _Total({required this.label, required this.value, required this.color});

  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(label, style: TextStyle(color: AppColors.textPrimary70)),
        ),
        Text(
          Formatters.currency(value),
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
