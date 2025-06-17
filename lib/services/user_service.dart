import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/transaction_model.dart';

class UserService {
  static const String _userKey = 'user_data';
  static const String _transactionsKey = 'transactions_data';
  static const String _isOnboardedKey = 'is_onboarded';

  // Save user data
  static Future<void> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
    await prefs.setBool(_isOnboardedKey, true);
  }

  // Get user data
  static Future<UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      return UserModel.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  // Check if user is onboarded
  static Future<bool> isOnboarded() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isOnboardedKey) ?? false;
  }

  // Update user savings
  static Future<void> updateUserSavings(double newSavingsAmount) async {
    final user = await getUser();
    if (user != null) {
      final updatedUser = user.copyWith(
        totalSaved: user.totalSaved + newSavingsAmount,
        walletBalance: user.walletBalance + newSavingsAmount,
      );
      await saveUser(updatedUser);
    }
  }

  // Save transaction
  static Future<void> saveTransaction(TransactionModel transaction) async {
    final prefs = await SharedPreferences.getInstance();
    final transactionsJson = prefs.getString(_transactionsKey);
    List<TransactionModel> transactions = [];
    
    if (transactionsJson != null) {
      final List<dynamic> transactionsList = jsonDecode(transactionsJson);
      transactions = transactionsList.map((json) => TransactionModel.fromJson(json)).toList();
    }
    
    transactions.insert(0, transaction); // Add to beginning for recent first
    
    // Keep only last 50 transactions
    if (transactions.length > 50) {
      transactions = transactions.take(50).toList();
    }
    
    final updatedJson = jsonEncode(transactions.map((t) => t.toJson()).toList());
    await prefs.setString(_transactionsKey, updatedJson);
  }

  // Get transactions
  static Future<List<TransactionModel>> getTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final transactionsJson = prefs.getString(_transactionsKey);
    
    if (transactionsJson != null) {
      final List<dynamic> transactionsList = jsonDecode(transactionsJson);
      return transactionsList.map((json) => TransactionModel.fromJson(json)).toList();
    }
    
    return [];
  }

  // Clear all data (for testing)
  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Get mock transactions for demo
  static List<TransactionModel> getMockTransactions() {
    return [
      TransactionModel(
        id: '1',
        type: 'savings',
        amount: 100.0,
        savingsAmount: 1.0,
        recipient: 'John Doe',
        reason: 'Lunch payment',
        momoProvider: 'MTN',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      TransactionModel(
        id: '2',
        type: 'savings',
        amount: 50.0,
        savingsAmount: 0.5,
        recipient: 'Jane Smith',
        reason: 'Transport',
        momoProvider: 'Vodafone',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
      ),
      TransactionModel(
        id: '3',
        type: 'savings',
        amount: 200.0,
        savingsAmount: 2.0,
        recipient: 'Bob Wilson',
        reason: 'Groceries',
        momoProvider: 'AirtelTigo',
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];
  }
}