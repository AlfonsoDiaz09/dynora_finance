import 'package:dynora_finance/core/error/failures.dart';
import 'package:dynora_finance/features/cards/domain/entities/card_type.dart';

class CardValidator {
  const CardValidator._();

  static final RegExp _fourDigits = RegExp(r'^\d{4}$');

  /// Returns a [ValidationFailure] when the data is invalid, `null` otherwise.
  static ValidationFailure? validate({
    required String name,
    required CardType type,
    required String lastFourDigits,
    required int? cutoffDay,
    required int? paymentDueDay,
    double? creditLimit,
  }) {
    if (name.trim().isEmpty) {
      return const ValidationFailure('El nombre es obligatorio');
    }
    if (!_fourDigits.hasMatch(lastFourDigits)) {
      return const ValidationFailure(
        'Ingresa los últimos 4 dígitos de la tarjeta',
      );
    }
    if (!type.hasBillingCycle) return null;

    if (!_isDay(cutoffDay)) {
      return const ValidationFailure('El día de corte debe estar entre 1 y 31');
    }
    if (!_isDay(paymentDueDay)) {
      return const ValidationFailure('El día de pago debe estar entre 1 y 31');
    }
    if (creditLimit != null &&
        (creditLimit <= 0 || creditLimit.isNaN || creditLimit.isInfinite)) {
      return const ValidationFailure('El límite de crédito debe ser mayor a 0');
    }
    return null;
  }

  static bool _isDay(int? day) => day != null && day >= 1 && day <= 31;
}
