# خطوط Cairo العربية

## الملفات المطلوبة

يجب إضافة الملفات التالية في هذا المجلد:

1. `Cairo-Regular.ttf` - الخط العادي
2. `Cairo-Bold.ttf` - الخط العريض
3. `Cairo-Light.ttf` - الخط الرفيع
4. `Cairo-Medium.ttf` - الخط المتوسط

## كيفية الحصول على الخطوط

### الطريقة الأولى: من Google Fonts
1. اذهب إلى [Google Fonts - Cairo](https://fonts.google.com/specimen/Cairo)
2. انقر على "Download family"
3. استخرج الملفات وضعها في هذا المجلد

### الطريقة الثانية: من GitHub
```bash
# تحميل من مستودع Cairo Fonts
git clone https://github.com/google/fonts.git
cp fonts/ofl/cairo/Cairo-*.ttf assets/fonts/
```

### الطريقة الثالثة: تحميل مباشر
```bash
# تحميل الخطوط مباشرة
wget https://github.com/google/fonts/raw/main/ofl/cairo/Cairo-Regular.ttf -O assets/fonts/Cairo-Regular.ttf
wget https://github.com/google/fonts/raw/main/ofl/cairo/Cairo-Bold.ttf -O assets/fonts/Cairo-Bold.ttf
wget https://github.com/google/fonts/raw/main/ofl/cairo/Cairo-Light.ttf -O assets/fonts/Cairo-Light.ttf
wget https://github.com/google/fonts/raw/main/ofl/cairo/Cairo-Medium.ttf -O assets/fonts/Cairo-Medium.ttf
```

## ملاحظات مهمة
- تأكد من أن أسماء الملفات مطابقة تماماً لما هو مذكور أعلاه
- الخطوط مطلوبة لعرض النصوص العربية بشكل صحيح
- بدون هذه الخطوط ستعرض النصوص العربية بخط افتراضي قد لا يكون مناسباً
