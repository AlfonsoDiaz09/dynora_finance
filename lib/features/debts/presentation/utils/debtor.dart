import 'package:dynora_finance/features/debts/domain/entities/debt_entity.dart';
import 'package:dynora_finance/features/debts/domain/entities/person_entity.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

/// A person who owes you part of a movement, ready to display.
class Debtor extends Equatable {
  const Debtor({
    required this.personId,
    required this.name,
    required this.amount,
    this.paidAt,
    this.detail,
  });

  final String personId;
  final String name;
  final double amount;
  final DateTime? paidAt;

  /// Extra context, e.g. the movement title when listing a whole period.
  final String? detail;

  bool get isPaid => paidAt != null;

  String get initial =>
      name.isEmpty ? '?' : name.characters.first.toUpperCase();

  /// Movement id → its debtors, pending first then by name.
  static Map<String, List<Debtor>> byMovement(
    Iterable<DebtEntity> debts,
    Iterable<PersonEntity> people,
  ) {
    final names = {for (final p in people) p.id: p.name};
    final result = <String, List<Debtor>>{};
    for (final debt in debts) {
      result
          .putIfAbsent(debt.movementId, () => [])
          .add(
            Debtor(
              personId: debt.personId,
              name: names[debt.personId] ?? 'Persona',
              amount: debt.amount,
              paidAt: debt.paidAt,
            ),
          );
    }
    for (final list in result.values) {
      list.sort((a, b) {
        if (a.isPaid != b.isPaid) return a.isPaid ? 1 : -1;
        return a.name.compareTo(b.name);
      });
    }
    return result;
  }

  Debtor withDetail(String detail) => Debtor(
    personId: personId,
    name: name,
    amount: amount,
    paidAt: paidAt,
    detail: detail,
  );

  @override
  List<Object?> get props => [personId, name, amount, paidAt, detail];
}
