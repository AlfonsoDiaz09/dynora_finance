import 'package:dynora_finance/core/error/failures.dart';

class MovementValidator {
  const MovementValidator._();

  static const int maxInstallments = 48;

  /// Returns a [ValidationFailure] when the data is invalid, `null` otherwise.
  static ValidationFailure? validate({
    required String title,
    required double amount,
    required String categoryId,
    String? cardId,
    int? installmentCount,
    double? installmentRate,
    bool isCashWithdrawal = false,
  }) {
    if (title.trim().isEmpty) {
      return const ValidationFailure('El título es obligatorio');
    }
    if (amount <= 0 || amount.isNaN || amount.isInfinite) {
      return const ValidationFailure('El monto debe ser mayor a 0');
    }
    if (isCashWithdrawal && cardId == null) {
      return const ValidationFailure(
        'Elige la tarjeta de crédito de la disposición',
      );
    }
    if (categoryId.isEmpty) {
      return const ValidationFailure('La categoría es obligatoria');
    }
    final rate = installmentRate ?? 0;
    if (rate > 0 && cardId == null) {
      return const ValidationFailure('El interés solo aplica con tarjeta');
    }
    if (installmentCount != null && installmentCount > 1) {
      if (cardId == null) {
        return const ValidationFailure(
          'Las compras a meses requieren una tarjeta de crédito',
        );
      }
      if (installmentCount > maxInstallments) {
        return const ValidationFailure(
          'El máximo es de $maxInstallments meses',
        );
      }
    }
    if (rate < 0 || rate > 100 || rate.isNaN) {
      return const ValidationFailure('La tasa debe estar entre 0 y 100%');
    }
    return null;
  }
}
