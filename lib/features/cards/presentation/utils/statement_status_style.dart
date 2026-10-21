import 'package:dynora_finance/app/theme/app_colors.dart';
import 'package:dynora_finance/features/cards/domain/entities/card_statement.dart';
import 'package:flutter/material.dart';

/// Label and color describing the status of [statement] on [now].
(String, Color) statementStatusStyle(CardStatement statement, DateTime now) {
  final days = statement.period.daysUntilPayment(now);
  return switch (statement.status(now)) {
    StatementStatus.open => ('Periodo actual', AppColors.info),
    StatementStatus.pending => (
      switch (days) {
        0 => 'Por pagar · hoy',
        1 => 'Por pagar · 1 día',
        _ => 'Por pagar · $days días',
      },
      days <= 3 ? AppColors.error : AppColors.warning,
    ),
    StatementStatus.overdue => (
      days == -1 ? 'Vencido · ayer' : 'Vencido · hace ${-days} días',
      AppColors.error,
    ),
    StatementStatus.paid => ('Pagado', AppColors.success),
    StatementStatus.nothingToPay => ('Sin saldo', AppColors.textPrimary70),
  };
}
