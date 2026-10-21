import 'package:dynora_finance/core/enums/movement_type.dart';
import 'package:dynora_finance/core/enums/payment_method.dart';
import 'package:equatable/equatable.dart';

class MovementEntity extends Equatable {
  const MovementEntity({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.date,
    this.note,
    this.cardId,
    PaymentMethod? paymentMethod,
    this.installmentCount,
    this.installmentRate,
    required this.createdAt,
    required this.updatedAt,
  }) : paymentMethod = cardId != null
           ? PaymentMethod.card
           : (paymentMethod == PaymentMethod.transfer
                 ? PaymentMethod.transfer
                 : PaymentMethod.cash);

  final String id;
  final String title;

  /// Price of the purchase (without installment interest).
  final double amount;
  final MovementType type;
  final String categoryId;
  final DateTime date;
  final String? note;

  /// Card used to pay, `null` for cash or transfers.
  final String? cardId;

  /// Always [PaymentMethod.card] when [cardId] is set.
  final PaymentMethod paymentMethod;

  /// Monthly installments of a card purchase; `null` for a single charge.
  final int? installmentCount;

  /// Fixed interest (percentage of [amount]) of an installment purchase;
  /// `null` or 0 for interest-free installments.
  final double? installmentRate;

  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isExpense => type == MovementType.expense;

  bool get hasInstallments => (installmentCount ?? 1) > 1;

  bool get hasInterest => hasInstallments && (installmentRate ?? 0) > 0;

  /// What will be charged in total, interest included.
  double get totalWithInterest =>
      hasInterest ? _cents(amount * (1 + installmentRate! / 100)) : amount;

  /// Amount of each charge, in order. A single charge when there are no
  /// installments; the last installment absorbs rounding cents so they add
  /// up exactly to [totalWithInterest].
  List<double> get installmentAmounts {
    if (!hasInstallments) return [amount];
    final count = installmentCount!;
    final total = totalWithInterest;
    final regular = _cents(total / count);
    return [
      for (var i = 0; i < count - 1; i++) regular,
      _cents(total - regular * (count - 1)),
    ];
  }

  static double _cents(double value) => (value * 100).roundToDouble() / 100;

  MovementEntity copyWith({
    String? title,
    double? amount,
    MovementType? type,
    String? categoryId,
    DateTime? date,
    String? note,
  }) {
    return MovementEntity(
      id: id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      date: date ?? this.date,
      note: note ?? this.note,
      cardId: cardId,
      paymentMethod: paymentMethod,
      installmentCount: installmentCount,
      installmentRate: installmentRate,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    amount,
    type,
    categoryId,
    date,
    note,
    cardId,
    paymentMethod,
    installmentCount,
    installmentRate,
    createdAt,
    updatedAt,
  ];
}
