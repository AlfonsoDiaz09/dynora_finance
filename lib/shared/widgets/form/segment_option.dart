import 'package:dynora_finance/app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// One option of a segmented selector (place several inside a `Row`).
class SegmentOption extends StatelessWidget {
  const SegmentOption({
    super.key,
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14.r),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: selected ? color : Colors.transparent),
        ),
        alignment: Alignment.center,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            style: TextStyle(
              color: selected ? color : AppColors.textPrimary70,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
