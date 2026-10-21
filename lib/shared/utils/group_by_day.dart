/// Groups [items] by calendar day of [dateOf], keeping their order (days
/// appear in the order of their first item).
List<(DateTime, List<T>)> groupByDay<T>(
  Iterable<T> items,
  DateTime Function(T item) dateOf,
) {
  final groups = <DateTime, List<T>>{};
  for (final item in items) {
    final date = dateOf(item);
    groups
        .putIfAbsent(DateTime(date.year, date.month, date.day), () => [])
        .add(item);
  }
  return [for (final entry in groups.entries) (entry.key, entry.value)];
}
