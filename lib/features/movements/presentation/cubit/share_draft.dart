import 'package:dynora_finance/features/debts/domain/entities/debt_entity.dart';
import 'package:dynora_finance/features/debts/domain/entities/debt_split.dart';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

enum SplitMode { equal, custom }

/// Who owes you part of the movement being edited, and how it is split.
class ShareDraft extends Equatable {
  const ShareDraft({
    this.enabled = false,
    this.personIds = const [],
    this.mode = SplitMode.equal,
    this.includeMe = true,
    this.initialAmounts = const {},
  });

  /// Rebuilds the draft from the debts already saved for a movement.
  factory ShareDraft.fromDebts(List<DebtEntity> debts, double total) {
    if (debts.isEmpty) return const ShareDraft();
    final amounts = {for (final d in debts) d.personId: d.amount};
    final ids = amounts.keys.toList();

    // Equal split, with or without you, reproduces the same amounts?
    for (final includeMe in const [true, false]) {
      final equal = DebtSplit.equal(
        total: total,
        people: ids.length,
        includeMe: includeMe,
      );
      final owed = [for (final id in ids) amounts[id]!]..sort();
      if (_sameAmounts(owed, equal..sort())) {
        return ShareDraft(
          enabled: true,
          personIds: ids,
          includeMe: includeMe,
          initialAmounts: amounts,
        );
      }
    }
    return ShareDraft(
      enabled: true,
      personIds: ids,
      mode: SplitMode.custom,
      initialAmounts: amounts,
    );
  }

  final bool enabled;

  /// People who owe you, in the order they were added.
  final List<String> personIds;
  final SplitMode mode;

  /// Whether you also take an equal part (equal mode only).
  final bool includeMe;

  /// Saved amounts per person, to prefill custom amounts when editing.
  final Map<String, double> initialAmounts;

  bool get isActive => enabled && personIds.isNotEmpty;

  /// Person id → amount owed for a movement of [total]. [customAmounts]
  /// holds what was typed per person in custom mode. Returns an error
  /// message when the split is invalid.
  Either<String, Map<String, double>> shares(
    double total,
    Map<String, double?> customAmounts,
  ) {
    if (!isActive) return right(const {});

    if (mode == SplitMode.equal) {
      final parts = DebtSplit.equal(
        total: total,
        people: personIds.length,
        includeMe: includeMe,
      );
      return right({
        for (var i = 0; i < personIds.length; i++) personIds[i]: parts[i],
      });
    }

    final result = <String, double>{};
    for (final id in personIds) {
      final amount = customAmounts[id];
      if (amount == null || amount <= 0) {
        return left('Ingresa cuánto te debe cada persona');
      }
      result[id] = amount;
    }
    final owed = result.values.fold<double>(0, (sum, a) => sum + a);
    if (owed > total + 0.005) {
      return left('Lo que te deben no puede superar el monto');
    }
    return right(result);
  }

  ShareDraft copyWith({
    bool? enabled,
    List<String>? personIds,
    SplitMode? mode,
    bool? includeMe,
  }) {
    return ShareDraft(
      enabled: enabled ?? this.enabled,
      personIds: personIds ?? this.personIds,
      mode: mode ?? this.mode,
      includeMe: includeMe ?? this.includeMe,
      initialAmounts: initialAmounts,
    );
  }

  static bool _sameAmounts(List<double> a, List<double> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if ((a[i] - b[i]).abs() > 0.005) return false;
    }
    return true;
  }

  @override
  List<Object?> get props => [
    enabled,
    personIds,
    mode,
    includeMe,
    initialAmounts,
  ];
}
