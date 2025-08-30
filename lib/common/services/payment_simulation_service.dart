import 'dart:math';
import 'supabase_service.dart';

/// Al-Kuraimi Bank API Simulation Service
/// Provides realistic bank transfer simulation for testing and development
class PaymentSimulationService {
  static final PaymentSimulationService _instance =
      PaymentSimulationService._internal();
  factory PaymentSimulationService() => _instance;
  PaymentSimulationService._internal();

  /// Get account information from database
  Future<AccountInfo?> getAccountInfo(String accountNumber) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Validate account number format
    if (accountNumber.isEmpty || accountNumber.length < 6) {
      throw const PaymentException('رقم الحساب غير صالح');
    }

    try {
      // Fetch account info from database
      final accountData = await SupabaseService.instance
          .getSimulationAccountDetails(accountNumber);

      if (accountData != null) {
        return AccountInfo(
          accountNumber: accountData['account_number'] as String,
          holderName: accountData['holder_name'] as String,
          balance: (accountData['balance'] as num).toDouble(),
          bankName: accountData['bank_name'] as String,
          isActive: accountData['is_active'] as bool,
        );
      }

      return null;
    } catch (e) {
      throw PaymentException('خطأ في جلب بيانات الحساب: $e');
    }
  }

  /// Calculate transfer fees
  Future<double> getTransferFee(double amount) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    if (amount <= 0) {
      throw const PaymentException('مبلغ غير صالح');
    }

    // Fee structure: 2 SAR for amounts under 500, 0.5% for higher amounts
    if (amount < 500) {
      return 2.0;
    } else {
      return amount * 0.005; // 0.5%
    }
  }

  /// Initiate payment transfer
  Future<PaymentResult> initiatePayment({
    required String fromAccount,
    required String toAccount,
    required double amount,
    required String courseId,
    required String userId,
    String? description,
  }) async {
    // Simulate processing time
    await Future.delayed(const Duration(seconds: 2));

    try {
      // Validate accounts
      final fromAccountInfo = await getAccountInfo(fromAccount);
      final toAccountInfo = await getAccountInfo(toAccount);

      if (fromAccountInfo == null) {
        return PaymentResult.failure(
          errorMessage: 'الحساب المرسل غير موجود: $fromAccount',
          fromAccount: fromAccount,
          toAccount: toAccount,
          amount: amount,
        );
      }

      if (toAccountInfo == null) {
        return PaymentResult.failure(
          errorMessage: 'الحساب المستقبل غير موجود: $toAccount',
          fromAccount: fromAccount,
          toAccount: toAccount,
          amount: amount,
        );
      }

      // Check sufficient balance
      if (fromAccountInfo.balance < amount) {
        return PaymentResult.failure(
          errorMessage:
              'رصيد غير كافي. الرصيد الحالي: ${fromAccountInfo.balance.toStringAsFixed(2)} ريال',
          fromAccount: fromAccount,
          toAccount: toAccount,
          amount: amount,
        );
      }

      // Simulate 10% failure rate for testing
      if (Random().nextDouble() < 0.1) {
        return PaymentResult.failure(
          errorMessage: 'خطأ في الشبكة، يرجى المحاولة مرة أخرى',
          fromAccount: fromAccount,
          toAccount: toAccount,
          amount: amount,
        );
      }

      // Process successful payment
      final transactionId = _generateTransactionId();

      // Update balances in database
      final newFromBalance = fromAccountInfo.balance - amount;
      final newToBalance = toAccountInfo.balance + amount;

      await SupabaseService.instance
          .updateSimulationAccountBalance(fromAccount, newFromBalance);
      await SupabaseService.instance
          .updateSimulationAccountBalance(toAccount, newToBalance);

      return PaymentResult.success(
        transactionId: transactionId,
        fromAccount: fromAccount,
        toAccount: toAccount,
        amount: amount,
        currency: 'SAR',
        description: description ?? 'دفع رسوم الكورس',
        timestamp: DateTime.now(),
        fee: await getTransferFee(amount),
      );
    } catch (e) {
      return PaymentResult.failure(
        errorMessage: e.toString(),
        fromAccount: fromAccount,
        toAccount: toAccount,
        amount: amount,
      );
    }
  }

  /// Generate unique transaction ID
  String _generateTransactionId() {
    final now = DateTime.now();
    final random = Random().nextInt(999999);
    return 'SIM${now.millisecondsSinceEpoch}${random.toString().padLeft(6, '0')}';
  }

  /// Reset accounts to default values (for testing)
  Future<void> resetAccountsToDefaults() async {
    // Reset accounts in database to default values
    final defaultAccounts = [
      {
        'account_number': '400001234567',
        'holder_name': 'أحمد محمد علي',
        'balance': 5000.0,
        'bank_name': 'بنك الكريمي',
        'is_active': true,
      },
      {
        'account_number': '400009876543',
        'holder_name': 'فاطمة أحمد سالم',
        'balance': 3500.0,
        'bank_name': 'بنك الكريمي',
        'is_active': true,
      },
      {
        'account_number': '400001111111',
        'holder_name': 'محمد عبدالله الحسن',
        'balance': 1200.0,
        'bank_name': 'بنك الكريمي',
        'is_active': true,
      },
      {
        'account_number': '400002222222',
        'holder_name': 'نورا سعد المحمدي',
        'balance': 800.0,
        'bank_name': 'بنك الكريمي',
        'is_active': true,
      },
      {
        'account_number': '400003333333',
        'holder_name': 'عبدالرحمن يوسف',
        'balance': 2200.0,
        'bank_name': 'بنك الكريمي',
        'is_active': true,
      },
    ];

    for (final account in defaultAccounts) {
      await SupabaseService.instance.resetSimulationAccount(account);
    }
  }
}

