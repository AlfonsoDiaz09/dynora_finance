import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppbarHelp extends StatelessWidget {
  const AppbarHelp({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.05),
        ),
        child: const Icon(Icons.help_outline, color: Colors.white),
      ),
    );
  }
}
