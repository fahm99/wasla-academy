import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart';
import '../../models/user.dart';
import '../../themes/app_theme.dart';
import '../../widgets/custom_dialog.dart';
import '../../widgets/loading_widget.dart';
import 'verification_code_screen.dart';
import 'document_upload_screen.dart'; // سننشئ هذه الشاشة لاحقاً

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _institutionNameController = TextEditingController(); // للمؤسسات
  final _licenseNumberController = TextEditingController(); // للمؤسسات

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;

  // نوع الحساب المختار
  UserRole _selectedRole = UserRole.student;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _institutionNameController.dispose();
    _licenseNumberController.dispose();
    super.dispose();
  }

  void _register() {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreeToTerms) {
      CustomDialog.showError(
        context: context,
        title: 'خطأ',
        message: 'يجب الموافقة على الشروط والأحكام',
      );
      return;
    }

    // للحسابات التي تتطلب تحميل مستندات
    if (_selectedRole == UserRole.instructor) {
      // الانتقال إلى شاشة تحميل المستندات
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DocumentUploadScreen(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            name: _fullNameController.text.trim(),
            phone: _phoneController.text.trim(),
            role: _selectedRole,
          ),
        ),
      );
    } else {
      // التسجيل المباشر للطلاب
      context.read<AuthBloc>().add(
            AuthSignUpRequested(
              email: _emailController.text.trim(),
              password: _passwordController.text,
              name: _fullNameController.text.trim(),
              role: _selectedRole,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthFailure) {
            CustomDialog.showError(
              context: context,
              title: 'خطأ',
              message: state.message,
            );
          } else if (state is AuthVerificationCodeSent) {
            CustomDialog.showSuccess(
              context: context,
              title: 'تم الإرسال',
              message: state.message,
            );
            // الانتقال إلى شاشة إدخال رمز التحقق
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    VerificationCodeScreen(email: state.email),
              ),
            );
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
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
                          Icons.school,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'إنشاء حساب جديد',
                        style: AppTheme.headlineStyle.copyWith(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'انضم إلى منصة وصلة التعليمية',
                        style: AppTheme.bodyStyle.copyWith(
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // اختيار نوع الحساب
                  _buildAccountTypeSelector(),

                  const SizedBox(height: 24),

                  // حقل الاسم الكامل
                  TextFormField(
                    controller: _fullNameController,
                    decoration: InputDecoration(
                      labelText: _selectedRole == UserRole.instructor
                          ? 'الاسم الكامل للمدرب'
                          : 'الاسم الكامل',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'يرجى إدخال الاسم الكامل';
                      }
                      if (value.trim().length < 3) {
                        return 'يجب أن يكون الاسم 3 أحرف على الأقل';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // حقل اسم المؤسسة (للمؤسسات فقط)
                  if (_selectedRole == UserRole.instructor)
                    TextFormField(
                      controller: _institutionNameController,
                      decoration: InputDecoration(
                        labelText: 'اسم المؤسسة التعليمية',
                        prefixIcon: const Icon(Icons.business_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (value) {
                        if (_selectedRole == UserRole.instructor &&
                            (value == null || value.trim().isEmpty)) {
                          return 'يرجى إدخال اسم المؤسسة';
                        }
                        return null;
                      },
                    ),

                  const SizedBox(height: 16),

                  // حقل رقم الترخيص (للمؤسسات فقط)
                  if (_selectedRole == UserRole.instructor)
                    TextFormField(
                      controller: _licenseNumberController,
                      decoration: InputDecoration(
                        labelText: 'رقم الترخيص',
                        prefixIcon:
                            const Icon(Icons.confirmation_number_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (value) {
                        if (_selectedRole == UserRole.instructor &&
                            (value == null || value.trim().isEmpty)) {
                          return 'يرجى إدخال رقم الترخيص';
                        }
                        return null;
                      },
                    ),

                  const SizedBox(height: 16),

                  // حقل البريد الإلكتروني
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'البريد الإلكتروني',
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'يرجى إدخال البريد الإلكتروني';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(value.trim())) {
                        return 'يرجى إدخال بريد إلكتروني صحيح';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // حقل رقم الهاتف
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'رقم الهاتف (اختياري)',
                      prefixIcon: const Icon(Icons.phone_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // حقل كلمة المرور
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'كلمة المرور',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال كلمة المرور';
                      }
                      if (value.length < 6) {
                        return 'يجب أن تكون كلمة المرور 6 أحرف على الأقل';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // حقل تأكيد كلمة المرور
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    decoration: InputDecoration(
                      labelText: 'تأكيد كلمة المرور',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى تأكيد كلمة المرور';
                      }
                      if (value != _passwordController.text) {
                        return 'كلمة المرور غير متطابقة';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // الموافقة على الشروط
                  Row(
                    children: [
                      Checkbox(
                        value: _agreeToTerms,
                        onChanged: (value) {
                          setState(() {
                            _agreeToTerms = value ?? false;
                          });
                        },
                        activeColor: AppTheme.primaryColor,
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _agreeToTerms = !_agreeToTerms;
                            });
                          },
                          child: Text(
                            'أوافق على الشروط والأحكام وسياسة الخصوصية',
                            style: AppTheme.bodyStyle.copyWith(
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // زر التسجيل
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return ElevatedButton(
                        onPressed: state is AuthLoading ? null : _register,
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
                                'إنشاء الحساب',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // رابط تسجيل الدخول
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'لديك حساب بالفعل؟ ',
                        style: AppTheme.bodyStyle.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                        child: Text(
                          'تسجيل الدخول',
                          style: AppTheme.bodyStyle.copyWith(
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
      ),
    );
  }

  // مكون اختيار نوع الحساب
  Widget _buildAccountTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'نوع الحساب',
          style: AppTheme.headlineStyle.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // خيار الطالب
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedRole = UserRole.student;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _selectedRole == UserRole.student
                        ? AppTheme.primaryColor
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedRole == UserRole.student
                          ? AppTheme.primaryColor
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.school_outlined,
                        size: 32,
                        color: _selectedRole == UserRole.student
                            ? Colors.white
                            : AppTheme.primaryColor,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'طالب',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _selectedRole == UserRole.student
                              ? Colors.white
                              : AppTheme.textPrimaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // خيار المؤسسة التعليمية/المدرب المستقل
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedRole = UserRole.instructor;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _selectedRole == UserRole.instructor
                        ? AppTheme.primaryColor
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedRole == UserRole.instructor
                          ? AppTheme.primaryColor
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.business,
                        size: 32,
                        color: _selectedRole == UserRole.instructor
                            ? Colors.white
                            : AppTheme.primaryColor,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'مؤسسة/مدرب',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _selectedRole == UserRole.instructor
                              ? Colors.white
                              : AppTheme.textPrimaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
