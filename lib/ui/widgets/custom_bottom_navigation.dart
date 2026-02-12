import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final VoidCallback onFastActionTap;

  const CustomBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onFastActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.h,
      margin: EdgeInsets.only(bottom: 25.h, left: 15.w, right: 15.w),
      decoration: BoxDecoration(
        color: Color(0xff1A1A2E),
        borderRadius: BorderRadius.all(Radius.circular(25.r)),
        boxShadow: [
          BoxShadow(color: Colors.purpleAccent, blurRadius: 5, spreadRadius: 2),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(Icons.swap_horiz, 0),
              _navItem(Icons.bar_chart_rounded, 1),
              SizedBox(width: 60),
              _navItem(Icons.pie_chart_outline, 3),
              _navItem(Icons.person_outline, 4),
            ],
          ),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, int index) {
    final bool isActive = currentIndex == index;

    return GestureDetector(
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
