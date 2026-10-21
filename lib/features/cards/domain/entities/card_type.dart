enum CardType {
  credit,
  debit,
  departmental;

  /// Credit and departmental cards are billed by period (cutoff + payment).
  bool get hasBillingCycle => this != CardType.debit;
}
