class UserModel {
  final String fullName;
  final String momoNumber;
  final String momoProvider;
  final double savingsPercentage;
  final double totalSaved;
  final double walletBalance;
  final double lockboxBalance;

  UserModel({
    required this.fullName,
    required this.momoNumber,
    required this.momoProvider,
    required this.savingsPercentage,
    this.totalSaved = 0.0,
    this.walletBalance = 0.0,
    this.lockboxBalance = 0.0,
  });

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'momoNumber': momoNumber,
      'momoProvider': momoProvider,
      'savingsPercentage': savingsPercentage,
      'totalSaved': totalSaved,
      'walletBalance': walletBalance,
      'lockboxBalance': lockboxBalance,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      fullName: json['fullName'] ?? '',
      momoNumber: json['momoNumber'] ?? '',
      momoProvider: json['momoProvider'] ?? '',
      savingsPercentage: json['savingsPercentage']?.toDouble() ?? 1.0,
      totalSaved: json['totalSaved']?.toDouble() ?? 0.0,
      walletBalance: json['walletBalance']?.toDouble() ?? 0.0,
      lockboxBalance: json['lockboxBalance']?.toDouble() ?? 0.0,
    );
  }

  UserModel copyWith({
    String? fullName,
    String? momoNumber,
    String? momoProvider,
    double? savingsPercentage,
    double? totalSaved,
    double? walletBalance,
    double? lockboxBalance,
  }) {
    return UserModel(
      fullName: fullName ?? this.fullName,
      momoNumber: momoNumber ?? this.momoNumber,
      momoProvider: momoProvider ?? this.momoProvider,
      savingsPercentage: savingsPercentage ?? this.savingsPercentage,
      totalSaved: totalSaved ?? this.totalSaved,
      walletBalance: walletBalance ?? this.walletBalance,
      lockboxBalance: lockboxBalance ?? this.lockboxBalance,
    );
  }
}