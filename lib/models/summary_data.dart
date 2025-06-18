class SummaryData {
  final double totalAmount;
  final int totalItems;
  final int totalQuantity;
  final DateTime startDate;
  final DateTime endDate;

  SummaryData({
    required this.totalAmount,
    required this.totalItems,
    required this.totalQuantity,
    required this.startDate,
    required this.endDate,
  });
}

enum SummaryPeriod {
  daily('Harian'),
  weekly('Mingguan'),
  monthly('Bulanan'),
  yearly('Tahunan'),
  custom('Custom');

  const SummaryPeriod(this.label);
  final String label;
}