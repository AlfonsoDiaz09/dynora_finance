import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BottomNavItem extends StatelessWidget {
  const BottomNavItem({
    super.key,
    required this.icon,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  final IconData icon;
  final int index;
  final int currentIndex;
  final Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    final bool isActive = currentIndex == index;

    return InkWell(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 250),
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
        child: Icon(
          icon,
          size: 26.sp,
          color: isActive
              ? Color(0xffE100FF)
              : Colors.white.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}
