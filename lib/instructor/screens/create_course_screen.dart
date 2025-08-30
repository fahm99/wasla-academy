import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../common/widgets/custom_app_bar.dart';
import '../../common/widgets/loading_widget.dart';
import '../../common/widgets/custom_dialog.dart';
import '../../common/themes/app_theme.dart';
import '../../common/models/course.dart';

class CreateCourseScreen extends StatefulWidget {
  final Course? course; // For editing existing course

  const CreateCourseScreen({
    super.key,
    this.course,
  });

  @override
  State<CreateCourseScreen> createState() => _CreateCourseScreenState();
}

class _CreateCourseScreenState extends State<CreateCourseScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final bool _isLoading = false;
  bool _isSaving = false;

  // Basic Info Controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _shortDescController = TextEditingController();
  final _priceController = TextEditingController();
  final _discountPriceController = TextEditingController();

  // Course Settings
  String _selectedCategory = '';
  CourseLevel _selectedLevel = CourseLevel.beginner;
  String _selectedLanguage = 'العربية';
  List<String> _tags = [];
  String _thumbnailUrl = '';
  String _previewVideoUrl = '';

  // Course Content
  List<Map<String, dynamic>> _sections = [];

  // Pricing & Settings
  bool _isFree = false;
  bool _hasDiscount = false;
  bool _isPublished = false;
  bool _allowComments = true;
  bool _allowDownloads = false;
  bool _hasCertificate = true;

  // Categories and Languages
  final List<String> _categories = [
    'البرمجة',
    'التصميم',
    'التسويق',
    'الأعمال',
    'اللغات',
    'الصحة',
    'الطبخ',
    'الرياضة',
    'الموسيقى',
    'التصوير',
  ];

  final List<String> _languages = [
    'العربية',
    'الإنجليزية',
    'الفرنسية',
    'الألمانية',
    'الإسبانية',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initializeData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _shortDescController.dispose();
    _priceController.dispose();
    _discountPriceController.dispose();
    super.dispose();
  }

  void _initializeData() {
    if (widget.course != null) {
      // Edit mode - populate fields
      final course = widget.course!;
      _titleController.text = course.title;
      _descriptionController.text = course.description;
      _priceController.text = course.price.toString();
      _discountPriceController.text = course.discountPrice?.toString() ?? '';
      _selectedCategory = course.category;
      _selectedLevel = course.level;
      _tags = List.from(course.tags);
      _thumbnailUrl = course.thumbnail ?? '';
      _hasDiscount = course.discountPrice != null;
      _isFree = course.price == 0;
    } else {
      // Create mode - add default section
      _sections = [
        {
          'title': 'مقدمة الكورس',
          'lessons': <Map<String, dynamic>>[],
          'isExpanded': true,
        }
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.course != null;

    return Scaffold(
      appBar: CustomAppBar(
        title: isEditing ? 'تعديل الكورس' : 'إنشاء كورس جديد',
        actions: [
          if (isEditing)
            PopupMenuButton<String>(
              onSelected: _handleMenuAction,
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'preview',
                  child: Row(
                    children: [
                      Icon(Icons.preview),
                      SizedBox(width: 8),
                      Text('معاينة'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'duplicate',
                  child: Row(
                    children: [
                      Icon(Icons.copy),
                      SizedBox(width: 8),
                      Text('نسخ الكورس'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('حذف الكورس', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'المعلومات الأساسية'),
            Tab(text: 'المحتوى'),
            Tab(text: 'التسعير'),
            Tab(text: 'الإعدادات'),
          ],
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.6),
          indicatorColor: AppTheme.primaryColor,
          isScrollable: true,
        ),
      ),
      body: _isLoading
          ? const LoadingWidget(message: 'جاري تحميل بيانات الكورس...')
          : Form(
              key: _formKey,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildBasicInfoTab(theme),
                  _buildContentTab(theme),
                  _buildPricingTab(theme),
                  _buildSettingsTab(theme),
                ],
              ),
            ),
      bottomNavigationBar: _buildBottomBar(theme),
    );
  }

  Widget _buildBasicInfoTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Course Title
          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'عنوان الكورس *',
              hintText: 'مثال: تعلم Flutter من الصفر',
              prefixIcon: Icon(Icons.title),
            ),
            maxLength: 100,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'يرجى إدخال عنوان الكورس';
              }
              if (value.length < 10) {
                return 'يجب أن يكون العنوان 10 أحرف على الأقل';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Short Description
          TextFormField(
            controller: _shortDescController,
            decoration: const InputDecoration(
              labelText: 'وصف مختصر *',
              hintText: 'وصف قصير يظهر في بطاقة الكورس',
              prefixIcon: Icon(Icons.short_text),
            ),
            maxLength: 200,
            maxLines: 2,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'يرجى إدخال وصف مختصر';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Full Description
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'الوصف الكامل *',
              hintText: 'وصف تفصيلي عن محتوى الكورس وما سيتعلمه الطالب',
              prefixIcon: Icon(Icons.description),
              alignLabelWithHint: true,
            ),
            maxLines: 6,
            maxLength: 2000,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'يرجى إدخال وصف الكورس';
              }
              if (value.length < 50) {
                return 'يجب أن يكون الوصف 50 حرف على الأقل';
              }
              return null;
            },
          ),

          const SizedBox(height: 24),

          // Category Selection
          Text(
            'التصنيف *',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedCategory.isEmpty ? null : _selectedCategory,
            decoration: const InputDecoration(
              hintText: 'اختر تصنيف الكورس',
              prefixIcon: Icon(Icons.category),
            ),
            items: _categories.map((category) {
              return DropdownMenuItem(
                value: category,
                child: Text(category),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedCategory = value ?? '';
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'يرجى اختيار تصنيف الكورس';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Level Selection
          Text(
            'مستوى الكورس *',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: CourseLevel.values.map((level) {
              return Expanded(
                child: RadioListTile<CourseLevel>(
                  title: Text(_getLevelText(level)),
                  value: level,
                  groupValue: _selectedLevel,
                  onChanged: (value) {
                    setState(() {
                      _selectedLevel = value!;
                    });
                  },
                  contentPadding: EdgeInsets.zero,
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // Language Selection
          DropdownButtonFormField<String>(
            value: _selectedLanguage,
            decoration: const InputDecoration(
              labelText: 'لغة الكورس',
              prefixIcon: Icon(Icons.language),
            ),
            items: _languages.map((language) {
              return DropdownMenuItem(
                value: language,
                child: Text(language),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedLanguage = value ?? 'العربية';
              });
            },
          ),

          const SizedBox(height: 24),

          // Tags
          Text(
            'الكلمات المفتاحية',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          _buildTagsSection(theme),

          const SizedBox(height: 24),

          // Thumbnail
          _buildThumbnailSection(theme),

          const SizedBox(height: 24),

          // Preview Video
          _buildPreviewVideoSection(theme),
        ],
      ),
    );
  }

  Widget _buildContentTab(ThemeData theme) {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.appBarTheme.backgroundColor,
            border: Border(
              bottom: BorderSide(
                color: theme.colorScheme.outline.withOpacity(0.3),
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'محتوى الكورس',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: _addSection,
                icon: const Icon(Icons.add),
                label: const Text('إضافة قسم'),
              ),
            ],
          ),
        ),

        // Sections List
        Expanded(
          child: _sections.isEmpty
              ? _buildEmptyContent(theme)
              : ReorderableListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _sections.length,
                  onReorder: _reorderSections,
                  itemBuilder: (context, index) {
                    final section = _sections[index];
                    return _buildSectionCard(section, index, theme);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildPricingTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Free Course Toggle
          SwitchListTile(
            title: const Text('كورس مجاني'),
            subtitle: const Text('جعل الكورس متاح مجاناً لجميع الطلاب'),
            value: _isFree,
            onChanged: (value) {
              setState(() {
                _isFree = value;
                if (value) {
                  _priceController.text = '0';
                  _hasDiscount = false;
                  _discountPriceController.clear();
                }
              });
            },
          ),

          const Divider(),

          if (!_isFree) ...[
            // Course Price
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: 'سعر الكورس *',
                hintText: '299',
                prefixIcon: Icon(Icons.attach_money),
                suffixText: 'ر.س',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              validator: (value) {
                if (!_isFree && (value == null || value.isEmpty)) {
                  return 'يرجى إدخال سعر الكورس';
                }
                if (!_isFree && double.tryParse(value!) == null) {
                  return 'يرجى إدخال سعر صحيح';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Discount Toggle
            SwitchListTile(
              title: const Text('تطبيق خصم'),
              subtitle: const Text('إضافة سعر مخفض للكورس'),
              value: _hasDiscount,
              onChanged: (value) {
                setState(() {
                  _hasDiscount = value;
                  if (!value) {
                    _discountPriceController.clear();
                  }
                });
              },
            ),

            if (_hasDiscount) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _discountPriceController,
                decoration: const InputDecoration(
                  labelText: 'السعر بعد الخصم *',
                  hintText: '199',
                  prefixIcon: Icon(Icons.local_offer),
                  suffixText: 'ر.س',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (_hasDiscount && (value == null || value.isEmpty)) {
                    return 'يرجى إدخال السعر المخفض';
                  }
                  if (_hasDiscount && double.tryParse(value!) == null) {
                    return 'يرجى إدخال سعر صحيح';
                  }
                  if (_hasDiscount &&
                      double.tryParse(value!) != null &&
                      double.tryParse(_priceController.text) != null &&
                      double.parse(value) >=
                          double.parse(_priceController.text)) {
                    return 'السعر المخفض يجب أن يكون أقل من السعر الأصلي';
                  }
                  return null;
                },
              ),
            ],

            const SizedBox(height: 24),

            // Pricing Summary
            _buildPricingSummary(theme),
          ],
        ],
      ),
    );
  }

  Widget _buildSettingsTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'إعدادات الكورس',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          // Course Settings
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('نشر الكورس'),
                  subtitle: const Text('جعل الكورس متاح للطلاب'),
                  value: _isPublished,
                  onChanged: (value) {
                    setState(() {
                      _isPublished = value;
                    });
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('السماح بالتعليقات'),
                  subtitle: const Text('السماح للطلاب بكتابة التعليقات'),
                  value: _allowComments,
                  onChanged: (value) {
                    setState(() {
                      _allowComments = value;
                    });
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('السماح بالتحميل'),
                  subtitle: const Text('السماح للطلاب بتحميل المواد'),
                  value: _allowDownloads,
                  onChanged: (value) {
                    setState(() {
                      _allowDownloads = value;
                    });
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('شهادة إتمام'),
                  subtitle: const Text('منح شهادة عند إتمام الكورس'),
                  value: _hasCertificate,
                  onChanged: (value) {
                    setState(() {
                      _hasCertificate = value;
                    });
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Additional Settings
          Text(
            'إعدادات إضافية',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 16),

          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.schedule),
                  title: const Text('مدة الوصول'),
                  subtitle: const Text('مدى الحياة'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Show access duration options
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.devices),
                  title: const Text('عدد الأجهزة المسموحة'),
                  subtitle: const Text('غير محدود'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Show device limit options
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.security),
                  title: const Text('مستوى الحماية'),
                  subtitle: const Text('عادي'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Show protection level options
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagsSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ..._tags.map((tag) {
              return Chip(
                label: Text(tag),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () {
                  setState(() {
                    _tags.remove(tag);
                  });
                },
                backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
              );
            }),
            ActionChip(
              label: const Text('إضافة كلمة مفتاحية'),
              avatar: const Icon(Icons.add, size: 16),
              onPressed: _addTag,
              backgroundColor: theme.colorScheme.surface,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'أضف كلمات مفتاحية لمساعدة الطلاب في العثور على كورسك',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildThumbnailSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'صورة الكورس',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.3),
            ),
          ),
          child: _thumbnailUrl.isEmpty
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image,
                      size: 48,
                      color: theme.colorScheme.onSurface.withOpacity(0.4),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'اضغط لإضافة صورة الكورس',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _selectThumbnail,
                      icon: const Icon(Icons.upload),
                      label: const Text('رفع صورة'),
                    ),
                  ],
                )
              : Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        _thumbnailUrl,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: theme.colorScheme.surface,
                            child: const Icon(Icons.error),
                          );
                        },
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: IconButton(
                          onPressed: () {
                            setState(() {
                              _thumbnailUrl = '';
                            });
                          },
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
        const SizedBox(height: 8),
        Text(
          'الحد الأدنى: 1280x720 بكسل. نسبة العرض إلى الارتفاع المفضلة: 16:9',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewVideoSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'فيديو المعاينة (اختياري)',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 150,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.3),
            ),
          ),
          child: _previewVideoUrl.isEmpty
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.play_circle_outline,
                      size: 48,
                      color: theme.colorScheme.onSurface.withOpacity(0.4),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'إضافة فيديو معاينة',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _selectPreviewVideo,
                      icon: const Icon(Icons.video_library),
                      label: const Text('رفع فيديو'),
                    ),
                  ],
                )
              : Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.play_circle_outline,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: IconButton(
                          onPressed: () {
                            setState(() {
                              _previewVideoUrl = '';
                            });
                          },
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
        const SizedBox(height: 8),
        Text(
          'فيديو قصير (1-3 دقائق) لإعطاء الطلاب فكرة عن محتوى الكورس',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyContent(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.video_library_outlined,
              size: 80,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'لا يوجد محتوى بعد',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'ابدأ بإضافة أقسام ودروس لكورسك',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _addSection,
              icon: const Icon(Icons.add),
              label: const Text('إضافة قسم جديد'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(
      Map<String, dynamic> section, int index, ThemeData theme) {
    return Card(
      key: ValueKey('section_$index'),
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(
          section['title'] ?? 'قسم بدون عنوان',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text('${(section['lessons'] as List).length} دروس'),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleSectionAction(value, index),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('تعديل'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'add_lesson',
              child: Row(
                children: [
                  Icon(Icons.add),
                  SizedBox(width: 8),
                  Text('إضافة درس'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('حذف', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
        children: [
          if ((section['lessons'] as List).isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'لا توجد دروس في هذا القسم',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () => _addLesson(index),
                    icon: const Icon(Icons.add),
                    label: const Text('إضافة درس'),
                  ),
                ],
              ),
            )
          else
            ...(section['lessons'] as List).asMap().entries.map((entry) {
              final lessonIndex = entry.key;
              final lesson = entry.value;
              return _buildLessonTile(lesson, index, lessonIndex, theme);
            }),
        ],
      ),
    );
  }

  Widget _buildLessonTile(Map<String, dynamic> lesson, int sectionIndex,
      int lessonIndex, ThemeData theme) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          lesson['type'] == 'video' ? Icons.play_arrow : Icons.article,
          color: AppTheme.primaryColor,
        ),
      ),
      title: Text(lesson['title'] ?? 'درس بدون عنوان'),
      subtitle: Text(
          '${lesson['duration'] ?? '00:00'} • ${lesson['type'] ?? 'فيديو'}'),
      trailing: PopupMenuButton<String>(
        onSelected: (value) =>
            _handleLessonAction(value, sectionIndex, lessonIndex),
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                Icon(Icons.edit),
                SizedBox(width: 8),
                Text('تعديل'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete, color: Colors.red),
                SizedBox(width: 8),
                Text('حذف', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingSummary(ThemeData theme) {
    final originalPrice = double.tryParse(_priceController.text) ?? 0;
    final discountPrice = _hasDiscount
        ? (double.tryParse(_discountPriceController.text) ?? 0)
        : 0;
    final savings = _hasDiscount ? originalPrice - discountPrice : 0;
    final discountPercentage = _hasDiscount && originalPrice > 0
        ? ((savings / originalPrice) * 100).round()
        : 0;

    return Card(
      color: AppTheme.primaryColor.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ملخص التسعير',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('السعر الأصلي:'),
                Text(
                  '${originalPrice.toStringAsFixed(0)} ر.س',
                  style: _hasDiscount
                      ? theme.textTheme.bodyMedium?.copyWith(
                          decoration: TextDecoration.lineThrough,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        )
                      : theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                ),
              ],
            ),
            if (_hasDiscount) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('السعر بعد الخصم:'),
                  Text(
                    '${discountPrice.toStringAsFixed(0)} ر.س',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('نسبة الخصم:'),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.successColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$discountPercentage%',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.successColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.3),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _saveDraft,
              child: const Text('حفظ كمسودة'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _isSaving ? null : _saveCourse,
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      widget.course != null ? 'حفظ التغييرات' : 'إنشاء الكورس'),
            ),
          ),
        ],
      ),
    );
  }

  String _getLevelText(CourseLevel level) {
    switch (level) {
      case CourseLevel.beginner:
        return 'مبتدئ';
      case CourseLevel.intermediate:
        return 'متوسط';
      case CourseLevel.advanced:
        return 'متقدم';
    }
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'preview':
        _previewCourse();
        break;
      case 'duplicate':
        _duplicateCourse();
        break;
      case 'delete':
        _deleteCourse();
        break;
    }
  }

  void _addTag() async {
    final result = await CustomDialog.showInput(
      context: context,
      title: 'إضافة كلمة مفتاحية',
      hintText: 'مثال: Flutter',
    );

    if (result != null && result.isNotEmpty && !_tags.contains(result)) {
      setState(() {
        _tags.add(result);
      });
    }
  }

  void _selectThumbnail() {
    CustomDialog.show(
      context: context,
      type: DialogType.info,
      title: 'رفع صورة',
      message: 'ميزة رفع الصور قيد التطوير',
    );
  }

  void _selectPreviewVideo() {
    CustomDialog.show(
      context: context,
      type: DialogType.info,
      title: 'رفع فيديو',
      message: 'ميزة رفع الفيديوهات قيد التطوير',
    );
  }

  void _addSection() async {
    final result = await CustomDialog.showInput(
      context: context,
      title: 'إضافة قسم جديد',
      hintText: 'عنوان القسم',
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        _sections.add({
          'title': result,
          'lessons': <Map<String, dynamic>>[],
          'isExpanded': true,
        });
      });
    }
  }

  void _reorderSections(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final section = _sections.removeAt(oldIndex);
      _sections.insert(newIndex, section);
    });
  }

  void _handleSectionAction(String action, int index) {
    switch (action) {
      case 'edit':
        _editSection(index);
        break;
      case 'add_lesson':
        _addLesson(index);
        break;
      case 'delete':
        _deleteSection(index);
        break;
    }
  }

  void _editSection(int index) async {
    final result = await CustomDialog.showInput(
      context: context,
      title: 'تعديل القسم',
      initialValue: _sections[index]['title'],
      hintText: 'عنوان القسم',
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        _sections[index]['title'] = result;
      });
    }
  }

  void _addLesson(int sectionIndex) {
    // Navigate to add lesson screen or show dialog
    CustomDialog.show(
      context: context,
      type: DialogType.info,
      title: 'إضافة درس',
      message: 'ميزة إضافة الدروس قيد التطوير',
    );
  }

  void _deleteSection(int index) async {
    final confirmed = await CustomDialog.showConfirmation(
      context: context,
      title: 'حذف القسم',
      message: 'هل تريد حذف هذا القسم وجميع دروسه؟',
      confirmText: 'حذف',
      cancelText: 'إلغاء',
    );

    if (confirmed == true) {
      setState(() {
        _sections.removeAt(index);
      });
    }
  }

  void _handleLessonAction(String action, int sectionIndex, int lessonIndex) {
    switch (action) {
      case 'edit':
        _editLesson(sectionIndex, lessonIndex);
        break;
      case 'delete':
        _deleteLesson(sectionIndex, lessonIndex);
        break;
    }
  }

  void _editLesson(int sectionIndex, int lessonIndex) {
    CustomDialog.show(
      context: context,
      type: DialogType.info,
      title: 'تعديل الدرس',
      message: 'ميزة تعديل الدروس قيد التطوير',
    );
  }

  void _deleteLesson(int sectionIndex, int lessonIndex) async {
    final confirmed = await CustomDialog.showConfirmation(
      context: context,
      title: 'حذف الدرس',
      message: 'هل تريد حذف هذا الدرس؟',
      confirmText: 'حذف',
      cancelText: 'إلغاء',
    );

    if (confirmed == true) {
      setState(() {
        (_sections[sectionIndex]['lessons'] as List).removeAt(lessonIndex);
      });
    }
  }

  void _previewCourse() {
    CustomDialog.show(
      context: context,
      type: DialogType.info,
      title: 'معاينة الكورس',
      message: 'ميزة معاينة الكورس قيد التطوير',
    );
  }

  void _duplicateCourse() {
    CustomDialog.show(
      context: context,
      type: DialogType.info,
      title: 'نسخ الكورس',
      message: 'ميزة نسخ الكورس قيد التطوير',
    );
  }

  void _deleteCourse() async {
    final confirmed = await CustomDialog.showConfirmation(
      context: context,
      title: 'حذف الكورس',
      message:
          'هل تريد حذف هذا الكورس نهائياً؟ لا يمكن التراجع عن هذا الإجراء.',
      confirmText: 'حذف',
      cancelText: 'إلغاء',
    );

    if (confirmed == true) {
      Navigator.of(context).pop();
      CustomDialog.showSuccess(
        context: context,
        title: 'تم الحذف',
        message: 'تم حذف الكورس بنجاح',
      );
    }
  }

  void _saveDraft() async {
    setState(() => _isSaving = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    setState(() => _isSaving = false);

    CustomDialog.showSuccess(
      context: context,
      title: 'تم الحفظ',
      message: 'تم حفظ الكورس كمسودة',
    );
  }

  void _saveCourse() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isSaving = false);

    final isEditing = widget.course != null;

    CustomDialog.showSuccess(
      context: context,
      title: isEditing ? 'تم التحديث' : 'تم الإنشاء',
      message: isEditing ? 'تم تحديث الكورس بنجاح' : 'تم إنشاء الكورس بنجاح',
    );

    if (!isEditing) {
      Navigator.of(context).pop();
    }
  }
}
