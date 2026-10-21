import 'package:equatable/equatable.dart';

enum LoanKind {
  /// Bank or financial company: fixed payment, number of payments and date.
  institution,

  /// Someone you know: interest, fixed payments and dates are optional.
  personal,
}

/// One scheduled payment of a loan.
class LoanInstallment extends Equatable {
  const LoanInstallment({
    required this.number,
    required this.dueDate,
    required this.amount,
  });

  /// 1-based.
  final int number;
  final DateTime dueDate;
  final double amount;

  @override
  List<Object?> get props => [number, dueDate, amount];
}

/// Money you borrowed and are paying back.
class LoanEntity extends Equatable {
  const LoanEntity({
    required this.id,
    required this.name,
    required this.kind,
    required this.principal,
    required this.startDate,
    this.interestRate,
    this.installmentAmount,
    this.installmentCount,
    this.firstPaymentDate,
    this.countsAsIncome = true,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Lender (bank or person) or a description of the loan.
  final String name;
  final String id;
  final LoanKind kind;

  /// Amount you received.
  final double principal;

  /// Day you received the money.
  final DateTime startDate;

  /// Fixed interest as a percentage of [principal]; used when the total is
  /// not defined by [installmentAmount] × [installmentCount].
  final double? interestRate;

  /// Fixed amount of each payment, if any.
  final double? installmentAmount;

  /// Number of payments; derived from the total when only
  /// [installmentAmount] is known.
  final int? installmentCount;

  /// Due date of the first payment; later ones fall on the same day of each
  /// following month.
  final DateTime? firstPaymentDate;

  /// Whether the money entered your accounts (counts as income on
  /// [startDate]).
  final bool countsAsIncome;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// What you will pay back in total, interest included.
  double get totalToPay {
    final amount = installmentAmount;
    final count = installmentCount;
    if (amount != null && count != null) return _cents(amount * count);
    return _cents(principal * (1 + (interestRate ?? 0) / 100));
  }

  double get interest => _cents(totalToPay - principal);

  /// Payments follow a calendar of fixed amounts.
  bool get hasSchedule => installmentAmount != null && firstPaymentDate != null;

  /// Payments of the calendar, the last one absorbing the remainder.
  List<LoanInstallment> get schedule {
    final amount = installmentAmount;
    final first = firstPaymentDate;
    if (amount == null || first == null || amount <= 0) return const [];

    final total = totalToPay;
    final count = installmentCount ?? (total / amount - 0.0001).ceil();
    return [
      for (var i = 0; i < count; i++)
        LoanInstallment(
          number: i + 1,
          dueDate: _monthly(first, i),
          amount: i < count - 1 ? amount : _cents(total - amount * (count - 1)),
        ),
    ];
  }

  /// [first] moved [months] months ahead, clamping the day to the month end.
  static DateTime _monthly(DateTime first, int months) {
    final lastDay = DateTime(first.year, first.month + months + 1, 0).day;
    return DateTime(
      first.year,
      first.month + months,
      first.day > lastDay ? lastDay : first.day,
    );
  }

  static double _cents(double value) => (value * 100).roundToDouble() / 100;

  @override
  List<Object?> get props => [
    id,
    name,
    kind,
    principal,
    startDate,
    interestRate,
    installmentAmount,
    installmentCount,
    firstPaymentDate,
    countsAsIncome,
    note,
    createdAt,
    updatedAt,
  ];
}
