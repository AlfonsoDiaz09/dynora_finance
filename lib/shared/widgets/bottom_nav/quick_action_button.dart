import 'package:dynora_finance/app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class QuickActionButton extends StatelessWidget {
  const QuickActionButton({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onFastActionTap,
  });

  final int currentIndex;
  final Function(int) onTap;
  final VoidCallback onFastActionTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(2),
      borderRadius: BorderRadius.circular(100.r),
      onLongPress: onFastActionTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        width: 60.w,
        height: 60.h,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: currentIndex == 2 ? null : AppColors.surface,
          gradient: currentIndex == 2
              ? LinearGradient(colors: [AppColors.primary, AppColors.secondary])
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.purpleAccent,
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Icon(
          Icons.home_rounded,
          color: currentIndex == 2
              ? Colors.white
              : AppColors.textPrimary38,
          size: 28.sp,
        ),
      ),
    );
  }
}