/// Account information model
class AccountInfo {
  final String accountNumber;
  final String holderName;
  final double balance;
  final String bankName;
  final bool isActive;

  const AccountInfo({
    required this.accountNumber,
    required this.holderName,
    required this.balance,
    required this.bankName,
    required this.isActive,
  });

  AccountInfo copyWith({
    String? accountNumber,
    String? holderName,
    double? balance,
    String? bankName,
    bool? isActive,
  }) {
    return AccountInfo(
      accountNumber: accountNumber ?? this.accountNumber,
      holderName: holderName ?? this.holderName,
      balance: balance ?? this.balance,
      bankName: bankName ?? this.bankName,
      isActive: isActive ?? this.isActive,
    );
  }

  /// Check if account has sufficient balance
  bool hasSufficientBalance(double amount) {
    return balance >= amount;
  }
}

/// Payment result model
class PaymentResult {
  final bool success;
  final String? transactionId;
  final String fromAccount;
  final String toAccount;
  final double amount;
  final String currency;
  final String? description;
  final DateTime? timestamp;
  final double? fee;
  final String? errorMessage;

  const PaymentResult({
    required this.success,
    this.transactionId,
    required this.fromAccount,
    required this.toAccount,
    required this.amount,
    this.currency = 'SAR',
    this.description,
    this.timestamp,
    this.fee,
    this.errorMessage,
  });

  factory PaymentResult.success({
    required String transactionId,
    required String fromAccount,
    required String toAccount,
    required double amount,
    String currency = 'SAR',
    String? description,
    DateTime? timestamp,
    double? fee,
  }) {
    return PaymentResult(
      success: true,
      transactionId: transactionId,
      fromAccount: fromAccount,
      toAccount: toAccount,
      amount: amount,
      currency: currency,
      description: description,
      timestamp: timestamp ?? DateTime.now(),
      fee: fee,
    );
  }

  factory PaymentResult.failure({
    required String errorMessage,
    required String fromAccount,
    required String toAccount,
    required double amount,
    String currency = 'SAR',
  }) {
    return PaymentResult(
      success: false,
      fromAccount: fromAccount,
      toAccount: toAccount,
      amount: amount,
      currency: currency,
      errorMessage: errorMessage,
    );
  }
}

/// Payment exception
class PaymentException implements Exception {
  final String message;
  const PaymentException(this.message);

  @override
  String toString() => message;
}

/// Payment statistics model
class PaymentStatistics {
  final int totalPayments;
  final double totalAmount;
  final int successfulPayments;
  final int failedPayments;
  final double averagePaymentAmount;
  final DateTime lastPaymentDate;
  final Map<String, int> paymentMethods;

  const PaymentStatistics({
    required this.totalPayments,
    required this.totalAmount,
    required this.successfulPayments,
    required this.failedPayments,
    required this.averagePaymentAmount,
    required this.lastPaymentDate,
    required this.paymentMethods,
  });

  /// Create empty statistics
  factory PaymentStatistics.empty() {
    return PaymentStatistics(
      totalPayments: 0,
      totalAmount: 0.0,
      successfulPayments: 0,
      failedPayments: 0,
      averagePaymentAmount: 0.0,
      lastPaymentDate: DateTime(2000, 1, 1),
      paymentMethods: {},
    );
  }
}
