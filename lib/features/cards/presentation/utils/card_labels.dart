import 'package:dynora_finance/features/cards/domain/entities/card_entity.dart';
import 'package:dynora_finance/features/cards/domain/entities/card_type.dart';

extension CardTypeLabel on CardType {
  String get label => switch (this) {
    CardType.credit => 'Crédito',
    CardType.debit => 'Débito',
    CardType.departmental => 'Departamental',
  };
}

extension CardEntityLabel on CardEntity {
  /// `•••• 1234`
  String get maskedDigits => '•••• $lastFourDigits';

  /// `Nu •• 1234`, short enough for list subtitles and chips.
  String get shortLabel => '$name •• $lastFourDigits';
}
