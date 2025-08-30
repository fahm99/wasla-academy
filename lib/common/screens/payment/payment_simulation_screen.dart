import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/course.dart';
import '../../services/payment_service_manager.dart';
import '../../services/payment_simulation_service.dart';
import '../../services/supabase_service.dart';
import '../../themes/app_theme.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/custom_dialog.dart';

/// Payment simulation screen
/// Simulates bank transfer process with interactive UI
class PaymentSimulationScreen extends StatefulWidget {
  final Course course;
  final String userId;
  final double amount;

  const PaymentSimulationScreen({
    super.key,
    required this.course,
    required this.userId,
    required this.amount,
  });

  @override
  State<PaymentSimulationScreen> createState() =>
      _PaymentSimulationScreenState();
}

class _PaymentSimulationScreenState extends State<PaymentSimulationScreen>
    with TickerProviderStateMixin {
  // Controllers
  final _formKey = GlobalKey<FormState>();
  final _fromAccountController = TextEditingController();
  final _toAccountController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Payment manager instance
  final PaymentServiceManager paymentManager = PaymentServiceManager();

  // State
  bool _isLoading = false;
  bool _isValidatingAccounts = false;
  AccountInfo? _fromAccountInfo;
  AccountInfo? _toAccountInfo;

  // Animations
  late AnimationController _animationController;
  late AnimationController _progressAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupControllers();
    _loadInstructorAccount();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressAnimationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  void _setupControllers() {
    // Set default amount
    _amountController.text = widget.amount.toStringAsFixed(0);

    // Default description
    _descriptionController.text = 'Payment for course: ${widget.course.title}';

    // Monitor changes to sender account field
    _fromAccountController.addListener(() {
      if (_fromAccountController.text.length >= 10) {
        _validateAccount(_fromAccountController.text, isFromAccount: true);
      } else {
        setState(() {
          _fromAccountInfo = null;
        });
      }
    });
  }

  void _loadInstructorAccount() {
    // Load instructor account (from database or default setting)
    _toAccountController.text =
        widget.course.instructorAlkuraimiAccount ?? '400001234567';
    _validateAccount(_toAccountController.text, isFromAccount: false);
  }

  Future<void> _validateAccount(String accountNumber,
      {required bool isFromAccount}) async {
    if (_isValidatingAccounts) return;

    setState(() {
      _isValidatingAccounts = true;
    });

    try {
      final accountInfo = await paymentManager.getAccountInfo(accountNumber);

      setState(() {
        if (isFromAccount) {
          _fromAccountInfo = accountInfo;
        } else {
          _toAccountInfo = accountInfo;
        }
      });
    } catch (e) {
      // Ignore errors to avoid disturbing user while typing
    } finally {
      setState(() {
        _isValidatingAccounts = false;
      });
    }
  }

  Future<void> _processPayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    _progressAnimationController.forward();
    HapticFeedback.mediumImpact();

    try {
      // Simulate payment process
      final result = await paymentManager.initiatePayment(
        fromAccount: _fromAccountController.text.trim(),
        toAccount: _toAccountController.text.trim(),
        amount: double.parse(_amountController.text),
        courseId: widget.course.id,
        userId: widget.userId,
        description: _descriptionController.text.trim(),
      );

      if (result.success) {
        // Save payment transaction to database
        await _savePaymentToDatabase(result);

        // Show success result
        await _showSuccessResult(result);

        // Return with success result
        Navigator.of(context).pop(true);
      } else {
        _showErrorDialog(result.errorMessage ?? 'Payment processing failed');
      }
    } catch (e) {
      _showErrorDialog('Error processing payment: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
      _progressAnimationController.reset();
    }
  }

  Future<void> _savePaymentToDatabase(PaymentResult result) async {
    try {
      await SupabaseService.instance.createTransaction({
        'user_id': widget.userId,
        'course_id': widget.course.id,
        'amount': result.amount,
        'currency': result.currency,
        'type': 'purchase',
        'status': 'completed',
        'payment_type': 'simulation',
        'from_account': result.fromAccount,
        'to_account': result.toAccount,
        'notes': result.description,
      });

      // Create bank transaction record
      await SupabaseService.instance.createBankTransaction(
        userId: widget.userId,
        courseId: widget.course.id,
        fromAccount: result.fromAccount,
        toAccount: result.toAccount,
        amount: result.amount,
        currency: result.currency,
        description: result.description,
        serviceType: 'simulation',
      );
    } catch (e) {
      print('Error saving payment to database: $e');
      // Don't stop the process, just log the error
    }
  }

  Future<void> _showSuccessResult(PaymentResult result) async {
    await CustomDialog.showSuccess(
      context: context,
      title: 'Payment Successful! 🎉',
      message: 'Transaction ID: ${result.transactionId}\n'
          'Amount: ${result.amount.toStringAsFixed(2)} ${result.currency}\n'
          'Successfully enrolled in the course!',
    );
  }

  void _showErrorDialog(String errorMessage) {
    CustomDialog.showError(
      context: context,
      title: 'Payment Failed',
      message: errorMessage,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _progressAnimationController.dispose();
    _fromAccountController.dispose();
    _toAccountController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bank Transfer Simulation'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: _isLoading
              ? _buildLoadingScreen()
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSimulationBanner(),
                        const SizedBox(height: 24),
                        _buildCourseInfoCard(),
                        const SizedBox(height: 24),
                        _buildTransferForm(),
                        const SizedBox(height: 32),
                        _buildProcessButton(),
                        const SizedBox(height: 16),
                        _buildTestAccountsInfo(),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const LoadingWidget(),
          const SizedBox(height: 24),
          Text(
            'Processing transfer...',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Container(
            width: 200,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(2),
            ),
            child: AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                return Container(
                  width: 200 * _progressAnimation.value,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Simulating bank response...',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimulationBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.shade50,
            Colors.blue.shade100,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blue.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.computer,
            color: Colors.blue.shade700,
            size: 30,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Simulation Mode',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'You are using a safe bank transfer simulation. This will not affect your real accounts.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.blue.shade600,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseInfoCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Course Details',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.play_circle_fill,
                    size: 30,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.course.title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Instructor: ${widget.course.instructorName ?? 'Not specified'}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Amount: ${widget.amount.toStringAsFixed(0)} SAR',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransferForm() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transfer Details',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 20),
            _buildFromAccountField(),
            const SizedBox(height: 16),
            _buildToAccountField(),
            const SizedBox(height: 16),
            _buildAmountField(),
            const SizedBox(height: 16),
            _buildDescriptionField(),
          ],
        ),
      ),
    );
  }

  Widget _buildFromAccountField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _fromAccountController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(12),
          ],
          decoration: InputDecoration(
            labelText: 'Your Account Number *',
            hintText: 'Enter your Al-Kuraimi bank account number',
            prefixIcon: const Icon(Icons.account_balance_wallet),
            suffixIcon: _isValidatingAccounts
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : null,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your account number';
            }
            if (value.length < 10) {
              return 'Account number is too short';
            }
            if (!value.startsWith('4000')) {
              return 'Account number must start with 4000';
            }
            return null;
          },
        ),
        if (_fromAccountInfo != null) ...[
          const SizedBox(height: 8),
          _buildAccountInfoDisplay(_fromAccountInfo!),
        ],
      ],
    );
  }

  Widget _buildToAccountField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _toAccountController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(12),
          ],
          decoration: const InputDecoration(
            labelText: 'Instructor Account *',
            hintText: 'Instructor account number to receive payment',
            prefixIcon: Icon(Icons.person),
            enabled: false, // Not editable
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Instructor account number is required';
            }
            return null;
          },
        ),
        if (_toAccountInfo != null) ...[
          const SizedBox(height: 8),
          _buildAccountInfoDisplay(_toAccountInfo!),
        ],
      ],
    );
  }

  Widget _buildAmountField() {
    return TextFormField(
      controller: _amountController,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      decoration: const InputDecoration(
        labelText: 'Amount *',
        hintText: 'Enter the amount to transfer',
        prefixIcon: Icon(Icons.attach_money),
        suffixText: 'SAR',
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter the amount';
        }
        final amount = double.tryParse(value);
        if (amount == null || amount <= 0) {
          return 'Please enter a valid amount';
        }
        if (amount > 10000) {
          return 'Amount exceeds maximum limit (10,000 SAR)';
        }
        if (_fromAccountInfo != null &&
            !_fromAccountInfo!.hasSufficientBalance(amount)) {
          return 'Insufficient balance';
        }
        return null;
      },
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      maxLines: 2,
      maxLength: 100,
      decoration: const InputDecoration(
        labelText: 'Transfer Description',
        hintText: 'Optional description for the transfer',
        prefixIcon: Icon(Icons.description),
      ),
    );
  }

  Widget _buildAccountInfoDisplay(AccountInfo accountInfo) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.green.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: Colors.green.shade600,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  accountInfo.holderName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                ),
                Text(
                  'Balance: ${accountInfo.balance.toStringAsFixed(2)} SAR',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.green.shade600,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _processPayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.goldColor,
          foregroundColor: AppTheme.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: AppTheme.primaryColor)
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.send),
                  const SizedBox(width: 8),
                  Text(
                    'Process Transfer',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildTestAccountsInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.amber.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.amber.shade700,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Test Accounts for Testing',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.amber.shade700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'You can use any of the following accounts for testing:\n'
            '• 400001234567 (Ahmed Mohammed - Balance: 5000 SAR)\n'
            '• 400009876543 (Fatima Ahmed - Balance: 3500 SAR)\n'
            '• 400001111111 (Mohammed Abdullah - Balance: 1200 SAR)',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.amber.shade600,
                ),
          ),
        ],
      ),
    );
  }
}

// Add extension for course instructor account
extension CoursePaymentExtension on Course {
  String? get instructorAlkuraimiAccount {
    // In real app, this would be fetched from database
    // Here we set default values for testing
    switch (instructorId) {
      case 'instructor_1':
        return '400001234567';
      case 'instructor_2':
        return '400009876543';
      default:
        return '400001111111';
    }
  }
}
