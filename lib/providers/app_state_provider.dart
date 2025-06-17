import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/transaction_model.dart';
import '../services/user_service.dart';
import '../services/payment_service.dart';

class AppStateProvider with ChangeNotifier {
  UserModel? _user;
  List<TransactionModel> _transactions = [];
  bool _isLoading = false;
  bool _isOnboarded = false;

  // Getters
  UserModel? get user => _user;
  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;
  bool get isOnboarded => _isOnboarded;
  
  double get totalSaved => _user?.totalSaved ?? 0.0;
  double get walletBalance => _user?.walletBalance ?? 0.0;
  double get lockboxBalance => _user?.lockboxBalance ?? 0.0;
  
  // Emergency fund goal (mock)
  double get emergencyFundGoal => 500.0;
  double get emergencyFundProgress => PaymentService.calculateGoalProgress(totalSaved, emergencyFundGoal);
  
  // Recent savings transactions (last 5)
  List<TransactionModel> get recentSavingsTransactions {
    return _transactions
        .where((t) => t.type == 'payment' || t.type == 'savings')
        .take(5)
        .toList();
  }

  // Initialize app state
  Future<void> initializeApp() async {
    _setLoading(true);
    
    try {
      // Check if user is onboarded
      _isOnboarded = await UserService.isOnboarded();
      
      if (_isOnboarded) {
        // Load user data
        _user = await UserService.getUser();
        
        // Load transactions
        _transactions = await UserService.getTransactions();
        
        // If no transactions exist, add mock data for demo
        if (_transactions.isEmpty) {
          _transactions = UserService.getMockTransactions();
        }
      }
    } catch (e) {
      debugPrint('Error initializing app: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Complete onboarding
  Future<void> completeOnboarding({
    required String fullName,
    required String momoNumber,
    required String momoProvider,
    required double savingsPercentage,
  }) async {
    _setLoading(true);
    
    try {
      final user = UserModel(
        fullName: fullName,
        momoNumber: momoNumber,
        momoProvider: momoProvider,
        savingsPercentage: savingsPercentage,
        totalSaved: 3.5, // Start with some mock savings
        walletBalance: 3.5,
        lockboxBalance: 0.0,
      );
      
      await UserService.saveUser(user);
      _user = user;
      _isOnboarded = true;
      
      // Add mock transactions for demo
      _transactions = UserService.getMockTransactions();
      for (final transaction in _transactions) {
        await UserService.saveTransaction(transaction);
      }
      
    } catch (e) {
      debugPrint('Error completing onboarding: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Process payment
  Future<PaymentResult> processPayment({
    required String recipient,
    required double amount,
    required String reason,
    required String momoProvider,
  }) async {
    if (_user == null) {
      return PaymentResult(
        success: false,
        message: 'User not found',
        transaction: null,
        savingsAmount: 0,
      );
    }
    
    _setLoading(true);
    
    try {
      final result = await PaymentService.processPayment(
        recipient: recipient,
        amount: amount,
        reason: reason,
        momoProvider: momoProvider,
        savingsPercentage: _user!.savingsPercentage,
      );
      
      if (result.success) {
        // Refresh user data
        _user = await UserService.getUser();
        
        // Refresh transactions
        _transactions = await UserService.getTransactions();
      }
      
      return result;
    } catch (e) {
      debugPrint('Error processing payment: $e');
      return PaymentResult(
        success: false,
        message: 'Payment failed: $e',
        transaction: null,
        savingsAmount: 0,
      );
    } finally {
      _setLoading(false);
    }
  }

  // Update savings percentage
  Future<void> updateSavingsPercentage(double newPercentage) async {
    if (_user == null) return;
    
    _setLoading(true);
    
    try {
      final updatedUser = _user!.copyWith(savingsPercentage: newPercentage);
      await UserService.saveUser(updatedUser);
      _user = updatedUser;
    } catch (e) {
      debugPrint('Error updating savings percentage: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Clear all data (for testing)
  Future<void> clearAllData() async {
    _setLoading(true);
    
    try {
      await UserService.clearAllData();
      _user = null;
      _transactions = [];
      _isOnboarded = false;
    } catch (e) {
      debugPrint('Error clearing data: $e');
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}