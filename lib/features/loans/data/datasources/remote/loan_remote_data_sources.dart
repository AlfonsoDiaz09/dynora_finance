import 'package:dynora_finance/features/loans/data/dto/loan_dto.dart';
import 'package:dynora_finance/features/loans/data/dto/loan_payment_dto.dart';

/// Contract any remote provider must implement to sync loans.
///
/// Implementations must throw `RemoteDataSourceException` on failure.
/// Deletions travel as DTOs with `isDeleted: true`.
abstract interface class LoanRemoteDataSource {
  /// Loans (deleted ones included) whose `updatedAt` is after [since], or
  /// all of them when [since] is `null`.
  Future<List<LoanDto>> fetchChangedSince(DateTime? since);

  /// Creates or replaces the given loans on the remote provider.
  Future<void> upsert(List<LoanDto> loans);
}

/// Contract any remote provider must implement to sync loan payments.
abstract interface class LoanPaymentRemoteDataSource {
  Future<List<LoanPaymentDto>> fetchChangedSince(DateTime? since);

  Future<void> upsert(List<LoanPaymentDto> payments);
}
