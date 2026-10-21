import 'package:dynora_finance/app/theme/app_colors.dart';
import 'package:dynora_finance/features/loans/domain/entities/loan_entity.dart';
import 'package:dynora_finance/features/loans/domain/entities/loan_summary.dart';
import 'package:dynora_finance/shared/utils/formatters.dart';
import 'package:flutter/material.dart';

/// Words that change depending on who owes whom.
extension LoanDirectionWords on LoanDirection {
  bool get _lent => this == LoanDirection.lent;

  String get tab => _lent ? 'Presté' : 'Me prestaron';
  String get totalTitle => _lent ? 'Te deben en total' : 'Debes en total';
  String get monthTitle => _lent ? 'Cobros de este mes' : 'Pagos de este mes';
  String get remaining => _lent ? 'Por cobrar' : 'Restante';
  String get remainingShort => _lent ? 'por cobrar' : 'restante';
  String get paidWord => _lent ? 'Cobrado' : 'Pagado';
  String get paidPercent => _lent ? 'cobrado' : 'pagado';
  String get nextPayment => _lent ? 'Próximo cobro' : 'Próximo pago';
  String get registerPayment => _lent ? 'Registrar cobro' : 'Registrar pago';
  String get editPayment => _lent ? 'Editar cobro' : 'Editar pago';
  String get savePayment => _lent ? 'Guardar cobro' : 'Guardar pago';
  String get paymentsTitle => _lent ? 'Cobros recibidos' : 'Pagos realizados';
  String get noPayments =>
      _lent ? 'Aún no registras cobros' : 'Aún no registras pagos';
  String get paymentAmountHint => _lent ? 'Monto cobrado' : 'Monto pagado';
  String get paymentDateLabel =>
      _lent ? 'Fecha en que te pagaron' : 'Fecha en que pagaste';
  String get cashSwitch =>
      _lent ? 'El dinero salió de mi cuenta' : 'El dinero entró a mi cuenta';
  String get personHint =>
      _lent ? '¿A quién le prestaste?' : '¿Quién te prestó?';
  String get receivedChip => _lent ? 'Prestado el' : 'Recibido';
  String get newTitle =>
      _lent ? 'Nuevo préstamo que hiciste' : 'Nuevo préstamo';
  String get emptyMessage => _lent
      ? 'No has registrado préstamos que hiciste.\n'
            'Toca + para agregar uno.'
      : 'No tienes préstamos registrados.\n'
            'Toca + para agregar uno de un banco o de una persona.';
}

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
      '${summary.loan.direction.nextPayment} '
          '${Formatters.shortDate(next.installment.dueDate)} · '
          '${Formatters.currency(next.missing)} '
          '(${next.installment.number}/$total)',
      AppColors.warning,
    );
  }
  return (
    'Sin pagos fijos · ${summary.loan.direction.remaining} '
        '${Formatters.currency(summary.remaining)}',
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
