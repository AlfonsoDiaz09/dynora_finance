import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class QuickActionButton extends StatelessWidget {
  const QuickActionButton({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onFastActionTap,});

  final int currentIndex;
  final Function(int) onTap;
  final VoidCallback onFastActionTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () => onTap(2),
        onLongPress: onFastActionTap,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          width: 60.w,
          height: 60.h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Color(0xff7F00FF), Color(0xffE100FF)],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.purpleAccent,
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(
            currentIndex == 2 ? Icons.home_rounded : Icons.home_outlined,
            color: Colors.white,
            size: 28.sp,
          ),
        ),
      );
  }
}