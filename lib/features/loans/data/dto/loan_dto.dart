import 'package:dynora_finance/core/sync/sync_status.dart';
import 'package:dynora_finance/features/loans/data/models/loan_model.dart';
import 'package:dynora_finance/features/loans/domain/entities/loan_entity.dart';

/// Provider-agnostic shape of a loan exchanged with a remote backend.
class LoanDto {
  const LoanDto({
    required this.id,
    required this.name,
    required this.kind,
    required this.principal,
    required this.startDate,
    this.interestRate,
    this.installmentAmount,
    this.installmentCount,
    this.firstPaymentDate,
    required this.countsAsIncome,
    this.note,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
  });

  final String id;
  final String name;
  final String kind;
  final double principal;

  /// Calendar dates (`yyyy-MM-dd`), not instants.
  final DateTime startDate;
  final double? interestRate;
  final double? installmentAmount;
  final int? installmentCount;
  final DateTime? firstPaymentDate;
  final bool countsAsIncome;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;

  factory LoanDto.fromJson(Map<String, dynamic> json) {
    final first = json['first_payment_date'] as String?;
    return LoanDto(
      id: json['id'] as String,
      name: json['name'] as String,
      kind: json['kind'] as String,
      principal: (json['principal'] as num).toDouble(),
      startDate: _parseDate(json['start_date'] as String),
      interestRate: (json['interest_rate'] as num?)?.toDouble(),
      installmentAmount: (json['installment_amount'] as num?)?.toDouble(),
      installmentCount: json['installment_count'] as int?,
      firstPaymentDate: first == null ? null : _parseDate(first),
      countsAsIncome: json['counts_as_income'] as bool? ?? true,
      note: json['note'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      isDeleted: json['is_deleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    final first = firstPaymentDate;
    return {
      'id': id,
      'name': name,
      'kind': kind,
      'principal': principal,
      'start_date': _formatDate(startDate),
      'interest_rate': interestRate,
      'installment_amount': installmentAmount,
      'installment_count': installmentCount,
      'first_payment_date': first == null ? null : _formatDate(first),
      'counts_as_income': countsAsIncome,
      'note': note,
      'created_at': createdAt.toUtc().toIso8601String(),
      'updated_at': updatedAt.toUtc().toIso8601String(),
      'is_deleted': isDeleted,
    };
  }

  factory LoanDto.fromModel(LoanModel model) {
    return LoanDto(
      id: model.uid,
      name: model.name,
      kind: model.kind.name,
      principal: model.principal,
      startDate: model.startDate,
      interestRate: model.interestRate,
      installmentAmount: model.installmentAmount,
      installmentCount: model.installmentCount,
      firstPaymentDate: model.firstPaymentDate,
      countsAsIncome: model.countsAsIncome,
      note: model.note,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      isDeleted: model.isDeleted,
    );
  }

  /// Builds a local model from remote data, already marked as synced.
  LoanModel toModel({required DateTime syncedAt}) {
    return LoanModel()
      ..uid = id
      ..name = name
      ..kind = LoanKind.values.byName(kind)
      ..principal = principal
      ..startDate = startDate
      ..interestRate = interestRate
      ..installmentAmount = installmentAmount
      ..installmentCount = installmentCount
      ..firstPaymentDate = firstPaymentDate
      ..countsAsIncome = countsAsIncome
      ..note = note
      ..createdAt = createdAt.toLocal()
      ..updatedAt = updatedAt.toLocal()
      ..isDeleted = isDeleted
      ..syncStatus = SyncStatus.synced
      ..lastSyncedAt = syncedAt;
  }

  static String _formatDate(DateTime date) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${date.year}-${two(date.month)}-${two(date.day)}';
  }

  static DateTime _parseDate(String value) {
    final parts = value.split('-').map(int.parse).toList();
    return DateTime(parts[0], parts[1], parts[2]);
  }
}
