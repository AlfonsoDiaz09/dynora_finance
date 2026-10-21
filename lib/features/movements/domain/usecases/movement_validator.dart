import 'package:dynora_finance/core/error/failures.dart';

class MovementValidator {
  const MovementValidator._();

  /// Returns a [ValidationFailure] when the data is invalid, `null` otherwise.
  static ValidationFailure? validate({
    required String title,
    required double amount,
    required String categoryId,
  }) {
    if (title.trim().isEmpty) {
      return const ValidationFailure('El título es obligatorio');
    }
    if (amount <= 0 || amount.isNaN || amount.isInfinite) {
      return const ValidationFailure('El monto debe ser mayor a 0');
    }
    if (categoryId.isEmpty) {
      return const ValidationFailure('La categoría es obligatoria');
    }
    return null;
  }
}
