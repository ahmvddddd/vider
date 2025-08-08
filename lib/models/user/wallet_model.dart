class WalletModel {
  final double balance;
  final String cryptoAddress;
  final double usdcBalance;
  final String subscriptionPlan;

  WalletModel({
    required this.balance,
    required this.cryptoAddress,
    required this.usdcBalance,
    required this.subscriptionPlan,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      balance: (json['balance'] ?? 0).toDouble(),
      cryptoAddress: json['cryptoAddress'] ?? '',
      usdcBalance: (json['usdcBalance'] ?? 0).toDouble(),
      subscriptionPlan: json['subscriptionPlan'] ?? '',
    );
  }
}
