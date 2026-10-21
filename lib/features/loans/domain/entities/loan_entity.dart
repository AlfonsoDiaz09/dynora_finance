import 'package:equatable/equatable.dart';

enum LoanDirection {
  /// Someone lent you money: you pay it back.
  borrowed,

  /// You lent money to someone: they pay you back.
  lent,
}

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

/// Money you borrowed and pay back, or money you lent and collect.
class LoanEntity extends Equatable {
  const LoanEntity({
    required this.id,
    required this.name,
    required this.kind,
    this.direction = LoanDirection.borrowed,
    required this.principal,
    required this.startDate,
    this.interestRate,
    this.installmentAmount,
    this.installmentCount,
    this.firstPaymentDate,
    this.affectsCash = true,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Lender or borrower (bank or person), or a description of the loan.
  final String name;
  final String id;

  /// Always [LoanKind.personal] for [LoanDirection.lent].
  final LoanKind kind;
  final LoanDirection direction;

  /// Amount lent.
  final double principal;

  /// Day the money was handed over.
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

  /// Whether the money moved through your accounts: on [startDate] it is
  /// income when borrowed and an expense when lent.
  final bool affectsCash;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isLent => direction == LoanDirection.lent;

  /// What will be paid back in total, interest included.
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
    direction,
    affectsCash,
    note,
    createdAt,
    updatedAt,
  ];
}
