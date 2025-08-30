import 'package:flutter/material.dart';
import '../themes/app_theme.dart';

enum DialogType {
  success,
  error,
  warning,
  info,
  confirmation,
}

class InputDialog extends StatefulWidget {
  final String title;
  final String? message;
  final String? hintText;
  final String? initialValue;
  final String? confirmText;
  final String? cancelText;
  final bool isRequired;
  final int? maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const InputDialog({
    super.key,
    required this.title,
    this.message,
    this.hintText,
    this.initialValue,
    this.confirmText,
    this.cancelText,
    this.isRequired = false,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
  });

  @override
  State<InputDialog> createState() => _InputDialogState();

  /// Static method to show InputDialog
  static Future<String?> show({
    required BuildContext context,
    required String title,
    String? message,
    String? hintText,
    String? initialValue,
    String? confirmText,
    String? cancelText,
    bool isRequired = false,
    int? maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return showDialog<String>(
      context: context,
      builder: (context) => InputDialog(
        title: title,
        message: message,
        hintText: hintText,
        initialValue: initialValue,
        confirmText: confirmText,
        cancelText: cancelText,
        isRequired: isRequired,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
      ),
    );
  }
}

class _InputDialogState extends State<InputDialog> {
  late final TextEditingController _controller;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (widget.message != null) ...[
                const SizedBox(height: 8),
                Text(
                  widget.message!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              TextFormField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: widget.hintText,
                ),
                maxLines: widget.maxLines,
                keyboardType: widget.keyboardType,
                validator: widget.validator ??
                    (widget.isRequired
                        ? (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'هذا الحقل مطلوب';
                            }
                            return null;
                          }
                        : null),
                autofocus: true,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(widget.cancelText ?? 'إلغاء'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          Navigator.of(context).pop(_controller.text);
                        }
                      },
                      child: Text(widget.confirmText ?? 'تأكيد'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Static method to show InputDialog
  static Future<String?> show({
    required BuildContext context,
    required String title,
    String? message,
    String? hintText,
    String? initialValue,
    String? confirmText,
    String? cancelText,
    bool isRequired = false,
    int? maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return showDialog<String>(
      context: context,
      builder: (context) => InputDialog(
        title: title,
        message: message,
        hintText: hintText,
        initialValue: initialValue,
        confirmText: confirmText,
        cancelText: cancelText,
        isRequired: isRequired,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
      ),
    );
  }
}

class CustomDialog extends StatelessWidget {
  final DialogType type;
  final String title;
  final String message;
  final String? primaryButtonText;
  final String? secondaryButtonText;
  final VoidCallback? onPrimaryPressed;
  final VoidCallback? onSecondaryPressed;
  final Widget? customContent;
  final bool barrierDismissible;

  const CustomDialog({
    super.key,
    required this.type,
    required this.title,
    required this.message,
    this.primaryButtonText,
    this.secondaryButtonText,
    this.onPrimaryPressed,
    this.onSecondaryPressed,
    this.customContent,
    this.barrierDismissible = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dialogConfig = _getDialogConfig();

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: dialogConfig.color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                dialogConfig.icon,
                color: dialogConfig.color,
                size: 32,
              ),
            ),

            const SizedBox(height: 16),

            // Title
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            // Message
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),

            // Custom Content
            if (customContent != null) ...[
              const SizedBox(height: 16),
              customContent!,
            ],

            const SizedBox(height: 24),

            // Buttons
            Row(
              children: [
                if (secondaryButtonText != null) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onSecondaryPressed ??
                          () => Navigator.of(context).pop(false),
                      child: Text(secondaryButtonText!),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: ElevatedButton(
                    onPressed: onPrimaryPressed ??
                        () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: dialogConfig.color,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(primaryButtonText ?? 'موافق'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _DialogConfig _getDialogConfig() {
    switch (type) {
      case DialogType.success:
        return const _DialogConfig(
          icon: Icons.check_circle,
          color: AppTheme.successColor,
        );
      case DialogType.error:
        return const _DialogConfig(
          icon: Icons.error,
          color: AppTheme.errorColor,
        );
      case DialogType.warning:
        return const _DialogConfig(
          icon: Icons.warning,
          color: AppTheme.warningColor,
        );
      case DialogType.info:
        return const _DialogConfig(
          icon: Icons.info,
          color: AppTheme.primaryColor,
        );
      case DialogType.confirmation:
        return const _DialogConfig(
          icon: Icons.help,
          color: AppTheme.primaryColor,
        );
    }
  }

  static Future<bool?> show({
    required BuildContext context,
    required DialogType type,
    required String title,
    required String message,
    String? primaryButtonText,
    String? secondaryButtonText,
    VoidCallback? onPrimaryPressed,
    VoidCallback? onSecondaryPressed,
    Widget? customContent,
    bool barrierDismissible = true,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => CustomDialog(
        type: type,
        title: title,
        message: message,
        primaryButtonText: primaryButtonText,
        secondaryButtonText: secondaryButtonText,
        onPrimaryPressed: onPrimaryPressed,
        onSecondaryPressed: onSecondaryPressed,
        customContent: customContent,
        barrierDismissible: barrierDismissible,
      ),
    );
  }

  // Convenience methods
  static Future<bool?> showSuccess({
    required BuildContext context,
    required String title,
    required String message,
    String? buttonText,
    VoidCallback? onPressed,
  }) {
    return show(
      context: context,
      type: DialogType.success,
      title: title,
      message: message,
      primaryButtonText: buttonText ?? 'تم',
      onPrimaryPressed: onPressed,
    );
  }

  static Future<bool?> showError({
    required BuildContext context,
    required String title,
    required String message,
    String? buttonText,
    VoidCallback? onPressed,
  }) {
    return show(
      context: context,
      type: DialogType.error,
      title: title,
      message: message,
      primaryButtonText: buttonText ?? 'حسناً',
      onPrimaryPressed: onPressed,
    );
  }

  static Future<bool?> showConfirmation({
    required BuildContext context,
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    return show(
      context: context,
      type: DialogType.confirmation,
      title: title,
      message: message,
      primaryButtonText: confirmText ?? 'تأكيد',
      secondaryButtonText: cancelText ?? 'إلغاء',
      onPrimaryPressed: onConfirm,
      onSecondaryPressed: onCancel,
    );
  }

  static Future<String?> showInput({
    required BuildContext context,
    required String title,
    String? message,
    String? hintText,
    String? initialValue,
    String? confirmText,
    String? cancelText,
    bool isRequired = false,
    int? maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return InputDialog.show(
      context: context,
      title: title,
      message: message,
      hintText: hintText,
      initialValue: initialValue,
      confirmText: confirmText,
      cancelText: cancelText,
      isRequired: isRequired,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
    );
  }
}

class _DialogConfig {
  final IconData icon;
  final Color color;

  const _DialogConfig({
    required this.icon,
    required this.color,
  });
}

class LoadingDialog extends StatelessWidget {
  final String? message;

  const LoadingDialog({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              color: AppTheme.primaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              message ?? 'جاري التحميل...',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  static void show({
    required BuildContext context,
    String? message,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => LoadingDialog(message: message),
    );
  }

  static void hide(BuildContext context) {
    Navigator.of(context).pop();
  }
}
