import 'package:dynora_finance/features/loans/domain/entities/loan_entity.dart';
import 'package:dynora_finance/features/loans/domain/entities/loan_payment_entity.dart';
import 'package:equatable/equatable.dart';

enum InstallmentStatus { paid, partial, overdue, pending }

class InstallmentState extends Equatable {
  const InstallmentState({
    required this.installment,
    required this.covered,
    required this.status,
  });

  final LoanInstallment installment;

  /// Part of the installment already covered by payments.
  final double covered;
  final InstallmentStatus status;

  double get missing => installment.amount - covered;

  @override
  List<Object?> get props => [installment, covered, status];
}

/// Where a loan stands on a given day: paid, remaining, calendar status.
///
/// Payments are applied to the installments in order, so paying more than
/// one installment covers the next ones.
class LoanSummary extends Equatable {
  const LoanSummary({
    required this.loan,
    required this.payments,
    required this.paid,
    required this.installments,
    required this.today,
  });

  factory LoanSummary.of(
    LoanEntity loan,
    Iterable<LoanPaymentEntity> allPayments,
    DateTime now,
  ) {
    final payments = [
      for (final p in allPayments)
        if (p.loanId == loan.id) p,
    ]..sort((a, b) => b.paidAt.compareTo(a.paidAt));
    final paid = payments.fold<double>(0, (sum, p) => sum + p.amount);
    final today = DateTime(now.year, now.month, now.day);

    var available = paid;
    final installments = <InstallmentState>[];
    for (final installment in loan.schedule) {
      final covered = available >= installment.amount - _epsilon
          ? installment.amount
          : (available > _epsilon ? available : 0.0);
      available -= covered;
      final complete = covered >= installment.amount - _epsilon;
      installments.add(
        InstallmentState(
          installment: installment,
          covered: covered,
          status: complete
              ? InstallmentStatus.paid
              : installment.dueDate.isBefore(today)
              ? InstallmentStatus.overdue
              : covered > 0
              ? InstallmentStatus.partial
              : InstallmentStatus.pending,
        ),
      );
    }

    return LoanSummary(
      loan: loan,
      payments: payments,
      paid: paid,
      installments: installments,
      today: today,
    );
  }

  static const double _epsilon = 0.005;

  final LoanEntity loan;

  /// Payments of [loan], newest first.
  final List<LoanPaymentEntity> payments;
  final double paid;
  final List<InstallmentState> installments;
  final DateTime today;

  double get total => loan.totalToPay;

  double get remaining {
    final value = total - paid;
    return value > _epsilon ? value : 0;
  }

  bool get isSettled => remaining == 0;

  /// Share of the total already paid (0-1).
  double get progress => total > 0 ? (paid / total).clamp(0.0, 1.0) : 1;

  /// First installment not fully covered.
  InstallmentState? get nextInstallment =>
      installments.where((i) => i.status != InstallmentStatus.paid).firstOrNull;

  /// Amount of the installments past their due date still unpaid.
  double get overdueAmount => installments
      .where((i) => i.status == InstallmentStatus.overdue)
      .fold(0, (sum, i) => sum + i.missing);

  int get overdueCount =>
      installments.where((i) => i.status == InstallmentStatus.overdue).length;

  @override
  List<Object?> get props => [loan, payments, paid, installments, today];
}
