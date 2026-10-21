import 'package:dynora_finance/app/theme/app_colors.dart';
import 'package:dynora_finance/shared/utils/formatters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// "Te deben" shortcut to the debts page.
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(18.r),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.success.withValues(alpha: 0.2),
              child: const Icon(
                Icons.handshake_rounded,
                color: AppColors.success,
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Te deben',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    switch (people) {
                      0 => 'Todos al corriente',
                      1 => '1 persona',
                      _ => '$people personas',
                    },
                    style: TextStyle(
                      color: AppColors.textPrimary70,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              Formatters.currency(total),
              style: const TextStyle(
                color: AppColors.success,
                fontWeight: FontWeight.bold,
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppColors.textPrimary70),
          ],
        ),
      ),
    );
  }
}
