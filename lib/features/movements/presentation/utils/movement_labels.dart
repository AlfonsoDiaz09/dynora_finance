import 'package:dynora_finance/core/enums/movement_type.dart';
import 'package:dynora_finance/core/enums/payment_method.dart';
import 'package:dynora_finance/features/categories/domain/entities/category_entity.dart';
import 'package:dynora_finance/app/theme/app_colors.dart';
import 'package:dynora_finance/features/movements/domain/entities/movement_entity.dart';
import 'package:dynora_finance/shared/utils/category_icons.dart';
import 'package:flutter/material.dart';

extension PaymentMethodLabel on PaymentMethod {
  String get label => switch (this) {
    PaymentMethod.cash => 'Efectivo',
    PaymentMethod.transfer => 'Transferencia',
    PaymentMethod.card => 'Tarjeta',
  };
}

extension MovementCategoryLabel on MovementEntity {
  /// Category name, `Disposición de efectivo` for card cash withdrawals.
  String categoryName(Map<String, CategoryEntity> categories) =>
      isCashWithdrawal
      ? 'Disposición de efectivo'
      : categories[categoryId]?.name ?? 'Sin categoría';

  /// Whether lists show it as money going out. Cash withdrawals bring money
  /// in, so they show as income outside the card's statement.
  bool get showsAsExpense => isExpense && !isCashWithdrawal;

  /// Icon of its category (an ATM for cash withdrawals).
  IconData? categoryIcon(Map<String, CategoryEntity> categories) =>
      isCashWithdrawal
      ? Icons.local_atm_rounded
      : switch (categories[categoryId]) {
          final category? => CategoryIcons.of(category.iconKey),
          null => null,
        };

  /// Color of its category.
  Color? categoryColor(Map<String, CategoryEntity> categories) =>
      isCashWithdrawal
      ? AppColors.info
      : switch (categories[categoryId]) {
          final category? => Color(category.colorValue),
          null => null,
        };

  /// Type used for color and sign outside the card's statement.
  MovementType get displayType =>
      showsAsExpense ? MovementType.expense : MovementType.income;
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
