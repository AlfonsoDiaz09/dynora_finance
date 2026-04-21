import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'widgets/financial_summary_card.dart';
import 'widgets/upcoming_payments_section.dart';
import 'widgets/recent_transactions_section.dart';
import 'widgets/quick_actions_section.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10.h),
          FinancialSummaryCard(),
          SizedBox(height: 28.h),
          UpcomingPaymentsSection(),
          SizedBox(height: 28.h),
          RecentTransactionsSection(),
          SizedBox(height: 28.h),
          QuickActionsSection(),
          SizedBox(height: 50.h),
        ],
      ),
    );
  }
}
