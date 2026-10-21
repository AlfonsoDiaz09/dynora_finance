import 'package:dynora_finance/app/theme/app_colors.dart';
import 'package:dynora_finance/shared/utils/formatters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Tappable field showing a date (or a placeholder) that opens a picker.
class DateField extends StatelessWidget {
  const DateField({
    super.key,
    required this.date,
    required this.onChanged,
    this.placeholder = 'Elegir fecha',
    this.firstDate,
    this.lastDate,
  });

  final DateTime? date;
  final ValueChanged<DateTime> onChanged;
  final String placeholder;
  final DateTime? firstDate;
  final DateTime? lastDate;

  Future<void> _pick(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: date ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(2000),
      lastDate: lastDate ?? DateTime(2100),
    );
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final value = date;
    return InkWell(
      borderRadius: BorderRadius.circular(16.r),
      onTap: () => _pick(context),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_rounded, color: AppColors.textPrimary70),
            SizedBox(width: 12.w),
            Text(
              value == null
                  ? placeholder
                  : '${value.day} ${Formatters.shortMonthYear(value)}',
              style: TextStyle(
                color: value == null ? AppColors.textPrimary38 : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
