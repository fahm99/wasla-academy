/// خدمة التحقق من صحة البيانات
class ValidationService {
  /// التحقق من صحة البريد الإلكتروني
  static String? validateEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      return 'يرجى إدخال البريد الإلكتروني';
    }

    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

    if (!emailRegex.hasMatch(email.trim())) {
      return 'يرجى إدخال بريد إلكتروني صحيح';
    }

    return null;
  }

  /// التحقق من صحة كلمة المرور
  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'يرجى إدخال كلمة المرور';
    }

    if (password.length < 8) {
      return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
    }

    // التحقق من وجود حرف كبير
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'كلمة المرور يجب أن تحتوي على حرف كبير واحد على الأقل';
    }

    // التحقق من وجود حرف صغير
    if (!password.contains(RegExp(r'[a-z]'))) {
      return 'كلمة المرور يجب أن تحتوي على حرف صغير واحد على الأقل';
    }

    // التحقق من وجود رقم
    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'كلمة المرور يجب أن تحتوي على رقم واحد على الأقل';
    }

    // التحقق من وجود رمز خاص
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'كلمة المرور يجب أن تحتوي على رمز خاص واحد على الأقل';
    }

    return null;
  }

  /// التحقق من تطابق كلمات المرور
  static String? validatePasswordConfirmation(
      String? password, String? confirmPassword) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'يرجى تأكيد كلمة المرور';
    }

    if (password != confirmPassword) {
      return 'كلمات المرور غير متطابقة';
    }

    return null;
  }

  /// التحقق من صحة الاسم
  static String? validateName(String? name) {
    if (name == null || name.trim().isEmpty) {
      return 'يرجى إدخال الاسم';
    }

    if (name.trim().length < 2) {
      return 'الاسم يجب أن يكون حرفين على الأقل';
    }

    if (name.trim().length > 50) {
      return 'الاسم يجب أن يكون أقل من 50 حرف';
    }

    // التحقق من أن الاسم يحتوي على حروف فقط (مع السماح بالمسافات)
    final nameRegex = RegExp(r'^[a-zA-Zأ-ي\s]+$');
    if (!nameRegex.hasMatch(name.trim())) {
      return 'الاسم يجب أن يحتوي على حروف فقط';
    }

    return null;
  }

  /// التحقق من صحة رقم الهاتف
  static String? validatePhoneNumber(String? phone) {
    if (phone == null || phone.trim().isEmpty) {
      return null; // اختياري
    }

    // إزالة المسافات والرموز
    final cleanPhone = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    // التحقق من الصيغة (رقم سعودي)
    final phoneRegex = RegExp(r'^(\+966|966|0)?5[0-9]{8}$');
    if (!phoneRegex.hasMatch(cleanPhone)) {
      return 'يرجى إدخال رقم هاتف صحيح (مثال: 0501234567)';
    }

    return null;
  }

  /// التحقق من صحة عنوان الكورس
  static String? validateCourseTitle(String? title) {
    if (title == null || title.trim().isEmpty) {
      return 'يرجى إدخال عنوان الكورس';
    }

    if (title.trim().length < 5) {
      return 'عنوان الكورس يجب أن يكون 5 أحرف على الأقل';
    }

    if (title.trim().length > 100) {
      return 'عنوان الكورس يجب أن يكون أقل من 100 حرف';
    }

    return null;
  }

  /// التحقق من صحة وصف الكورس
  static String? validateCourseDescription(String? description) {
    if (description == null || description.trim().isEmpty) {
      return 'يرجى إدخال وصف الكورس';
    }

    if (description.trim().length < 20) {
      return 'وصف الكورس يجب أن يكون 20 حرف على الأقل';
    }

    if (description.trim().length > 1000) {
      return 'وصف الكورس يجب أن يكون أقل من 1000 حرف';
    }

    return null;
  }

  /// التحقق من صحة سعر الكورس
  static String? validateCoursePrice(String? price) {
    if (price == null || price.trim().isEmpty) {
      return 'يرجى إدخال سعر الكورس';
    }

    final priceValue = double.tryParse(price);
    if (priceValue == null) {
      return 'يرجى إدخال سعر صحيح';
    }

    if (priceValue < 0) {
      return 'السعر لا يمكن أن يكون سالب';
    }

    if (priceValue > 10000) {
      return 'السعر لا يمكن أن يتجاوز 10,000 ريال';
    }

    return null;
  }

  /// التحقق من صحة رمز التحقق
  static String? validateVerificationCode(String? code) {
    if (code == null || code.trim().isEmpty) {
      return 'يرجى إدخال رمز التحقق';
    }

    if (code.trim().length != 6) {
      return 'رمز التحقق يجب أن يكون 6 أرقام';
    }

    final codeRegex = RegExp(r'^[0-9]{6}$');
    if (!codeRegex.hasMatch(code.trim())) {
      return 'رمز التحقق يجب أن يحتوي على أرقام فقط';
    }

    return null;
  }

  /// التحقق من صحة رقم البطاقة الائتمانية
  static String? validateCreditCardNumber(String? cardNumber) {
    if (cardNumber == null || cardNumber.trim().isEmpty) {
      return 'يرجى إدخال رقم البطاقة';
    }

    // إزالة المسافات والشرطات
    final cleanNumber = cardNumber.replaceAll(RegExp(r'[\s\-]'), '');

    if (cleanNumber.length < 13 || cleanNumber.length > 19) {
      return 'رقم البطاقة غير صحيح';
    }

    // خوارزمية Luhn للتحقق من صحة رقم البطاقة
    if (!_isValidLuhn(cleanNumber)) {
      return 'رقم البطاقة غير صحيح';
    }

    return null;
  }

  /// التحقق من صحة تاريخ انتهاء البطاقة
  static String? validateCardExpiryDate(String? expiryDate) {
    if (expiryDate == null || expiryDate.trim().isEmpty) {
      return 'يرجى إدخال تاريخ انتهاء البطاقة';
    }

    final dateRegex = RegExp(r'^(0[1-9]|1[0-2])\/([0-9]{2})$');
    if (!dateRegex.hasMatch(expiryDate.trim())) {
      return 'تاريخ انتهاء البطاقة يجب أن يكون بصيغة MM/YY';
    }

    final parts = expiryDate.trim().split('/');
    final month = int.parse(parts[0]);
    final year = int.parse('20${parts[1]}');

    final now = DateTime.now();
    final expiry = DateTime(year, month + 1, 0); // آخر يوم في الشهر

    if (expiry.isBefore(now)) {
      return 'البطاقة منتهية الصلاحية';
    }

    return null;
  }

  /// التحقق من صحة CVV
  static String? validateCVV(String? cvv) {
    if (cvv == null || cvv.trim().isEmpty) {
      return 'يرجى إدخال رمز CVV';
    }

    final cvvRegex = RegExp(r'^[0-9]{3,4}$');
    if (!cvvRegex.hasMatch(cvv.trim())) {
      return 'رمز CVV يجب أن يكون 3 أو 4 أرقام';
    }

    return null;
  }

  /// التحقق من صحة IBAN
  static String? validateIBAN(String? iban) {
    if (iban == null || iban.trim().isEmpty) {
      return 'يرجى إدخال رقم IBAN';
    }

    // إزالة المسافات
    final cleanIBAN = iban.replaceAll(' ', '').toUpperCase();

    // التحقق من طول IBAN السعودي
    if (!cleanIBAN.startsWith('SA') || cleanIBAN.length != 24) {
      return 'رقم IBAN السعودي يجب أن يبدأ بـ SA ويكون 24 رقم';
    }

    // التحقق من أن باقي الأرقام صحيحة
    final ibanRegex = RegExp(r'^SA[0-9]{22}$');
    if (!ibanRegex.hasMatch(cleanIBAN)) {
      return 'رقم IBAN غير صحيح';
    }

    return null;
  }

  /// خوارزمية Luhn للتحقق من صحة رقم البطاقة الائتمانية
  static bool _isValidLuhn(String cardNumber) {
    int sum = 0;
    bool alternate = false;

    for (int i = cardNumber.length - 1; i >= 0; i--) {
      int digit = int.parse(cardNumber[i]);

      if (alternate) {
        digit *= 2;
        if (digit > 9) {
          digit = (digit % 10) + 1;
        }
      }

      sum += digit;
      alternate = !alternate;
    }

    return sum % 10 == 0;
  }

  /// التحقق من صحة URL
  static String? validateURL(String? url) {
    if (url == null || url.trim().isEmpty) {
      return null; // اختياري
    }

    final urlRegex = RegExp(
        r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$');

    if (!urlRegex.hasMatch(url.trim())) {
      return 'يرجى إدخال رابط صحيح';
    }

    return null;
  }

  /// التحقق من قوة كلمة المرور (من 0 إلى 5)
  static int getPasswordStrength(String password) {
    int strength = 0;

    if (password.length >= 8) strength++;
    if (password.contains(RegExp(r'[a-z]'))) strength++;
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;

    return strength;
  }

  /// وصف قوة كلمة المرور
  static String getPasswordStrengthText(int strength) {
    switch (strength) {
      case 0:
      case 1:
        return 'ضعيفة جداً';
      case 2:
        return 'ضعيفة';
      case 3:
        return 'متوسطة';
      case 4:
        return 'قوية';
      case 5:
        return 'قوية جداً';
      default:
        return 'غير محدد';
    }
  }
}
