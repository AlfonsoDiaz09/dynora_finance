import 'package:dynora_finance/core/error/failures.dart';
import 'package:dynora_finance/features/loans/domain/entities/loan_entity.dart';
import 'package:dynora_finance/features/loans/domain/entities/loan_payment_entity.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class LoanRepository {
  /// Emits loans (oldest first) and every subsequent change.
  Stream<Either<Failure, List<LoanEntity>>> watchLoans();

  /// Creates the loan, or replaces it when [LoanEntity.id] already exists
  /// (an empty id creates a new one).
  Future<Either<Failure, LoanEntity>> saveLoan(LoanEntity loan);

  /// Deletes the loan and its payments.
  Future<Either<Failure, Unit>> deleteLoan(String id);

  /// Emits every loan payment and each subsequent change.
  Stream<Either<Failure, List<LoanPaymentEntity>>> watchPayments();

  /// Creates the payment, or replaces it when [LoanPaymentEntity.id]
  /// already exists (an empty id creates a new one).
  Future<Either<Failure, LoanPaymentEntity>> savePayment(
    LoanPaymentEntity payment,
  );

  Future<Either<Failure, Unit>> deletePayment(String id);
}
