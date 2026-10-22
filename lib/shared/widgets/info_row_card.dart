import 'package:dynora_finance/app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Card row: icon, title and subtitle, and a trailing widget kept apart
/// from the text, which shortens with "…" instead of pushing it.
class InfoRowCard extends StatelessWidget {
  const InfoRowCard({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    this.subtitle,
    this.subtitleColor,
    this.trailing,
    this.onTap,
  });

  final IconData icon;

  /// Accent of the icon badge.
  final Color color;
  final String title;
  final String? subtitle;
  final Color? subtitleColor;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          child: Row(
            children: [
              Container(
                width: 40.r,
                height: 40.r,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(icon, color: color, size: 20.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14.sp,
                      ),
                    ),
                    if (subtitle case final text?) ...[
                      SizedBox(height: 2.h),
                      Text(
                        text,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: subtitleColor ?? AppColors.textPrimary70,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing case final widget?) ...[
                SizedBox(width: 12.w),
                widget,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact colored label for the right side of an [InfoRowCard].
class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// Amount with a caption below, right aligned (e.g. "$1,200.00 / debes").
class AmountCaption extends StatelessWidget {
  const AmountCaption({
    super.key,
    required this.amount,
    required this.caption,
    this.color = Colors.white,
  });

  final String amount;
  final String caption;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          amount,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 14.sp,
          ),
        ),
        Text(
          caption,
          style: TextStyle(color: AppColors.textPrimary70, fontSize: 11.sp),
        ),
      ],
    );
  }
}
