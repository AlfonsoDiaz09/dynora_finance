import 'package:dynora_finance/shared/utils/formatters.dart';
import 'package:dynora_finance/shared/utils/group_by_day.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('groups by calendar day keeping the order', () {
    final items = [
      ('Café', DateTime(2026, 10, 21, 18)),
      ('Uber', DateTime(2026, 10, 21, 9)),
      ('Súper', DateTime(2026, 10, 18, 12)),
      ('Cine', DateTime(2026, 10, 18, 20)),
    ];
    final groups = groupByDay(items, (item) => item.$2);
    expect(groups.map((g) => g.$1), [
      DateTime(2026, 10, 21),
      DateTime(2026, 10, 18),
    ]);
    expect(groups.first.$2.map((i) => i.$1), ['Café', 'Uber']);
    expect(groups.last.$2.map((i) => i.$1), ['Súper', 'Cine']);
  });

  test('month and two-digit year', () {
    expect(Formatters.monthShortYear(DateTime(2026, 9, 2)), 'Sep 26');
    expect(Formatters.monthShortYear(DateTime(2030, 1, 1)), 'Ene 30');
    expect(Formatters.monthShortYear(DateTime(2105, 12, 1)), 'Dic 05');
  });
}
