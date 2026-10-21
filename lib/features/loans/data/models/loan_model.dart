import 'package:dynora_finance/core/sync/sync_status.dart';
import 'package:dynora_finance/features/loans/domain/entities/loan_entity.dart';
import 'package:isar_community/isar.dart';

part 'loan_model.g.dart';

/// Local (Isar) representation of a loan.
///
/// [uid] is the global id shared with any remote provider; [isarId] is only
/// the internal Isar key and never leaves this layer.
@collection
class LoanModel {
  Id isarId = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String uid;

  late String name;

  @Enumerated(EnumType.name)
  LoanKind kind = LoanKind.personal;

  late double principal;
  late DateTime startDate;
  double? interestRate;
  double? installmentAmount;
  int? installmentCount;
  DateTime? firstPaymentDate;
  bool countsAsIncome = true;
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

  LoanEntity toEntity() {
    return LoanEntity(
      id: uid,
      name: name,
      kind: kind,
      principal: principal,
      startDate: startDate,
      interestRate: interestRate,
      installmentAmount: installmentAmount,
      installmentCount: installmentCount,
      firstPaymentDate: firstPaymentDate,
      countsAsIncome: countsAsIncome,
      note: note,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Copies the editable fields of [entity] into this model.
  void applyEntity(LoanEntity entity) {
    name = entity.name;
    kind = entity.kind;
    principal = entity.principal;
    startDate = entity.startDate;
    interestRate = entity.interestRate;
    installmentAmount = entity.installmentAmount;
    installmentCount = entity.installmentCount;
    firstPaymentDate = entity.firstPaymentDate;
    countsAsIncome = entity.countsAsIncome;
    note = entity.note;
  }
}
