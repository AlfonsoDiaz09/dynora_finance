import 'package:dynora_finance/app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.message, this.icon});

  final String message;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          if (icon != null) ...[
            Icon(icon, color: AppColors.textPrimary38, size: 28.sp),
            SizedBox(height: 8.h),
          ],
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textPrimary70, fontSize: 13.sp),
          ),
        ],
      ),
    );
  }
}
