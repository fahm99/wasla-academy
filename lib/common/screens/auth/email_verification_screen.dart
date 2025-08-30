import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart';
import '../../themes/app_theme.dart';
import '../../widgets/custom_dialog.dart';
import '../../widgets/loading_widget.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String email;

  const EmailVerificationScreen({
    super.key,
    required this.email,
  });

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool _isResending = false;

  void _resendEmail() {
    setState(() {
      _isResending = true;
    });

    context.read<AuthBloc>().add(
          const AuthResendEmailConfirmationRequested(),
        );

    // إعادة تعيين الحالة بعد ثانيتين
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    });
  }

  void _checkEmailConfirmation() {
    context.read<AuthBloc>().add(
          const AuthCheckEmailConfirmationRequested(),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthFailure) {
            CustomDialog.showError(
              context: context,
              title: 'خطأ',
              message: state.message,
            );
          } else if (state is AuthEmailConfirmed) {
            CustomDialog.showSuccess(
              context: context,
              title: 'نجح',
              message: 'تم تأكيد بريدك الإلكتروني بنجاح!',
            );
            Navigator.pushReplacementNamed(context, '/login');
          } else if (state is AuthResendEmailSuccess) {
            CustomDialog.showSuccess(
              context: context,
              title: 'تم الإرسال',
              message: 'تم إرسال رابط التأكيد مرة أخرى إلى بريدك الإلكتروني',
            );
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),

                // الشعار والعنوان
                Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.mark_email_unread_outlined,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'تأكيد البريد الإلكتروني',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'تم إرسال رابط التأكيد إلى',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.email,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // التعليمات
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue[600],
                        size: 32,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'خطوات التأكيد',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildInstructionStep(
                        '1',
                        'افتح بريدك الإلكتروني',
                        Icons.email_outlined,
                      ),
                      _buildInstructionStep(
                        '2',
                        'ابحث عن رسالة من وصلة',
                        Icons.search_outlined,
                      ),
                      _buildInstructionStep(
                        '3',
                        'انقر على رابط التأكيد',
                        Icons.link_outlined,
                      ),
                      _buildInstructionStep(
                        '4',
                        'عد إلى التطبيق',
                        Icons.arrow_back_outlined,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // زر التحقق من التأكيد
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    return ElevatedButton(
                      onPressed:
                          state is AuthLoading ? null : _checkEmailConfirmation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: state is AuthLoading
                          ? const LoadingWidget(
                              color: Colors.white,
                              size: 20,
                            )
                          : const Text(
                              'تحقق من التأكيد',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    );
                  },
                ),

                const SizedBox(height: 16),

                // زر إعادة إرسال البريد
                OutlinedButton(
                  onPressed: _isResending ? null : _resendEmail,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                    side: const BorderSide(color: AppTheme.primaryColor),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isResending
                      ? const LoadingWidget(
                          color: Colors.blue,
                          size: 20,
                        )
                      : const Text(
                          'إعادة إرسال رابط التأكيد',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),

                const SizedBox(height: 24),

                // معلومات إضافية
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange[200]!),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.warning_amber_outlined,
                        color: Colors.orange[600],
                        size: 24,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'ملاحظة مهمة',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[800],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'إذا لم تجد رسالة التأكيد، تحقق من مجلد الرسائل غير المرغوب فيها (Spam).',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.orange[700],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // رابط العودة لتسجيل الدخول
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'تم التأكيد؟ ',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      child: const Text(
                        'تسجيل الدخول',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionStep(String number, String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Icon(
            icon,
            color: Colors.blue[600],
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.blue[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
