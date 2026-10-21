/// How the cost of a movement is shared.
class DebtSplit {
  const DebtSplit._();

  /// Equal parts of [total] for [people] people, plus one part kept by you
  /// when [includeMe]. Leftover cents go to the first people so the parts
  /// owed plus yours add up exactly to [total].
  static List<double> equal({
    required double total,
    required int people,
    required bool includeMe,
  }) {
    if (people <= 0) return const [];
    final parts = people + (includeMe ? 1 : 0);
    final totalCents = (total * 100).round();
    final baseCents = totalCents ~/ parts;
    // Without you in the split, everything is distributed among [people].
    final owedCents = includeMe ? baseCents * people : totalCents;
    var leftover = owedCents - baseCents * people;
    return [
      for (var i = 0; i < people; i++)
        (baseCents + (leftover-- > 0 ? 1 : 0)) / 100,
    ];
  }

  /// Your own part of [total] once others pay [owed].
  static double myShare(double total, Iterable<double> owed) {
    final rest = total - owed.fold<double>(0, (sum, a) => sum + a);
    return (rest * 100).roundToDouble() / 100;
  }
}
