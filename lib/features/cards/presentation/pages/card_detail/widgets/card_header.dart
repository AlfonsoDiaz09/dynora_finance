import 'package:dynora_finance/app/theme/app_colors.dart';
import 'package:dynora_finance/features/cards/domain/entities/card_entity.dart';
import 'package:dynora_finance/features/cards/domain/entities/card_statement.dart';
import 'package:dynora_finance/features/cards/presentation/utils/card_labels.dart';
import 'package:dynora_finance/features/cards/presentation/utils/statement_status_style.dart';
import 'package:dynora_finance/shared/utils/formatters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Card summary. For billed cards it shows the selected [statement]: amount
/// to pay against the credit limit, payment date and funding income.
class CardHeader extends StatelessWidget {
  const CardHeader({
    super.key,
    required this.card,
    required this.onEdit,
    this.statement,
  });

  final CardEntity card;
  final VoidCallback onEdit;

  /// Selected billing period; `null` for debit cards.
  final CardStatement? statement;

  @override
  Widget build(BuildContext context) {
    final color = Color(card.colorValue);
    final statement = this.statement;

    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 8.w, 20.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, Color.lerp(color, AppColors.background, 0.6)!],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${card.type.label}  ${card.maskedDigits}',
                  style: TextStyle(
                    color: AppColors.textPrimary85,
                    letterSpacing: 1,
                  ),
                ),
              ),
              IconButton(
                onPressed: onEdit,
                tooltip: 'Editar tarjeta',
                icon: const Icon(Icons.edit_rounded, color: Colors.white),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(right: 12.w),
            child: statement == null
                ? _DebitSummary(card: card)
                : _StatementSummary(
                    card: card,
                    statement: statement,
                    onEdit: onEdit,
                  ),
          ),
        ],
      ),
    );
  }
}

class _DebitSummary extends StatelessWidget {
  const _DebitSummary({required this.card});

  final CardEntity card;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          card.name,
          style: TextStyle(
            color: Colors.white,
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          'Sin fecha de corte ni límite',
          style: TextStyle(color: AppColors.textPrimary70, fontSize: 13.sp),
        ),
      ],
    );
  }
}

class _StatementSummary extends StatelessWidget {
  const _StatementSummary({
    required this.card,
    required this.statement,
    required this.onEdit,
  });

  final CardEntity card;
  final CardStatement statement;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final period = statement.period;
    final (statusLabel, statusColor) = statementStatusStyle(statement, now);
    final pending = statement.remaining > 0;
    final amount = pending ? statement.remaining : statement.total;
    final limit = card.creditLimit;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                pending ? 'Total a pagar' : 'Total del periodo',
                style: TextStyle(color: AppColors.textPrimary85),
              ),
            ),
            _Chip(label: statusLabel, color: statusColor, filled: true),
          ],
        ),
        SizedBox(height: 4.h),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: Formatters.currency(amount),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (limit != null)
                TextSpan(
                  text: '  / ${Formatters.currency(limit)}',
                  style: TextStyle(
                    color: AppColors.textPrimary70,
                    fontSize: 15.sp,
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: 14.h),
        if (limit != null)
          _LimitBar(used: statement.total, limit: limit)
        else
          InkWell(
            onTap: onEdit,
            child: Text(
              'Agrega tu límite de crédito para ver cuánto usas',
              style: TextStyle(
                color: AppColors.textPrimary85,
                fontSize: 12.sp,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.textPrimary70,
              ),
            ),
          ),
        SizedBox(height: 16.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: [
            _Chip(
              icon: Icons.event_rounded,
              label: 'Fecha límite ${_fullDate(period.paymentDate)}',
            ),
            _Chip(
              icon: Icons.content_cut_rounded,
              label:
                  'Corte día ${card.cutoffDay} · Pago día ${card.paymentDueDay}',
            ),
          ],
        ),
      ],
    );
  }

  /// `20 Oct 2026`
  static String _fullDate(DateTime date) =>
      '${date.day} ${Formatters.shortMonthYear(date)}';
}

/// Share of the credit limit taken by the statement.
class _LimitBar extends StatelessWidget {
  const _LimitBar({required this.used, required this.limit});

  final double used;
  final double limit;

  @override
  Widget build(BuildContext context) {
    final ratio = limit > 0 ? (used / limit).clamp(0.0, 1.0) : 0.0;
    final percent = limit > 0 ? (used / limit * 100).round() : 0;
    final available = limit - used;
    final color = ratio >= 0.8
        ? AppColors.error
        : ratio >= 0.5
        ? AppColors.warning
        : AppColors.success;

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10.r),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 10.h,
            backgroundColor: Colors.white24,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(
              child: Text(
                '$percent% de tu límite',
                style: TextStyle(
                  color: AppColors.textPrimary85,
                  fontSize: 12.sp,
                ),
              ),
            ),
            Text(
              available >= 0
                  ? 'Disponible ${Formatters.currency(available)}'
                  : 'Excedido ${Formatters.currency(-available)}',
              style: TextStyle(
                color: available >= 0
                    ? AppColors.textPrimary85
                    : AppColors.error,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    this.icon,
    this.color = Colors.white,
    this.filled = false,
  });

  final String label;
  final IconData? icon;
  final Color color;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: filled
            ? AppColors.background.withValues(alpha: 0.55)
            : Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: color, size: 14.sp),
            SizedBox(width: 6.w),
          ],
          Text(
            label,
            style: TextStyle(color: color, fontSize: 12.sp),
          ),
        ],
      ),
    );
  }
}
