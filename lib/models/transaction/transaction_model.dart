class TransactionModel {
  final String transactionType;
  final double amount;
  final String refName;
  final String transactionStatus;
  final String description;
  final String reference;
  final DateTime date;
  final String transactionId;

  TransactionModel({
    required this.transactionType,
    required this.amount,
    required this.refName,
    required this.transactionStatus,
    required this.description,
    required this.reference,
    required this.date,
    required this.transactionId
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      transactionType: json['transactionType'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      refName: json['refName'] ?? '',
      transactionStatus: json['transactionStatus'] ?? '',
      description: json['description'] ?? '',
      reference: json['reference'] ?? '',
      date: DateTime.parse(json['date']),
      transactionId: json['_id'] ?? ''
    );
  }
}