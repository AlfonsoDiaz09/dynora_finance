import 'package:dynora_finance/core/enums/movement_type.dart';
import 'package:dynora_finance/core/enums/payment_method.dart';
import 'package:dynora_finance/core/error/failures.dart';
import 'package:dynora_finance/core/usecase/usecase.dart';
import 'package:dynora_finance/features/movements/domain/entities/movement_entity.dart';
import 'package:dynora_finance/features/movements/domain/repositories/movement_repository.dart';
import 'package:dynora_finance/features/movements/domain/usecases/movement_validator.dart';
import 'package:fpdart/fpdart.dart';

class AddMovement implements UseCase<MovementEntity, AddMovementParams> {
  const AddMovement(this._repository);

  final MovementRepository _repository;

  @override
  Future<Either<Failure, MovementEntity>> call(AddMovementParams params) async {
    final failure = MovementValidator.validate(
      title: params.title,
      amount: params.amount,
      categoryId: params.categoryId,
      cardId: params.cardId,
      installmentCount: params.installmentCount,
      installmentRate: params.installmentRate,
    );
    if (failure != null) return left(failure);
    final installments = (params.installmentCount ?? 1) > 1;

    return _repository.createMovement(
      title: params.title.trim(),
      amount: params.amount,
      type: params.type,
      categoryId: params.categoryId,
      date: params.date,
      note: params.note?.trim(),
      cardId: params.cardId,
      paymentMethod: params.paymentMethod,
      installmentCount: installments ? params.installmentCount : null,
      installmentRate: installments && (params.installmentRate ?? 0) > 0
          ? params.installmentRate
          : null,
    );
  }
}

class AddMovementParams {
  const AddMovementParams({
    required this.title,
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.date,
    this.note,
    this.cardId,
    this.paymentMethod = PaymentMethod.cash,
    this.installmentCount,
    this.installmentRate,
  });

  final String title;
  final double amount;
  final MovementType type;
  final String categoryId;
  final DateTime date;
  final String? note;
  final String? cardId;

  /// Ignored when [cardId] is set (the method is then the card).
  final PaymentMethod paymentMethod;
  final int? installmentCount;
  final double? installmentRate;
}
