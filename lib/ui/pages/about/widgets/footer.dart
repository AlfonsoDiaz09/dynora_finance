import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "Versión 0.0.1",
          style: TextStyle(fontSize: 12.sp, color: Colors.white38),
        ),
        SizedBox(height: 4.h),
        Text(
          "© 2026 Alfionyx · Desarrollado por Alfonso Díaz",
          style: TextStyle(fontSize: 12.sp, color: Colors.white38),
        ),
      ],
    );
  }
}
