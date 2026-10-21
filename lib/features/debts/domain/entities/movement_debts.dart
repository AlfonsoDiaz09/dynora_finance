import 'package:dynora_finance/features/debts/domain/entities/debt_entity.dart';
import 'package:equatable/equatable.dart';

/// What others owe you for one movement.
class MovementDebts extends Equatable {
  const MovementDebts({required this.owed, required this.pending});

  /// Total others owe for the movement, paid or not.
  final double owed;

  /// Part of [owed] not paid back yet.
  final double pending;

  /// Movement id → its debts summary.
  static Map<String, MovementDebts> byMovement(Iterable<DebtEntity> debts) {
    final owed = <String, double>{};
    final pending = <String, double>{};
    for (final debt in debts) {
      owed.update(
        debt.movementId,
        (v) => v + debt.amount,
        ifAbsent: () => debt.amount,
      );
      if (!debt.isPaid) {
        pending.update(
          debt.movementId,
          (v) => v + debt.amount,
          ifAbsent: () => debt.amount,
        );
      }
    }
    return {
      for (final id in owed.keys)
        id: MovementDebts(owed: owed[id]!, pending: pending[id] ?? 0),
    };
  }

  @override
  List<Object?> get props => [owed, pending];
}
