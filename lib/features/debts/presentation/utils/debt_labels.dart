import 'package:dynora_finance/features/debts/domain/entities/movement_debts.dart';
import 'package:dynora_finance/shared/utils/formatters.dart';

/// `Te deben $600.00` or `Saldado`; `null` when nobody owes you for it.
String? debtTag(MovementDebts? debts) {
  if (debts == null) return null;
  return debts.pending > 0
      ? 'Te deben ${Formatters.currency(debts.pending)}'
      : 'Saldado';
}
