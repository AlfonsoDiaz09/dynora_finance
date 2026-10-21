import 'package:dynora_finance/core/enums/movement_type.dart';
import 'package:dynora_finance/core/enums/payment_method.dart';
import 'package:dynora_finance/core/sync/sync_status.dart';
import 'package:dynora_finance/features/movements/data/models/movement_model.dart';

/// Provider-agnostic shape of a movement exchanged with a remote backend.
///
/// Remote data sources (REST, Supabase, Firestore, ...) only deal with DTOs,
/// so the Isar model can change without touching the remote contract.
class MovementDto {
  const MovementDto({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.date,
    this.note,
    this.cardId,
    required this.paymentMethod,
    this.installmentCount,
    this.installmentRate,
    this.isCashWithdrawal = false,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
  });

  final String id;
  final String title;
  final double amount;
  final String type;
  final String categoryId;
  final DateTime date;
  final String? note;
  final String? cardId;
  final String paymentMethod;
  final int? installmentCount;
  final double? installmentRate;
  final bool isCashWithdrawal;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;

  factory MovementDto.fromJson(Map<String, dynamic> json) {
    return MovementDto(
      id: json['id'] as String,
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: json['type'] as String,
      categoryId: json['category_id'] as String,
      date: DateTime.parse(json['date'] as String),
      note: json['note'] as String?,
      cardId: json['card_id'] as String?,
      paymentMethod: json['payment_method'] as String? ?? 'cash',
      installmentCount: json['installment_count'] as int?,
      installmentRate: (json['installment_rate'] as num?)?.toDouble(),
      isCashWithdrawal: json['is_cash_withdrawal'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      isDeleted: json['is_deleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'type': type,
      'category_id': categoryId,
      'date': date.toUtc().toIso8601String(),
      'note': note,
      'card_id': cardId,
      'payment_method': paymentMethod,
      'installment_count': installmentCount,
      'installment_rate': installmentRate,
      'is_cash_withdrawal': isCashWithdrawal,
      'created_at': createdAt.toUtc().toIso8601String(),
      'updated_at': updatedAt.toUtc().toIso8601String(),
      'is_deleted': isDeleted,
    };
  }

  factory MovementDto.fromModel(MovementModel model) {
    return MovementDto(
      id: model.uid,
      title: model.title,
      amount: model.amount,
      type: model.type.name,
      categoryId: model.categoryId,
      date: model.date,
      note: model.note,
      cardId: model.cardId,
      paymentMethod: model.paymentMethod.name,
      installmentCount: model.installmentCount,
      installmentRate: model.installmentRate,
      isCashWithdrawal: model.isCashWithdrawal,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      isDeleted: model.isDeleted,
    );
  }

  /// Builds a local model from remote data, already marked as synced.
  MovementModel toModel({required DateTime syncedAt}) {
    return MovementModel()
      ..uid = id
      ..title = title
      ..amount = amount
      ..type = MovementType.values.byName(type)
      ..categoryId = categoryId
      ..date = date.toLocal()
      ..note = note
      ..cardId = cardId
      ..paymentMethod = PaymentMethod.values.byName(paymentMethod)
      ..installmentCount = installmentCount
      ..installmentRate = installmentRate
      ..isCashWithdrawal = isCashWithdrawal
      ..createdAt = createdAt.toLocal()
      ..updatedAt = updatedAt.toLocal()
      ..isDeleted = isDeleted
      ..syncStatus = SyncStatus.synced
      ..lastSyncedAt = syncedAt;
  }
}
