import 'package:dynora_finance/ui/widgets/bottom_nav/bottom_nav_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
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
              BottomNavItem(icon: Icons.swap_horiz, index: 0, currentIndex: currentIndex, onTap: onTap),
              BottomNavItem(icon: Icons.bar_chart_rounded, index: 1, currentIndex: currentIndex, onTap: onTap),
              SizedBox(width: 60),
              BottomNavItem(icon: Icons.pie_chart_outline, index: 3, currentIndex: currentIndex, onTap: onTap),
              BottomNavItem(icon: Icons.person_outline, index: 4, currentIndex: currentIndex, onTap: onTap),
            ],
          ),
        ],
      ),
    );
  }
}
