import 'package:dynora_finance/core/sync/sync_status.dart';
import 'package:dynora_finance/features/loans/domain/entities/loan_payment_entity.dart';
import 'package:isar_community/isar.dart';

part 'loan_payment_model.g.dart';

/// Local (Isar) representation of a loan payment.
@collection
class LoanPaymentModel {
  Id isarId = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String uid;

  @Index()
  late String loanId;

  late double amount;
  late DateTime paidAt;
  String? note;
  late DateTime createdAt;
  late DateTime updatedAt;

  @Enumerated(EnumType.name)
  @Index()
  SyncStatus syncStatus = SyncStatus.pendingCreate;

  /// Tombstone kept until the deletion is pushed to the remote provider.
  @Index()
  bool isDeleted = false;

  DateTime? lastSyncedAt;

  LoanPaymentEntity toEntity() {
    return LoanPaymentEntity(
      id: uid,
      loanId: loanId,
      amount: amount,
      paidAt: paidAt,
      note: note,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
