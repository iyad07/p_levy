import 'dart:math';
import '../models/transaction_model.dart';
import '../models/user_model.dart';
import 'user_service.dart';

class PaymentService {
  // Simulate payment processing
  static Future<PaymentResult> processPayment({
    required String recipient,
    required double amount,
    required String reason,
    required String momoProvider,
    required double savingsPercentage,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));
    
    // Simulate 95% success rate
    final random = Random();
    final isSuccess = random.nextDouble() > 0.05;
    
    if (!isSuccess) {
      return PaymentResult(
        success: false,
        message: 'Payment failed. Please try again.',
        transaction: null,
        savingsAmount: 0,
      );
    }
    
    // Calculate savings amount
    final savingsAmount = (amount * savingsPercentage / 100);
    
    // Create transaction
    final transaction = TransactionModel(
      id: _generateTransactionId(),
      type: 'payment',
      amount: amount,
      savingsAmount: savingsAmount,
      recipient: recipient,
      reason: reason,
      momoProvider: momoProvider,
      timestamp: DateTime.now(),
    );
    
    // Save transaction
    await UserService.saveTransaction(transaction);
    
    // Update user savings
    await UserService.updateUserSavings(savingsAmount);
    
    return PaymentResult(
      success: true,
      message: 'Payment successful!',
      transaction: transaction,
      savingsAmount: savingsAmount,
    );
  }
  
  // Generate unique transaction ID
  static String _generateTransactionId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(9999);
    return 'TXN_${timestamp}_$random';
  }
  
  // Simulate USSD prompt
  static Future<String> simulateUSSDPrompt(String momoProvider, double amount) async {
    await Future.delayed(const Duration(milliseconds: 1500));
    
    switch (momoProvider.toLowerCase()) {
      case 'mtn':
        return '*170*101*$amount#';
      case 'vodafone':
        return '*110*$amount#';
      case 'airteltigo':
        return '*185*$amount#';
      default:
        return '*000*$amount#';
    }
  }
  
  // Get available MoMo providers
  static List<String> getMoMoProviders() {
    return ['MTN', 'Vodafone', 'AirtelTigo'];
  }
  
  // Get savings percentage options
  static List<double> getSavingsPercentageOptions() {
    return [0.5, 1.0, 1.5, 2.0, 2.5, 3.0, 4.0, 5.0];
  }
  
  // Format currency
  static String formatCurrency(double amount) {
    return 'GHS ${amount.toStringAsFixed(2)}';
  }
  
  // Calculate monthly savings goal progress
  static double calculateGoalProgress(double currentSavings, double goalAmount) {
    if (goalAmount <= 0) return 0.0;
    final progress = currentSavings / goalAmount;
    return progress > 1.0 ? 1.0 : progress;
  }
}

class PaymentResult {
  final bool success;
  final String message;
  final TransactionModel? transaction;
  final double savingsAmount;
  
  PaymentResult({
    required this.success,
    required this.message,
    required this.transaction,
    required this.savingsAmount,
  });
}