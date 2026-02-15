import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'widgets/month_selector.dart';
import 'widgets/statistics_summary_card.dart';
import 'widgets/category_chart.dart';
import 'widgets/trend_section.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff0F0F1A),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.only(
            left: 20.w,
            right: 20.w,
            top: 20.h,
            bottom: 40.h,
          ),
          children: [
            Text(
              "Estadísticas",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20.h),
            MonthSelector(),
            SizedBox(height: 20.h),
            StatisticsSummaryCard(),
            SizedBox(height: 30.h),
            CategoryChart(),
            SizedBox(height: 30.h),
            TrendSection(),
          ],
        ),
      ),
    );
  }
}
