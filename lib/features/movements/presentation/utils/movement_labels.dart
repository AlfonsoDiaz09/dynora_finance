import 'package:dynora_finance/core/enums/payment_method.dart';
import 'package:dynora_finance/features/movements/domain/entities/movement_entity.dart';

extension PaymentMethodLabel on PaymentMethod {
  String get label => switch (this) {
    PaymentMethod.cash => 'Efectivo',
    PaymentMethod.transfer => 'Transferencia',
    PaymentMethod.card => 'Tarjeta',
  };
}

extension MovementInstallmentLabel on MovementEntity {
  /// `12 MSI` or `12 meses con intereses`; `null` for single charges.
  String? get installmentTag {
    if (!hasInstallments) return null;
    return hasInterest
        ? '$installmentCount meses con intereses'
        : '$installmentCount MSI';
  }
}
