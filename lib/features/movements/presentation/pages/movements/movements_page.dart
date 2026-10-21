import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'widgets/movements_summary_card.dart';
import 'widgets/movement_filter_bar.dart';
import 'widgets/movement_group.dart';

class MovementsPage extends StatelessWidget {
  const MovementsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          child: MovementsSummaryCard(),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: MovementFilterBar(),
        ),
        SizedBox(height: 20.h),
        Expanded(
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            children: [
              MovementGroup(date: "Hoy"),
              SizedBox(height: 20.h),
              MovementGroup(date: "Ayer"),
              SizedBox(height: 50.h),
            ],
          ),
        ),
      ],
    );
  }
}
