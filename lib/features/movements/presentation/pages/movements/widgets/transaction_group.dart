import 'package:dynora_finance/app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'transaction_item.dart';

class TransactionGroup extends StatelessWidget {
  final String date;

  const TransactionGroup({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          date,
          style: TextStyle(color: AppColors.textPrimary70, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12.h),
        TransactionItem(
          title: "Amazon",
          category: "Compras",
          amount: 320,
          isExpense: true,
        ),
        SizedBox(height: 12.h),
        TransactionItem(
          title: "Nómina",
          category: "Ingreso",
          amount: 15000,
          isExpense: false,
        ),
      ],
    );
  }
}
