import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart';
import '../../models/user.dart';
import '../../themes/app_theme.dart';
import '../../widgets/custom_dialog.dart';
import '../../widgets/loading_widget.dart';
import 'verification_code_screen.dart';

class DocumentUploadScreen extends StatefulWidget {
  final String email;
  final String password;
  final String name;
  final String phone;
  final UserRole role;

  const DocumentUploadScreen({
    super.key,
    required this.email,
    required this.password,
    required this.name,
    required this.phone,
    required this.role,
  });

  @override
  State<DocumentUploadScreen> createState() => _DocumentUploadScreenState();
}

class _DocumentUploadScreenState extends State<DocumentUploadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _institutionNameController = TextEditingController();
  final _licenseNumberController = TextEditingController();
  final _specializationController = TextEditingController();
  final _experienceController = TextEditingController();

  File? _licenseDocument;
  File? _certificationDocument;
  File? _idDocument;

  bool _isLoading = false;

  @override
  void dispose() {
    _institutionNameController.dispose();
    _licenseNumberController.dispose();
    _specializationController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  Future<void> _pickDocument(String documentType) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
      );

      if (pickedFile != null) {
        setState(() {
          switch (documentType) {
            case 'license':
              _licenseDocument = File(pickedFile.path);
              break;
            case 'certification':
              _certificationDocument = File(pickedFile.path);
              break;
            case 'id':
              _idDocument = File(pickedFile.path);
              break;
          }
        });
      }
    } catch (e) {
      CustomDialog.showError(
        context: context,
        title: 'خطأ',
        message: 'فشل في اختيار الملف: ${e.toString()}',
      );
    }
  }

  void _submitDocuments() async {
    if (!_formKey.currentState!.validate()) return;

    // التحقق من تحميل المستندات المطلوبة
    if (_licenseDocument == null) {
      CustomDialog.showError(
        context: context,
        title: 'خطأ',
        message: 'يرجى تحميل وثيقة الترخيص',
      );
      return;
    }

    if (_certificationDocument == null) {
      CustomDialog.showError(
        context: context,
        title: 'خطأ',
        message: 'يرجى تحميل شهادة المؤهل',
      );
      return;
    }

    if (_idDocument == null) {
      CustomDialog.showError(
        context: context,
        title: 'خطأ',
        message: 'يرجى تحميل صورة الهوية',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // هنا سنقوم بإرسال البيانات والمستندات إلى الخادم
    // في الوقت الحالي، سنرسل فقط البيانات الأساسية للتسجيل
    context.read<AuthBloc>().add(
          AuthSignUpRequested(
            email: widget.email,
            password: widget.password,
            name: widget.name,
            role: widget.role,
          ),
        );
    
    // Check if the widget is still mounted before navigating
    if (!mounted) return;
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
            setState(() {
              _isLoading = false;
            });
            CustomDialog.showError(
              context: context,
              title: 'خطأ',
              message: state.message,
            );
          } else if (state is AuthVerificationCodeSent) {
            setState(() {
              _isLoading = false;
            });
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
                  const SizedBox(height: 20),

                  // العنوان
                  Text(
                    'رفع المستندات المطلوبة',
                    style: AppTheme.headlineStyle.copyWith(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'يرجى رفع المستندات التالية للمراجعة',
                    style: AppTheme.bodyStyle.copyWith(
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 40),

                  // حقل اسم المؤسسة
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
                      if (value == null || value.trim().isEmpty) {
                        return 'يرجى إدخال اسم المؤسسة';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // حقل رقم الترخيص
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
                      if (value == null || value.trim().isEmpty) {
                        return 'يرجى إدخال رقم الترخيص';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // حقل التخصص
                  TextFormField(
                    controller: _specializationController,
                    decoration: InputDecoration(
                      labelText: 'التخصص',
                      prefixIcon: const Icon(Icons.school_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'يرجى إدخال التخصص';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // حقل سنوات الخبرة
                  TextFormField(
                    controller: _experienceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'سنوات الخبرة',
                      prefixIcon: const Icon(Icons.work_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'يرجى إدخال سنوات الخبرة';
                      }
                      if (int.tryParse(value) == null) {
                        return 'يرجى إدخال رقم صحيح';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 30),

                  // قسم رفع المستندات
                  _buildDocumentUploadSection(),

                  const SizedBox(height: 30),

                  // زر الإرسال
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submitDocuments,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: _isLoading
                        ? const LoadingWidget(
                            color: Colors.white,
                            size: 20,
                          )
                        : const Text(
                            'إرسال للمراجعة',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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

  Widget _buildDocumentUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'المستندات المطلوبة',
          style: AppTheme.headlineStyle.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        // وثيقة الترخيص
        _buildDocumentItem(
          title: 'وثيقة الترخيص',
          subtitle: 'شهادة تسجيل المؤسسة أو الترخيص المهني',
          documentFile: _licenseDocument,
          documentType: 'license',
        ),

        const SizedBox(height: 16),

        // شهادة المؤهل
        _buildDocumentItem(
          title: 'شهادة المؤهل',
          subtitle: 'شهادة البكالوريوس أو الماجستير في التخصص',
          documentFile: _certificationDocument,
          documentType: 'certification',
        ),

        const SizedBox(height: 16),

        // صورة الهوية
        _buildDocumentItem(
          title: 'صورة الهوية',
          subtitle: 'صورة الهوية الشخصية للمدرب',
          documentFile: _idDocument,
          documentType: 'id',
        ),
      ],
    );
  }

  Widget _buildDocumentItem({
    required String title,
    required String subtitle,
    required File? documentFile,
    required String documentType,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: documentFile != null
                        ? Colors.green.shade50
                        : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: documentFile != null
                          ? Colors.green
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        documentFile != null
                            ? Icons.check_circle_outline
                            : Icons.upload_file_outlined,
                        size: 20,
                        color: documentFile != null
                            ? Colors.green
                            : Colors.grey.shade600,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          documentFile != null ? 'تم رفع الملف' : 'اختر ملف',
                          style: TextStyle(
                            fontSize: 14,
                            color: documentFile != null
                                ? Colors.green
                                : Colors.grey.shade600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => _pickDocument(documentType),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: const Text('رفع'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
