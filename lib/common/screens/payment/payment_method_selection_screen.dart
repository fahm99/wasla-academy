import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/course.dart';
import '../../services/payment_service_manager.dart';
import '../../themes/app_theme.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/custom_dialog.dart';
import 'payment_simulation_screen.dart';

/// شاشة اختيار طريقة الدفع
/// تتيح للمستخدم اختيار بين بنك الكريمي الحقيقي أو المحاكاة
class PaymentMethodSelectionScreen extends StatefulWidget {
  final Course course;
  final String userId;
  final double amount;

  const PaymentMethodSelectionScreen({
    super.key,
    required this.course,
    required this.userId,
    required this.amount,
  });

  @override
  State<PaymentMethodSelectionScreen> createState() =>
      _PaymentMethodSelectionScreenState();
}

class _PaymentMethodSelectionScreenState
    extends State<PaymentMethodSelectionScreen> with TickerProviderStateMixin {
  bool _isProcessing = false;
  PaymentServiceType? _selectedPaymentType;

  // Payment manager instance
  final PaymentServiceManager paymentManager = PaymentServiceManager();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
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

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _selectPaymentMethod(PaymentServiceType paymentType) {
    setState(() {
      _selectedPaymentType = paymentType;
    });

    HapticFeedback.selectionClick();
  }

  Future<void> _proceedWithSelectedMethod() async {
    if (_selectedPaymentType == null) {
      _showErrorDialog('يرجى اختيار طريقة الدفع أولاً');
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    HapticFeedback.mediumImpact();

    try {
      switch (_selectedPaymentType!) {
        case PaymentServiceType.alkuraimi:
          await _handleAlkuraimiPayment();
          break;
        case PaymentServiceType.simulation:
          await _handleSimulationPayment();
          break;
      }
    } catch (e) {
      _showErrorDialog('حدث خطأ أثناء معالجة الدفع: ${e.toString()}');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _handleAlkuraimiPayment() async {
    // إظهار رسالة أن الخدمة قيد التطوير
    await CustomDialog.show(
      context: context,
      type: DialogType.info,
      title: 'قريباً! 🏦',
      message: 'معذرة، سيتم التكامل مع بنك الكريمي قريباً.\n'
          'يمكنك استخدام وضع المحاكاة للاختبار حالياً.',
    );
  }

  Future<void> _handleSimulationPayment() async {
    // تعيين نوع الخدمة للمحاكاة
    paymentManager.setServiceType(PaymentServiceType.simulation);

    // الانتقال لشاشة المحاكاة
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentSimulationScreen(
          course: widget.course,
          userId: widget.userId,
          amount: widget.amount,
        ),
      ),
    );

    if (result == true) {
      // نجح الدفع، العودة مع النتيجة
      Navigator.of(context).pop(true);
    }
  }

  void _showErrorDialog(String errorMessage) {
    CustomDialog.showError(
      context: context,
      title: 'خطأ',
      message: errorMessage,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('اختيار طريقة الدفع'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: _isProcessing
              ? const Center(child: LoadingWidget())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCourseInfoCard(),
                      const SizedBox(height: 24),
                      _buildPaymentMethodsTitle(),
                      const SizedBox(height: 16),
                      _buildAlkuraimiPaymentOption(),
                      const SizedBox(height: 16),
                      _buildSimulationPaymentOption(),
                      const SizedBox(height: 32),
                      _buildContinueButton(),
                      const SizedBox(height: 16),
                      _buildInfoSection(),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildCourseInfoCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
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
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'المبلغ: ${widget.amount.toStringAsFixed(0)} ريال',
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
      ),
    );
  }

  Widget _buildPaymentMethodsTitle() {
    return Text(
      'اختر طريقة الدفع المناسبة لك:',
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildAlkuraimiPaymentOption() {
    final isSelected = _selectedPaymentType == PaymentServiceType.alkuraimi;

    return GestureDetector(
      onTap: () => _selectPaymentMethod(PaymentServiceType.alkuraimi),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor.withOpacity(0.1)
              : Colors.white,
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryColor
                : Colors.grey.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF1B5E20).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.account_balance,
                color: Color(0xFF1B5E20),
                size: 30,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'بنك الكريمي',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'قريباً',
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: Colors.orange[800],
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'دفع حقيقي عبر بنك الكريمي',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '• تحويل مباشر وآمن\n• دعم جميع البطاقات\n• تأكيد فوري',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[500],
                        ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppTheme.primaryColor,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimulationPaymentOption() {
    final isSelected = _selectedPaymentType == PaymentServiceType.simulation;

    return GestureDetector(
      onTap: () => _selectPaymentMethod(PaymentServiceType.simulation),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor.withOpacity(0.1)
              : Colors.white,
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryColor
                : Colors.grey.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.computer,
                color: AppTheme.primaryColor,
                size: 30,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'محاكاة الدفع',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'متاح',
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: Colors.green[800],
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'للاختبار والتجريب (موصى به)',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '• آمن تماماً للاختبار\n• تفعيل فوري للكورس\n• لا يؤثر على الحسابات الحقيقية',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.grey[500],
                        ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppTheme.primaryColor,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed:
            _selectedPaymentType == null ? null : _proceedWithSelectedMethod,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.goldColor,
          foregroundColor: AppTheme.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        ),
        child: _isProcessing
            ? const CircularProgressIndicator(color: AppTheme.primaryColor)
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.arrow_forward),
                  const SizedBox(width: 8),
                  Text(
                    'متابعة',
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

  Widget _buildInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blue.withOpacity(0.2),
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
                color: Colors.blue.shade700,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'معلومات مهمة',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '• يمكنك استخدام محاكاة الدفع للاختبار بأمان تام\n'
            '• سيتم إضافة المزيد من طرق الدفع قريباً\n'
            '• جميع المعاملات مشفرة ومحمية\n'
            '• ستحصل على إشعار فور تأكيد الدفع',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.blue.shade600,
                ),
          ),
        ],
      ),
    );
  }
}
