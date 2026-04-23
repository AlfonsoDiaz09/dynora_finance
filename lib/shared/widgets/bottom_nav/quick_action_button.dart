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
          color: currentIndex == 2 ? null : Color(0xff1A1A2E),
          gradient: currentIndex == 2
              ? LinearGradient(colors: [Color(0xff7F00FF), Color(0xffE100FF)])
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
              : Colors.white.withValues(alpha: 0.4),
          size: 28.sp,
        ),
      ),
    );
  }
}
