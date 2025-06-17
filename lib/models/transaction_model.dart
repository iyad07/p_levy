class TransactionModel {
  final String id;
  final String type; // 'payment' or 'savings'
  final double amount;
  final double savingsAmount;
  final String recipient;
  final String reason;
  final String momoProvider;
  final DateTime timestamp;

  TransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.savingsAmount,
    required this.recipient,
    required this.reason,
    required this.momoProvider,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'amount': amount,
      'savingsAmount': savingsAmount,
      'recipient': recipient,
      'reason': reason,
      'momoProvider': momoProvider,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      amount: json['amount']?.toDouble() ?? 0.0,
      savingsAmount: json['savingsAmount']?.toDouble() ?? 0.0,
      recipient: json['recipient'] ?? '',
      reason: json['reason'] ?? '',
      momoProvider: json['momoProvider'] ?? '',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }

  String get formattedDate {
    return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
  }

  String get formattedTime {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}