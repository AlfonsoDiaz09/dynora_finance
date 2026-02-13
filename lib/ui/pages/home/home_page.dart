import 'package:flutter/material.dart';
import 'widgets/financial_summary_card.dart';
import 'widgets/upcoming_payments_section.dart';
import 'widgets/recent_transactions_section.dart';
import 'widgets/quick_actions_section.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff0F0F1A),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              FinancialSummaryCard(),
              SizedBox(height: 28),
              UpcomingPaymentsSection(),
              SizedBox(height: 28),
              RecentTransactionsSection(),
              SizedBox(height: 28),
              QuickActionsSection(),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
