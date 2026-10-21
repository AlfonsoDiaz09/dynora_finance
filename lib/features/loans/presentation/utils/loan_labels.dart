import 'package:dynora_finance/app/theme/app_colors.dart';
import 'package:dynora_finance/features/loans/domain/entities/loan_entity.dart';
import 'package:dynora_finance/features/loans/domain/entities/loan_summary.dart';
import 'package:dynora_finance/shared/utils/formatters.dart';
import 'package:flutter/material.dart';

extension LoanKindLabel on LoanKind {
  String get label => switch (this) {
    LoanKind.institution => 'Institución',
    LoanKind.personal => 'Personal',
  };

  IconData get icon => switch (this) {
    LoanKind.institution => Icons.account_balance_rounded,
    LoanKind.personal => Icons.person_rounded,
  };
}

/// One line describing what's next for the loan, with its color.
(String, Color) loanStatusLine(LoanSummary summary) {
  if (summary.isSettled) return ('Liquidado', AppColors.success);
  if (summary.overdueAmount > 0) {
    final count = summary.overdueCount;
    return (
      'Vencido ${Formatters.currency(summary.overdueAmount)} · '
          '${count == 1 ? '1 pago' : '$count pagos'}',
      AppColors.error,
    );
  }
  final next = summary.nextInstallment;
  if (next != null) {
    final total = summary.installments.length;
    return (
      'Próximo pago ${Formatters.shortDate(next.installment.dueDate)} · '
          '${Formatters.currency(next.missing)} '
          '(${next.installment.number}/$total)',
      AppColors.warning,
    );
  }
  return (
    'Sin pagos fijos · Restan ${Formatters.currency(summary.remaining)}',
    AppColors.textPrimary70,
  );
}

(String, Color) installmentStatusStyle(InstallmentState state) {
  return switch (state.status) {
    InstallmentStatus.paid => ('Pagado', AppColors.success),
    InstallmentStatus.partial => (
      'Faltan ${Formatters.currency(state.missing)}',
      AppColors.warning,
    ),
    InstallmentStatus.overdue => ('Vencido', AppColors.error),
    InstallmentStatus.pending => ('Pendiente', AppColors.textPrimary70),
  };
}
