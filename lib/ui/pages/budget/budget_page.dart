import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'widgets/budget_summary_card.dart';
import 'widgets/category_budget_card.dart';

class BudgetPage extends StatelessWidget {
  const BudgetPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121212),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          children: [
            SizedBox(height: 20.h),
            Text(
              "Presupuesto",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20.h),
            BudgetSummaryCard(),
            SizedBox(height: 30.h),
            Text(
              "Por categoría",
              style: TextStyle(color: Colors.white70, fontSize: 16.sp),
            ),
            SizedBox(height: 15.h),
            CategoryBudgetCard(category: "Comida", spent: 320, total: 500),
            SizedBox(height: 15.h),
            CategoryBudgetCard(category: "Transporte", spent: 150, total: 300),
            SizedBox(height: 15.h),
            CategoryBudgetCard(
              category: "Entretenimiento",
              spent: 220,
              total: 250,
            ),
            SizedBox(height: 80.h),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 120.h),
        child: FloatingActionButton(
          backgroundColor: Colors.purpleAccent,
          onPressed: () {},
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}
