import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/course.dart';
import '../../themes/app_theme.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/custom_dialog.dart';
import 'payment_method_selection_screen.dart';

/// شاشة دفع الكورس الجديدة
/// تستخدم نظام التحويل البنكي الجديد
class CoursePaymentScreen extends StatefulWidget {
  final String userId;
  final Course course;

  const CoursePaymentScreen({
    super.key,
    required this.userId,
    required this.course,
  });

  @override
  State<CoursePaymentScreen> createState() => _CoursePaymentScreenState();
}

class _CoursePaymentScreenState extends State<CoursePaymentScreen>
    with TickerProviderStateMixin {
  bool _isProcessing = false;
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
      curve: Curves.easeIn,
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

  Future<void> _proceedToPaymentSelection() async {
    setState(() {
      _isProcessing = true;
    });

    // إضافة اهتزاز للتفاعل
    HapticFeedback.mediumImpact();

    try {
      // الانتقال لشاشة اختيار طريقة الدفع
      final result = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PaymentMethodSelectionScreen(
            course: widget.course,
            userId: widget.userId,
            amount: widget.course.effectivePrice,
          ),
        ),
      );

      if (result == true) {
        // في حالة نجاح الدفع، إظهار رسالة نجاح والعودة
        await _showSuccessDialog();
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      }
    } catch (e) {
      _showErrorDialog('حدث خطأ أثناء معالجة الدفع: ${e.toString()}');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _showSuccessDialog() async {
    if (!mounted) return;

    await CustomDialog.showSuccess(
      context: context,
      title: 'تم الدفع بنجاح! 🎉',
      message: 'تم دفع رسوم الكورس بنجاح.\nسيتم تفعيل الكورس خلال 24 ساعة.',
    );
  }

  void _showErrorDialog(String errorMessage) {
    if (!mounted) return;

    CustomDialog.showError(
      context: context,
      title: 'خطأ في الدفع',
      message: errorMessage,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('دفع رسوم الكورس'),
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
                      _buildCourseCard(),
                      const SizedBox(height: 24),
                      _buildPriceSection(),
                      const SizedBox(height: 24),
                      _buildPaymentMethodInfo(),
                      const SizedBox(height: 32),
                      _buildPaymentButton(),
                      const SizedBox(height: 16),
                      _buildServiceInfo(),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildCourseCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 80,
                    height: 80,
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    child: const Icon(
                      Icons.play_circle_fill,
                      size: 40,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.course.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.course.instructorName ?? 'مدرب غير محدد',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.schedule,
                              size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.course.duration} دقيقة',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(width: 16),
                          const Icon(Icons.star, size: 16, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            widget.course.rating.toStringAsFixed(1),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
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

  Widget _buildPriceSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'تفاصيل السعر',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('سعر الكورس:',
                    style: Theme.of(context).textTheme.bodyLarge),
                Text(
                  '${widget.course.price.toStringAsFixed(0)} ريال',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            if (widget.course.hasDiscount) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('الخصم:',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.green,
                          )),
                  Text(
                    '- ${(widget.course.price - widget.course.effectivePrice).toStringAsFixed(0)} ريال',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ],
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'المجموع:',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  '${widget.course.effectivePrice.toStringAsFixed(0)} ريال',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodInfo() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.payment, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'طرق الدفع المتاحة',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'ستتم إعادة توجيهك لاختيار طريقة الدفع المناسبة لك:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            _buildFeatureItem('• بنك الكريمي (قريباً)'),
            _buildFeatureItem('• محاكاة الدفع (للاختبار)'),
            _buildFeatureItem('• أمان عالي ومعاملات مشفرة'),
            _buildFeatureItem('• تتبع حالة الدفع فورياً'),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[700],
            ),
      ),
    );
  }

  Widget _buildPaymentButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isProcessing ? null : _proceedToPaymentSelection,
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
                  const Icon(Icons.payment),
                  const SizedBox(width: 8),
                  Text(
                    'الانتقال للدفع',
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

  Widget _buildServiceInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.info_outline,
                color: AppTheme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'معلومات مهمة',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '• يمكنك اختيار طريقة الدفع المناسبة لك\n• بنك الكريمي: خدمة حقيقية (قريباً)\n• محاكاة الدفع: للاختبار والتجريب\n• سيتم تفعيل الكورس فور نجاح الدفع',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.primaryColor.withOpacity(0.8),
                ),
          ),
        ],
      ),
    );
  }
}
