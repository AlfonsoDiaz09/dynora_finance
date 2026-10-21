import 'package:dynora_finance/core/error/failures.dart';

class CardValidator {
  const CardValidator._();

  /// Returns a [ValidationFailure] when the data is invalid, `null` otherwise.
  static ValidationFailure? validate({
    required String name,
    required int paymentDueDay,
  }) {
    if (name.trim().isEmpty) {
      return const ValidationFailure('El nombre es obligatorio');
    }
    if (paymentDueDay < 1 || paymentDueDay > 31) {
      return const ValidationFailure('El día de pago debe estar entre 1 y 31');
    }
    return null;
  }
}
