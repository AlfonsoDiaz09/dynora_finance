import 'package:equatable/equatable.dart';

class CardEntity extends Equatable {
  const CardEntity({
    required this.id,
    required this.name,
    required this.paymentDueDay,
    required this.colorValue,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;

  /// Day of the month (1-31) the card payment is due.
  final int paymentDueDay;

  /// ARGB value of the card color.
  final int colorValue;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Next due date on or after [from]. Days past the end of a month are
  /// clamped to its last day (e.g. day 31 in February).
  DateTime nextPaymentDate(DateTime from) {
    final today = DateTime(from.year, from.month, from.day);
    final thisMonth = _dueDateIn(today.year, today.month);
    if (!thisMonth.isBefore(today)) return thisMonth;
    return _dueDateIn(today.year, today.month + 1);
  }

  /// Whole days from [from] until [nextPaymentDate].
  int daysUntilPayment(DateTime from) {
    final today = DateTime.utc(from.year, from.month, from.day);
    final due = nextPaymentDate(from);
    return DateTime.utc(due.year, due.month, due.day).difference(today).inDays;
  }

  DateTime _dueDateIn(int year, int month) {
    final lastDay = DateTime(year, month + 1, 0).day;
    final day = paymentDueDay > lastDay ? lastDay : paymentDueDay;
    return DateTime(year, month, day);
  }

  CardEntity copyWith({String? name, int? paymentDueDay, int? colorValue}) {
    return CardEntity(
      id: id,
      name: name ?? this.name,
      paymentDueDay: paymentDueDay ?? this.paymentDueDay,
      colorValue: colorValue ?? this.colorValue,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    paymentDueDay,
    colorValue,
    createdAt,
    updatedAt,
  ];
}
