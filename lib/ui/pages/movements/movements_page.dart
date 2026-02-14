import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'widgets/transactions_summary_card.dart';
import 'widgets/transaction_filter_bar.dart';
import 'widgets/transaction_group.dart';

class MovementsPage extends StatelessWidget {
  const MovementsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff0F0F1A),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 20.h),
              child: Text(
                "Movimientos",
                style: TextStyle(color: Colors.white, fontSize: 21.sp),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
              child: TransactionsSummaryCard(),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: TransactionFilterBar(),
            ),
            SizedBox(height: 20.h),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                children: [
                  TransactionGroup(date: "Hoy"),
                  SizedBox(height: 20.h),
                  TransactionGroup(date: "Ayer"),
                  SizedBox(height: 50.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
