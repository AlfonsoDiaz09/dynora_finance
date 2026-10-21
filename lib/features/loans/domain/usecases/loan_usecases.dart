import 'package:dynora_finance/core/error/failures.dart';
import 'package:dynora_finance/core/usecase/usecase.dart';
import 'package:dynora_finance/features/loans/domain/entities/loan_entity.dart';
import 'package:dynora_finance/features/loans/domain/entities/loan_payment_entity.dart';
import 'package:dynora_finance/features/loans/domain/repositories/loan_repository.dart';
import 'package:fpdart/fpdart.dart';

class WatchLoans implements StreamUseCase<List<LoanEntity>, NoParams> {
  const WatchLoans(this._repository);

  final LoanRepository _repository;

  @override
  Stream<Either<Failure, List<LoanEntity>>> call(NoParams params) =>
      _repository.watchLoans();
}

class WatchLoanPayments
    implements StreamUseCase<List<LoanPaymentEntity>, NoParams> {
  const WatchLoanPayments(this._repository);

  final LoanRepository _repository;

  @override
  Stream<Either<Failure, List<LoanPaymentEntity>>> call(NoParams params) =>
      _repository.watchPayments();
}

/// Creates or updates a loan after validating it.
class SaveLoan implements UseCase<LoanEntity, LoanEntity> {
  const SaveLoan(this._repository);

  final LoanRepository _repository;

  @override
  Future<Either<Failure, LoanEntity>> call(LoanEntity loan) async {
    final failure = _validate(loan);
    if (failure != null) return left(failure);
    return _repository.saveLoan(loan);
  }

  static ValidationFailure? _validate(LoanEntity loan) {
    bool invalid(double? v) => v != null && (v <= 0 || v.isNaN || v.isInfinite);

    if (loan.name.trim().isEmpty) {
      return const ValidationFailure('Escribe quién te prestó');
    }
    if (invalid(loan.principal)) {
      return const ValidationFailure('El monto prestado debe ser mayor a 0');
    }
    if (invalid(loan.installmentAmount)) {
      return const ValidationFailure('El pago mensual debe ser mayor a 0');
    }
    final count = loan.installmentCount;
    if (count != null && (count < 1 || count > 600)) {
      return const ValidationFailure('El número de pagos no es válido');
    }
    final rate = loan.interestRate;
    if (rate != null && (rate < 0 || rate.isNaN)) {
      return const ValidationFailure('El interés no puede ser negativo');
    }
    if (loan.kind == LoanKind.institution &&
        (loan.installmentAmount == null ||
            count == null ||
            loan.firstPaymentDate == null)) {
      return const ValidationFailure(
        'Indica el pago mensual, el número de pagos y la fecha del primer pago',
      );
    }
    if (loan.installmentAmount != null && loan.firstPaymentDate == null) {
      return const ValidationFailure('Indica la fecha del primer pago');
    }
    if (loan.totalToPay < loan.principal - 0.005) {
      return const ValidationFailure(
        'El total a pagar no puede ser menor al monto prestado',
      );
    }
    return null;
  }
}

class DeleteLoan implements UseCase<Unit, String> {
  const DeleteLoan(this._repository);

  final LoanRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(String id) => _repository.deleteLoan(id);
}

/// Creates or updates a payment after validating it.
class SaveLoanPayment implements UseCase<LoanPaymentEntity, LoanPaymentEntity> {
  const SaveLoanPayment(this._repository, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final LoanRepository _repository;
  final DateTime Function() _clock;

  @override
  Future<Either<Failure, LoanPaymentEntity>> call(
    LoanPaymentEntity payment,
  ) async {
    if (payment.amount <= 0 || payment.amount.isNaN) {
      return left(const ValidationFailure('El monto debe ser mayor a 0'));
    }
    final now = _clock();
    final day = DateTime(
      payment.paidAt.year,
      payment.paidAt.month,
      payment.paidAt.day,
    );
    if (day.isAfter(DateTime(now.year, now.month, now.day))) {
      return left(
        const ValidationFailure('La fecha de pago no puede ser futura'),
      );
    }
    return _repository.savePayment(payment);
  }
}

class DeleteLoanPayment implements UseCase<Unit, String> {
  const DeleteLoanPayment(this._repository);

  final LoanRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(String id) =>
      _repository.deletePayment(id);
}
