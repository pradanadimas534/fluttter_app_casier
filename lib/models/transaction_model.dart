class TransactionModel {
  final String id;
  final DateTime date;
  final double total;
  final int totalItem;

  TransactionModel({
    required this.id,
    required this.date,
    required this.total,
    required this.totalItem,
  });
}