import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart';
import '../../themes/app_theme.dart';
import '../../widgets/custom_dialog.dart';
import '../../widgets/loading_widget.dart';

class VerificationCodeScreen extends StatefulWidget {
  final String email;

  const VerificationCodeScreen({
    super.key,
    required this.email,
  });

  @override
  State<VerificationCodeScreen> createState() => _VerificationCodeScreenState();
}

class _VerificationCodeScreenState extends State<VerificationCodeScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  bool _isResending = false;
  int _resendCountdown = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startResendCountdown();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  void _startResendCountdown() {
    setState(() {
      _resendCountdown = 60; // 60 seconds countdown
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        setState(() {
          _resendCountdown--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _resendCode() {
    if (_resendCountdown > 0) return;

    setState(() {
      _isResending = true;
    });

    context.read<AuthBloc>().add(
          AuthSendVerificationCodeRequested(email: widget.email),
        );

    _startResendCountdown();

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    });
  }

  void _verifyCode() {
    final code = _controllers.map((controller) => controller.text).join();

    if (code.length != 6) {
      CustomDialog.showError(
        context: context,
        title: 'خطأ',
        message: 'يرجى إدخال رمز التحقق كاملاً (6 أرقام)',
      );
      return;
    }

    context.read<AuthBloc>().add(
          AuthVerifyCodeRequested(
            email: widget.email,
            code: code,
          ),
        );
  }

  void _onCodeChanged(String value, int index) {
    if (value.isNotEmpty) {
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
        // Auto verify when all 6 digits are entered
        _verifyCode();
      }
    }
  }

  void _onBackspace(int index) {
    if (_controllers[index].text.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  void _clearAllCodes() {
    for (var controller in _controllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _clearAllCodes,
            child: const Text(
              'مسح',
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthFailure) {
            CustomDialog.showError(
              context: context,
              title: 'خطأ',
              message: state.message,
            );
          } else if (state is AuthCodeVerified) {
            CustomDialog.showSuccess(
              context: context,
              title: 'تم التحقق بنجاح',
              message: state.message,
            );
            // Navigate to main screen based on user role
            // سيتم تحديث هذا الجزء لاحقاً لإدارة الجلسات
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/student/home', // سيتم تحديث هذا لاحقاً
                  (route) => false,
                );
              }
            });
          } else if (state is AuthVerificationCodeSent) {
            CustomDialog.showSuccess(
              context: context,
              title: 'تم الإرسال',
              message: state.message,
            );
          } else if (state is AuthSuccess) {
            // للحسابات التي لا تحتاج رمز تحقق (المؤسسات والمدربون)
            CustomDialog.showSuccess(
              context: context,
              title: 'تم التسجيل',
              message: state.message,
            );
            // إعادة التوجيه التلقائي للشاشة الرئيسية
            Future.delayed(const Duration(seconds: 3), () {
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login', // سيتم إعادة التوجيه لشاشة الانتظار لاحقاً
                  (route) => false,
                );
              }
            });
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),

                // Header
                _buildHeader(theme),

                const SizedBox(height: 40),

                // Code Input Fields
                _buildCodeInputFields(theme),

                const SizedBox(height: 30),

                // Verify Button
                _buildVerifyButton(theme),

                const SizedBox(height: 20),

                // Resend Code Section
                _buildResendSection(theme),

                const SizedBox(height: 30),

                // Instructions
                _buildInstructions(theme),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.verified_user,
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
          'أدخل رمز التحقق المرسل إلى',
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
    );
  }

  Widget _buildCodeInputFields(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(6, (index) {
        return Container(
          width: 45,
          height: 55,
          decoration: BoxDecoration(
            border: Border.all(
              color: _controllers[index].text.isNotEmpty
                  ? AppTheme.primaryColor
                  : Colors.grey.shade300,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          child: TextFormField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            inputFormatters: [
              LengthLimitingTextInputFormatter(1),
              FilteringTextInputFormatter.digitsOnly,
            ],
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryColor,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              counterText: '',
            ),
            onChanged: (value) => _onCodeChanged(value, index),
            onTap: () {
              _controllers[index].selection = TextSelection.fromPosition(
                TextPosition(offset: _controllers[index].text.length),
              );
            },
            onEditingComplete: () {
              if (index < 5 && _controllers[index].text.isNotEmpty) {
                _focusNodes[index + 1].requestFocus();
              }
            },
            onFieldSubmitted: (value) {
              if (index == 5) {
                _verifyCode();
              }
            },
          ),
        );
      }),
    );
  }

  Widget _buildVerifyButton(ThemeData theme) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: isLoading ? null : _verifyCode,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: isLoading
                ? const LoadingWidget(
                    color: Colors.white,
                    size: 20,
                  )
                : const Text(
                    'تأكيد الرمز',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildResendSection(ThemeData theme) {
    return Column(
      children: [
        Text(
          'لم تستلم الرمز؟',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        if (_resendCountdown > 0)
          Text(
            'يمكنك إعادة الإرسال خلال $_resendCountdown ثانية',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          )
        else
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              return TextButton(
                onPressed:
                    (_isResending || state is AuthLoading) ? null : _resendCode,
                child: _isResending
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppTheme.primaryColor,
                        ),
                      )
                    : const Text(
                        'إعادة إرسال الرمز',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildInstructions(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.blue[600],
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            'نصائح مهمة',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '• تأكد من فحص مجلد البريد العشوائي (Spam)\n'
            '• الرمز صالح لمدة 10 دقائق فقط\n'
            '• تأكد من اتصالك بالإنترنت',
            style: TextStyle(
              fontSize: 13,
              color: Colors.blue[700],
              height: 1.4,
            ),
            textAlign: TextAlign.start,
          ),
        ],
      ),
    );
  }
}
