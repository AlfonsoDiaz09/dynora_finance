import 'package:dynora_finance/core/sync/sync_status.dart';
import 'package:dynora_finance/features/loans/data/models/loan_payment_model.dart';

/// Provider-agnostic shape of a loan payment exchanged with a remote backend.
class LoanPaymentDto {
  const LoanPaymentDto({
    required this.id,
    required this.loanId,
    required this.amount,
    required this.paidAt,
    this.note,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
  });

  final String id;
  final String loanId;
  final double amount;

  /// Calendar date (`yyyy-MM-dd`), not an instant.
  final DateTime paidAt;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;

  factory LoanPaymentDto.fromJson(Map<String, dynamic> json) {
    final parts = (json['paid_at'] as String)
        .split('-')
        .map(int.parse)
        .toList();
    return LoanPaymentDto(
      id: json['id'] as String,
      loanId: json['loan_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      paidAt: DateTime(parts[0], parts[1], parts[2]),
      note: json['note'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      isDeleted: json['is_deleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    String two(int n) => n.toString().padLeft(2, '0');
    return {
      'id': id,
      'loan_id': loanId,
      'amount': amount,
      'paid_at': '${paidAt.year}-${two(paidAt.month)}-${two(paidAt.day)}',
      'note': note,
      'created_at': createdAt.toUtc().toIso8601String(),
      'updated_at': updatedAt.toUtc().toIso8601String(),
      'is_deleted': isDeleted,
    };
  }

  factory LoanPaymentDto.fromModel(LoanPaymentModel model) {
    return LoanPaymentDto(
      id: model.uid,
      loanId: model.loanId,
      amount: model.amount,
      paidAt: model.paidAt,
      note: model.note,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      isDeleted: model.isDeleted,
    );
  }

  /// Builds a local model from remote data, already marked as synced.
  LoanPaymentModel toModel({required DateTime syncedAt}) {
    return LoanPaymentModel()
      ..uid = id
      ..loanId = loanId
      ..amount = amount
      ..paidAt = paidAt
      ..note = note
      ..createdAt = createdAt.toLocal()
      ..updatedAt = updatedAt.toLocal()
      ..isDeleted = isDeleted
      ..syncStatus = SyncStatus.synced
      ..lastSyncedAt = syncedAt;
  }
}
