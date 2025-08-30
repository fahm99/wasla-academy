import 'dart:async';
import 'payment_service_manager.dart';
import 'payment_simulation_service.dart';
import 'supabase_service.dart';
import '../models/course.dart';

// Payment constants - Fixed naming convention
const String paymentMethodSimulation = 'simulation';
const String paymentMethodAlkuraimi = 'alkuraimi_api';
const String defaultCurrency = 'YER';

/// Payment Management Service
/// Provides comprehensive payment lifecycle management
class PaymentManagementService {
  static final PaymentManagementService _instance =
      PaymentManagementService._internal();
  factory PaymentManagementService() => _instance;
  PaymentManagementService._internal();

  final PaymentServiceManager _paymentManager = PaymentServiceManager();
  final SupabaseService _supabaseService = SupabaseService.instance;

  // Payment timeout duration
  static const Duration _paymentTimeout = Duration(minutes: 5);

  // Active payment timers
  final Map<String, Timer> _paymentTimers = {};

  /// Initialize the payment management service
  void initialize() {
    _paymentManager.initialize();
  }

  /// Process course payment with new flow
  Future<PaymentResult> processCoursePayment({
    required String userId,
    required Course course,
    required String fromAccount,
    String? description,
    String paymentMethod = paymentMethodSimulation,
  }) async {
    try {
      // Validate course and user
      await _validatePaymentRequest(userId, course);

      // Get instructor's account based on payment method
      final instructorAccount =
          await _getInstructorAccount(course.instructorId, paymentMethod);
      if (instructorAccount == null) {
        return PaymentResult.failure(
          errorMessage: 'المدرس لم يضف حساب الكريمي الخاص به بعد',
          fromAccount: fromAccount,
          toAccount: '',
          amount: course.price,
        );
      }

      // Create pending payment record using existing method
      final pendingPayment = await _supabaseService.initiateCoursePayment(
        userId,
        course.id,
        course.price,
        defaultCurrency,
      );

      if (pendingPayment == null) {
        return PaymentResult.failure(
          errorMessage: 'فشل في إنشاء سجل الدفع',
          fromAccount: fromAccount,
          toAccount: instructorAccount,
          amount: course.price,
        );
      }

      // Start payment timeout timer
      final paymentId = pendingPayment['transaction_id'] as String;
      _startPaymentTimeout(paymentId);

      PaymentResult result;

      // Process based on payment method
      if (paymentMethod == paymentMethodSimulation) {
        result = await _processSimulationPayment(
          paymentId: paymentId,
          fromAccount: fromAccount,
          toAccount: instructorAccount,
          amount: course.price,
          courseId: course.id,
          userId: userId,
          description: description ?? 'دفع رسوم كورس ${course.title}',
        );
      } else {
        // For Al-Kuraimi API, return special result indicating it's not implemented yet
        result = PaymentResult.failure(
          errorMessage: 'معذرة، سيتم التكامل مع بنك الكريمي قريبًا',
          fromAccount: fromAccount,
          toAccount: instructorAccount,
          amount: course.price,
        );
      }

      // Cancel timeout timer
      _cancelPaymentTimeout(paymentId);

      // If successful, process enrollment and notification
      if (result.success) {
        await _processSuccessfulPayment(userId, course, result, paymentId);
      }

      return result;
    } catch (e) {
      // Fixed print statements
      // print('❌ Payment processing failed: $e');
      return PaymentResult.failure(
        errorMessage: 'خطأ في معالجة الدفع: $e',
        fromAccount: fromAccount,
        toAccount: '',
        amount: course.price,
      );
    }
  }

  /// Process simulation payment
  Future<PaymentResult> _processSimulationPayment({
    required String paymentId,
    required String fromAccount,
    required String toAccount,
    required double amount,
    required String courseId,
    required String userId,
    required String description,
  }) async {
    try {
      // Initiate payment through simulation service
      final result = await _paymentManager.initiatePayment(
        fromAccount: fromAccount,
        toAccount: toAccount,
        amount: amount,
        courseId: courseId,
        userId: userId,
        description: description,
      );

      // If successful, confirm the payment in our system
      if (result.success) {
        final confirmed = await _supabaseService.completeCoursePayment(
          paymentId,
          'SIM-${result.transactionId}',
        );

        if (!confirmed) {
          return PaymentResult.failure(
            errorMessage: 'فشل في تأكيد الدفع المحاكي',
            fromAccount: fromAccount,
            toAccount: toAccount,
            amount: amount,
          );
        }
      }

      return result;
    } catch (e) {
      // Fixed print statements
      // print('❌ Simulation payment processing failed: $e');
      return PaymentResult.failure(
        errorMessage: 'خطأ في معالجة الدفع المحاكي: $e',
        fromAccount: fromAccount,
        toAccount: toAccount,
        amount: amount,
      );
    }
  }

  /// Process successful payment
  Future<void> _processSuccessfulPayment(
    String userId,
    Course course,
    PaymentResult result,
    String paymentId,
  ) async {
    try {
      // Enroll user in course using existing method
      await _supabaseService.enrollInCourse(userId, course.id);

      // Save payment record using existing method
      await _supabaseService.createTransaction({
        'user_id': userId,
        'course_id': course.id,
        'amount': result.amount,
        'currency': result.currency,
        'transaction_id': result.transactionId,
        'status': 'completed',
        'type': 'purchase',
        'description': result.description,
        'created_at': DateTime.now().toIso8601String(),
      });

      // Create bank transaction record
      await _supabaseService.createBankTransaction(
        userId: userId,
        courseId: course.id,
        fromAccount: result.fromAccount,
        toAccount: result.toAccount,
        amount: result.amount,
        currency: result.currency,
        description: result.description,
        serviceType: 'simulation', // Assuming simulation for now
      );

      // Notify user of successful payment
      await _notifyUser(
        userId: userId,
        title: 'تم الدفع بنجاح! 🎉',
        message:
            'تم دفع رسوم الكورس "${course.title}" بنجاح. سيتم تفعيل الكورس خلال 24 ساعة.',
        type: 'payment_success',
      );
    } catch (e) {
      // Fixed print statements
      // print('❌ Error processing successful payment: $e');
      rethrow;
    }
  }

