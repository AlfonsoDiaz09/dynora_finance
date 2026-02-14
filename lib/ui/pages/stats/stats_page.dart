import 'package:flutter/material.dart';
import 'widgets/month_selector.dart';
import 'widgets/statistics_summary_card.dart';
import 'widgets/category_chart.dart';
import 'widgets/trend_section.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0F0F1A),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: const [

            SizedBox(height: 20),

            Text(
              "Estadísticas",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 20),

            MonthSelector(),

            SizedBox(height: 20),

            StatisticsSummaryCard(),

            SizedBox(height: 30),

            CategoryChart(),

            SizedBox(height: 30),

            TrendSection(),

            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
