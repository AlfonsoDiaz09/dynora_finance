import 'package:dynora_finance/app/theme/app_colors.dart';
import 'package:dynora_finance/features/debts/presentation/utils/debtor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Overlapping circles with the initial of each person who owes you: orange
/// ring while pending, green ring and check once paid.
class DebtorAvatars extends StatelessWidget {
  const DebtorAvatars({
    super.key,
    required this.debtors,
    required this.onTap,
    this.maxVisible = 3,
  });

  final List<Debtor> debtors;
  final VoidCallback onTap;
  final int maxVisible;

  @override
  Widget build(BuildContext context) {
    // One circle per person even if they appear in several movements.
    final unique = <String, Debtor>{};
    for (final debtor in debtors) {
      final current = unique[debtor.personId];
      // A person counts as pending while any of their debts is pending.
      if (current == null || (current.isPaid && !debtor.isPaid)) {
        unique[debtor.personId] = debtor;
      }
    }
    final people = unique.values.toList();
    final visible = people.take(maxVisible).toList();
    final hidden = people.length - visible.length;
    final size = 26.r;
    final step = size * 0.7;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 4.h),
        child: SizedBox(
          height: size,
          width: step * (visible.length + (hidden > 0 ? 1 : 0) - 1) + size,
          child: Stack(
            children: [
              for (final (index, debtor) in visible.indexed)
                Positioned(
                  left: step * index,
                  child: _Circle(debtor: debtor, size: size),
                ),
              if (hidden > 0)
                Positioned(
                  left: step * visible.length,
                  child: _MoreCircle(count: hidden, size: size),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Circle extends StatelessWidget {
  const _Circle({required this.debtor, required this.size});

  final Debtor debtor;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color = debtor.isPaid ? AppColors.success : AppColors.warning;
    return SizedBox.square(
      dimension: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 2),
            ),
            child: Text(
              debtor.initial,
              style: TextStyle(
                color: Colors.white,
                fontSize: 11.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (debtor.isPaid)
            Positioned(
              right: -3,
              bottom: -3,
              child: Icon(
                Icons.check_circle_rounded,
                color: AppColors.success,
                size: 12.sp,
              ),
            ),
        ],
      ),
    );
  }
}

class _MoreCircle extends StatelessWidget {
  const _MoreCircle({required this.count, required this.size});

  final int count;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surface,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.textPrimary38, width: 2),
      ),
      child: Text(
        '+$count',
        style: TextStyle(color: Colors.white, fontSize: 10.sp),
      ),
    );
  }
}