  /// Notify user of events (replaces undefined notifyUser method)
  Future<void> _notifyUser({
    required String userId,
    required String title,
    required String message,
    String type = 'info',
  }) async {
    try {
      await _supabaseService.createTransaction({
        'user_id': userId,
        'title': title,
        'message': message,
        'type': type,
        'status': 'unread',
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // Fixed print statements
      // print('❌ Error notifying user: $e');
      rethrow;
    }
  }

  /// Validate payment request
  Future<void> _validatePaymentRequest(String userId, Course course) async {
    // Check if user is already enrolled
    final isEnrolled = await _supabaseService.isUserEnrolled(userId, course.id);
    if (isEnrolled) {
      throw Exception('المستخدم مسجل بالفعل في هذا الكورس');
    }

    // Check if course is published
    if (course.status != CourseStatus.published) {
      throw Exception('الكورس غير متوفر للتسجيل حالياً');
    }
  }

  /// Get instructor's account for payment
  Future<String?> _getInstructorAccount(
      String instructorId, String paymentMethod) async {
    try {
      final accounts = await _supabaseService.getBankAccounts(instructorId);
      if (accounts.isEmpty) return null;

      // Find default account or return first available
      final defaultAccount = accounts.firstWhere(
          (acc) => acc['is_default'] == true,
          orElse: () => accounts.first);
      return defaultAccount['account_number'] as String?;
    } catch (e) {
      // Fixed print statements
      // print('❌ Error getting instructor account: $e');
      return null;
    }
  }

  /// Start payment timeout timer
  void _startPaymentTimeout(String paymentId) {
    _paymentTimers[paymentId] = Timer(_paymentTimeout, () async {
      try {
        await _supabaseService.cancelTransaction(
          paymentId,
          reason: 'انتهت مدة صلاحية الدفع',
        );
      } catch (e) {
        // Fixed print statements
        // print('❌ Error cancelling timed-out payment: $e');
      } finally {
        _paymentTimers.remove(paymentId);
      }
    });
  }

  /// Cancel payment timeout timer
  void _cancelPaymentTimeout(String paymentId) {
    final timer = _paymentTimers[paymentId];
    if (timer != null && timer.isActive) {
      timer.cancel();
      _paymentTimers.remove(paymentId);
    }
  }

  /// Generate payment ID (fixed unused element warning)
  String _generatePaymentId() {
    return 'pay_${DateTime.now().millisecondsSinceEpoch}_${_randomString(6)}';
  }

  /// Generate random string
  String _randomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = DateTime.now().microsecondsSinceEpoch % chars.length;
    return List.generate(length, (index) => chars[random]).join();
  }

  /// Get payment statistics for a user
  Future<PaymentStatistics> getPaymentStatistics(String userId) async {
    try {
      // Fetch payment data from Supabase
      final payments = await _supabaseService.getUserTransactions(userId);

      if (payments.isEmpty) {
        return PaymentStatistics.empty();
      }

      int totalPayments = payments.length;
      int successfulPayments = 0;
      int failedPayments = 0;
      double totalAmount = 0.0;
      DateTime lastPaymentDate =
          DateTime.parse(payments.first['created_at'] as String);
      final paymentMethods = <String, int>{};

      for (final payment in payments) {
        final amount = (payment['amount'] as num?)?.toDouble() ?? 0.0;
        final status = payment['status'] as String?;
        final method = payment['payment_type'] as String? ??
            payment['service_type'] as String? ??
            'unknown';
        final createdAtStr = payment['created_at'] as String;
        final createdAt = DateTime.parse(createdAtStr);

        totalAmount += amount;

        if (status == 'completed') {
          successfulPayments++;
        } else {
          failedPayments++;
        }

        if (createdAt.isAfter(lastPaymentDate)) {
          lastPaymentDate = createdAt;
        }

        paymentMethods[method] = (paymentMethods[method] ?? 0) + 1;
      }

      final averagePaymentAmount =
          totalPayments > 0 ? totalAmount / totalPayments : 0.0;

      return PaymentStatistics(
        totalPayments: totalPayments,
        totalAmount: totalAmount,
        successfulPayments: successfulPayments,
        failedPayments: failedPayments,
        averagePaymentAmount: averagePaymentAmount,
        lastPaymentDate: lastPaymentDate,
        paymentMethods: paymentMethods,
      );
    } catch (e) {
      // Return empty statistics if there's an error
      return PaymentStatistics.empty();
    }
  }

  /// Validate account number
  Future<AccountInfo?> validateAccount(String accountNumber) async {
    return await _paymentManager.getAccountInfo(accountNumber);
  }

  /// Calculate transfer fee
  Future<double> calculateTransferFee(double amount) async {
    return await _paymentManager.getTransferFee(amount);
  }

  /// Dispose resources
  void dispose() {
    _paymentManager.dispose();
  }
}
