import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'section_header.dart';

/// "Deudas y préstamos": who owes you and the loans you owe or made.
class DebtsAndLoansSection extends StatelessWidget {
  const DebtsAndLoansSection({
    super.key,
    required this.rows,
    required this.onSeeLoans,
  });

  final List<Widget> rows;
  final VoidCallback onSeeLoans;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Deudas y préstamos',
          actionLabel: 'Ver préstamos',
          onAction: onSeeLoans,
        ),
        SizedBox(height: 8.h),
        for (final (index, row) in rows.indexed) ...[
          if (index > 0) SizedBox(height: 10.h),
          row,
        ],
      ],
    );
  }
}
