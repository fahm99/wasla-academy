import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../common/widgets/loading_widget.dart';
import '../../common/widgets/custom_dialog.dart';
import '../../common/themes/app_theme.dart';
import '../../common/models/course.dart';
import '../../common/models/user.dart' as app_user;
import '../../common/screens/payment/course_payment_screen.dart';

class CourseDetailsScreen extends StatefulWidget {
  final Course course;

  const CourseDetailsScreen({
    super.key,
    required this.course,
  });

  @override
  State<CourseDetailsScreen> createState() => _CourseDetailsScreenState();
}

class _CourseDetailsScreenState extends State<CourseDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  bool _isEnrolled = false;
  bool _isFavorite = false;
  Map<String, dynamic> _courseDetails = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadCourseDetails();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCourseDetails() async {
    setState(() => _isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    // Mock data
    _courseDetails = {
      'isEnrolled': false,
      'isFavorite': false,
      'progress': 0.0,
      'completedLessons': 0,
      'totalLessons': widget.course.lessonsCount,
      'curriculum': [
        {
          'title': 'مقدمة في Flutter',
          'lessons': [
            {
              'title': 'ما هو Flutter؟',
              'duration': '15:30',
              'isCompleted': false,
              'isFree': true
            },
            {
              'title': 'إعداد بيئة التطوير',
              'duration': '22:45',
              'isCompleted': false,
              'isFree': true
            },
            {
              'title': 'أول تطبيق Flutter',
              'duration': '18:20',
              'isCompleted': false,
              'isFree': false
            },
          ],
        },
        {
          'title': 'الويدجت الأساسية',
          'lessons': [
            {
              'title': 'Text و Container',
              'duration': '25:10',
              'isCompleted': false,
              'isFree': false
            },
            {
              'title': 'Row و Column',
              'duration': '30:15',
              'isCompleted': false,
              'isFree': false
            },
            {
              'title': 'ListView و GridView',
              'duration': '35:40',
              'isCompleted': false,
              'isFree': false
            },
          ],
        },
        {
          'title': 'إدارة الحالة',
          'lessons': [
            {
              'title': 'setState',
              'duration': '20:30',
              'isCompleted': false,
              'isFree': false
            },
            {
              'title': 'Provider',
              'duration': '45:20',
              'isCompleted': false,
              'isFree': false
            },
            {
              'title': 'Bloc Pattern',
              'duration': '55:15',
              'isCompleted': false,
              'isFree': false
            },
          ],
        },
      ],
      'reviews': [
        {
          'userName': 'أحمد محمد',
          'userAvatar':
              'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=50&h=50&fit=crop&crop=face',
          'rating': 5,
          'comment': 'كورس ممتاز ومفيد جداً، شرح واضح ومبسط',
          'date': '2024-01-15',
        },
        {
          'userName': 'فاطمة علي',
          'userAvatar':
              'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=50&h=50&fit=crop&crop=face',
          'rating': 4,
          'comment': 'محتوى قيم ولكن أتمنى المزيد من الأمثلة العملية',
          'date': '2024-01-10',
        },
      ],
      'instructor': {
        'name': widget.course.instructorName,
        'avatar': widget.course.instructorAvatar,
        'bio':
            'مطور تطبيقات موبايل بخبرة 8 سنوات، متخصص في Flutter و React Native',
        'coursesCount': 12,
        'studentsCount': 3247,
        'rating': 4.8,
      },
    };

    _isEnrolled = _courseDetails['isEnrolled'];
    _isFavorite = _courseDetails['isFavorite'];

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: _isLoading
          ? const LoadingWidget(message: 'جاري تحميل تفاصيل الكورس...')
          : CustomScrollView(
              slivers: [
                // App Bar with Course Image
                SliverAppBar(
                  expandedHeight: 250,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        widget.course.thumbnail != null
                            ? Image.network(
                                widget.course.thumbnail!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color:
                                        AppTheme.primaryColor.withOpacity(0.1),
                                    child: const Icon(
                                      Icons.play_circle_outline,
                                      size: 80,
                                      color: AppTheme.primaryColor,
                                    ),
                                  );
                                },
                              )
                            : Container(
                                color: AppTheme.primaryColor.withOpacity(0.1),
                                child: const Icon(
                                  Icons.play_circle_outline,
                                  size: 80,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.7),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 16,
                          left: 16,
                          right: 16,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.course.title,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${widget.course.rating}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '(${widget.course.reviewsCount} تقييم)',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                    ),
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    onPressed: _toggleFavorite,
                                    icon: Icon(
                                      _isFavorite
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: _isFavorite
                                          ? Colors.red
                                          : Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    IconButton(
                      onPressed: _shareContent,
                      icon: const Icon(Icons.share),
                    ),
                  ],
                ),

                // Course Info and Tabs
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      // Course Basic Info
                      _buildCourseInfo(theme),

                      // Tabs
                      Container(
                        color: theme.appBarTheme.backgroundColor,
                        child: TabBar(
                          controller: _tabController,
                          tabs: const [
                            Tab(text: 'المحتوى'),
                            Tab(text: 'الوصف'),
                            Tab(text: 'المراجعات'),
                            Tab(text: 'المدرب'),
                          ],
                          labelColor: AppTheme.primaryColor,
                          unselectedLabelColor:
                              theme.colorScheme.onSurface.withOpacity(0.6),
                          indicatorColor: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),

                // Tab Content
                SliverFillRemaining(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildCurriculumTab(theme),
                      _buildDescriptionTab(theme),
                      _buildReviewsTab(theme),
                      _buildInstructorTab(theme),
                    ],
                  ),
                ),
              ],
            ),
      bottomNavigationBar: _buildBottomBar(theme),
    );
  }

  Widget _buildCourseInfo(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Price and Enrollment Info
          Row(
            children: [
              if (widget.course.discountPrice != null) ...[
                Text(
                  '${widget.course.price} ر.س',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    decoration: TextDecoration.lineThrough,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${widget.course.discountPrice} ر.س',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ] else ...[
                Text(
                  '${widget.course.price} ر.س',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${widget.course.enrolledCount} طالب',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.successColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Course Stats
          Row(
            children: [
              _buildStatItem(
                Icons.play_circle_outline,
                '${widget.course.lessonsCount} درس',
                theme,
              ),
              const SizedBox(width: 24),
              _buildStatItem(
                Icons.access_time,
                '${(widget.course.duration / 60).toStringAsFixed(0)} ساعة',
                theme,
              ),
              const SizedBox(width: 24),
              _buildStatItem(
                Icons.signal_cellular_alt,
                _getLevelText(widget.course.level),
                theme,
              ),
            ],
          ),

          if (_isEnrolled) ...[
            const SizedBox(height: 16),
            // Progress Bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'التقدم في الكورس',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${(_courseDetails['progress'] * 100).toInt()}%',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: _courseDetails['progress'],
                  backgroundColor: theme.colorScheme.outline.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                      AppTheme.primaryColor),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_courseDetails['completedLessons']} من ${_courseDetails['totalLessons']} دروس مكتملة',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String text, ThemeData theme) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildCurriculumTab(ThemeData theme) {
    final curriculum = _courseDetails['curriculum'] as List;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: curriculum.length,
      itemBuilder: (context, index) {
        final section = curriculum[index];
        final lessons = section['lessons'] as List;

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ExpansionTile(
            title: Text(
              section['title'],
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text('${lessons.length} دروس'),
            children: lessons.map<Widget>((lesson) {
              return ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: lesson['isCompleted']
                        ? AppTheme.successColor
                        : lesson['isFree']
                            ? AppTheme.primaryColor.withOpacity(0.1)
                            : theme.colorScheme.outline.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    lesson['isCompleted']
                        ? Icons.check
                        : lesson['isFree']
                            ? Icons.play_arrow
                            : Icons.lock,
                    color: lesson['isCompleted']
                        ? Colors.white
                        : lesson['isFree']
                            ? AppTheme.primaryColor
                            : theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                title: Text(lesson['title']),
                subtitle: Text(lesson['duration']),
                trailing: lesson['isFree']
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.successColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'مجاني',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.successColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    : null,
                onTap: () => _onLessonTap(lesson),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildDescriptionTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'وصف الكورس',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.course.description,
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          Text(
            'ما ستتعلمه',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...widget.course.tags.map((tag) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: AppTheme.successColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'إتقان $tag بشكل عملي ومتقدم',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 24),
          Text(
            'المتطلبات',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const Text('• معرفة أساسية بالبرمجة'),
          const Text('• جهاز كمبيوتر مع إمكانية تثبيت البرامج'),
          const Text('• الرغبة في التعلم والممارسة'),
        ],
      ),
    );
  }

  Widget _buildReviewsTab(ThemeData theme) {
    final reviews = _courseDetails['reviews'] as List;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: reviews.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Column(
            children: [
              // Rating Summary
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.outline.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Column(
                      children: [
                        Text(
                          '${widget.course.rating}',
                          style: theme.textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        Row(
                          children: List.generate(5, (i) {
                            return Icon(
                              i < widget.course.rating.floor()
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.amber,
                              size: 20,
                            );
                          }),
                        ),
                        Text(
                          '${widget.course.reviewsCount} تقييم',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        children: List.generate(5, (i) {
                          final stars = 5 - i;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              children: [
                                Text('$stars'),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: LinearProgressIndicator(
                                    value: (stars == 5
                                        ? 0.7
                                        : stars == 4
                                            ? 0.2
                                            : 0.1),
                                    backgroundColor: theme.colorScheme.outline
                                        .withOpacity(0.3),
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                            Colors.amber),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (_isEnrolled)
                ElevatedButton.icon(
                  onPressed: _writeReview,
                  icon: const Icon(Icons.rate_review),
                  label: const Text('كتابة مراجعة'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
              const SizedBox(height: 16),
            ],
          );
        }

        final review = reviews[index - 1];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(review['userAvatar']),
                      radius: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            review['userName'],
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              ...List.generate(5, (i) {
                                return Icon(
                                  i < review['rating']
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: Colors.amber,
                                  size: 16,
                                );
                              }),
                              const SizedBox(width: 8),
                              Text(
                                review['date'],
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  review['comment'],
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInstructorTab(ThemeData theme) {
    final instructor = _courseDetails['instructor'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Instructor Info
          Row(
            children: [
              CircleAvatar(
                backgroundImage: instructor['avatar'] != null
                    ? NetworkImage(instructor['avatar'])
                    : null,
                radius: 40,
                backgroundColor: AppTheme.primaryColor,
                child: instructor['avatar'] == null
                    ? Text(
                        instructor['name'][0],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      instructor['name'],
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${instructor['rating']}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Instructor Stats
          Row(
            children: [
              Expanded(
                child: _buildInstructorStat(
                  '${instructor['coursesCount']}',
                  'كورس',
                  theme,
                ),
              ),
              Expanded(
                child: _buildInstructorStat(
                  '${instructor['studentsCount']}',
                  'طالب',
                  theme,
                ),
              ),
              Expanded(
                child: _buildInstructorStat(
                  '${instructor['rating']}',
                  'تقييم',
                  theme,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Bio
          Text(
            'نبذة عن المدرب',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            instructor['bio'],
            style: theme.textTheme.bodyLarge,
          ),

          const SizedBox(height: 24),

          // Contact Button
          ElevatedButton.icon(
            onPressed: _contactInstructor,
            icon: const Icon(Icons.message),
            label: const Text('التواصل مع المدرب'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructorStat(String value, String label, ThemeData theme) {
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
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
          if (!_isEnrolled) ...[
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _enrollCourse,
                icon: const Icon(Icons.shopping_cart),
                label: const Text('شراء الكورس'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(0, 48),
                ),
              ),
            ),
          ] else ...[
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _continueLearning,
                icon: const Icon(Icons.play_arrow),
                label: const Text('متابعة التعلم'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(0, 48),
                ),
              ),
            ),
          ],
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

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });

    CustomDialog.showSuccess(
      context: context,
      title: _isFavorite ? 'تم الإضافة' : 'تم الإزالة',
      message: _isFavorite
          ? 'تم إضافة الكورس إلى المفضلة'
          : 'تم إزالة الكورس من المفضلة',
    );
  }

  void _shareContent() {
    final courseUrl = 'https://wasla.edu/course/${widget.course.id}';
    final shareText =
        'تعرف على هذا الكورس الرائع: ${widget.course.title}\n\n${widget.course.description}\n\nتسجيل الآن: $courseUrl';

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            Text(
              'مشاركة الكورس',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),

            // Share options
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 3,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _buildShareOption(
                  Icons.copy,
                  'نسخ الرابط',
                  AppTheme.primaryColor,
                  () {
                    Clipboard.setData(ClipboardData(text: courseUrl));
                    Navigator.pop(context);
                    CustomDialog.showSuccess(
                      context: context,
                      title: 'تم النسخ',
                      message: 'تم نسخ رابط الكورس إلى الحافظة',
                    );
                  },
                ),
                _buildShareOption(
                  Icons.message,
                  'الرسائل',
                  Colors.green,
                  () {
                    Navigator.pop(context);
                    CustomDialog.show(
                      context: context,
                      type: DialogType.info,
                      title: 'مشاركة عبر الرسائل',
                      message: 'سيتم فتح تطبيق الرسائل...',
                    );
                  },
                ),
                _buildShareOption(
                  Icons.email,
                  'البريد',
                  Colors.blue,
                  () {
                    Navigator.pop(context);
                    CustomDialog.show(
                      context: context,
                      type: DialogType.info,
                      title: 'مشاركة عبر البريد',
                      message: 'سيتم فتح تطبيق البريد...',
                    );
                  },
                ),
                _buildShareOption(
                  Icons.share,
                  'مشاركة عامة',
                  Colors.orange,
                  () {
                    Navigator.pop(context);
                    CustomDialog.show(
                      context: context,
                      type: DialogType.success,
                      title: 'مشاركة الكورس',
                      message: 'تم مشاركة الكورس بنجاح!',
                    );
                  },
                ),
                _buildShareOption(
                  Icons.qr_code,
                  'رمز QR',
                  AppTheme.accentColor,
                  () {
                    Navigator.pop(context);
                    _showQRCode(courseUrl);
                  },
                ),
                _buildShareOption(
                  Icons.more_horiz,
                  'أخرى',
                  Colors.grey,
                  () {
                    Navigator.pop(context);
                    CustomDialog.show(
                      context: context,
                      type: DialogType.info,
                      title: 'مزيد من الخيارات',
                      message: 'مزيد من خيارات المشاركة قريباً...',
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Preview text
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                ),
              ),
              child: Text(
                shareText,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.7),
                    ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareOption(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showQRCode(String url) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('رمز QR للكورس'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // QR Code placeholder
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.qr_code,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'رمز QR',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'امسح هذا الرمز لفتح الكورس',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  void _onLessonTap(Map<String, dynamic> lesson) {
    if (lesson['isFree'] || _isEnrolled) {
      // Navigate to lesson screen
      Navigator.pushNamed(
        context,
        '/student/lesson',
        arguments: lesson,
      );
    } else {
      CustomDialog.show(
        context: context,
        type: DialogType.warning,
        title: 'محتوى مدفوع',
        message: 'يجب شراء الكورس أولاً لمشاهدة هذا الدرس',
      );
    }
  }

  void _writeReview() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: _WriteReviewBottomSheet(
          course: widget.course,
          onReviewSubmitted: (rating, comment) {
            Navigator.pop(context);
            CustomDialog.showSuccess(
              context: context,
              title: 'شكراً لك!',
              message: 'تم إرسال مراجعتك بنجاح',
            );
          },
        ),
      ),
    );
  }

  void _contactInstructor() {
    // Create User object for instructor
    final instructor = app_user.User(
      id: widget.course.instructorId,
      name: widget.course.instructorName ?? 'المدرب',
      email: 'instructor@example.com',
      avatar: widget.course.instructorAvatar,
      role: app_user.UserRole.instructor,
      createdAt: DateTime.now(),
    );

    Navigator.pushNamed(
      context,
      '/student/chat',
      arguments: instructor,
    );
  }

  void _downloadMaterials() {
    CustomDialog.show(
      context: context,
      type: DialogType.info,
      title: 'تحميل المواد',
      message: 'ميزة تحميل المواد قيد التطوير',
    );
  }

  void _enrollCourse() {
    // Navigate to payment screen with required parameters
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CoursePaymentScreen(
          userId: 'test_user_id', // This should be replaced with actual user ID
          course: widget.course,
        ),
      ),
    );
  }

  void _continueLearning() {
    // Navigate to next lesson or course content
    Navigator.pushNamed(
      context,
      '/student/learning',
      arguments: widget.course,
    );
  }
}

class _WriteReviewBottomSheet extends StatefulWidget {
  final Course course;
  final Function(int rating, String comment) onReviewSubmitted;

  const _WriteReviewBottomSheet({
    required this.course,
    required this.onReviewSubmitted,
  });

  @override
  State<_WriteReviewBottomSheet> createState() =>
      _WriteReviewBottomSheetState();
}

class _WriteReviewBottomSheetState extends State<_WriteReviewBottomSheet> {
  int _rating = 0;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Title
          Text(
            'كتابة مراجعة',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          Text(
            widget.course.title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 24),

          // Rating Section
          Text(
            'تقييمك للكورس',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _rating = index + 1;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 40,
                  ),
                ),
              );
            }),
          ),

          if (_rating > 0)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _getRatingText(_rating),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

          const SizedBox(height: 24),

          // Comment Section
          Text(
            'التعليق (اختياري)',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _commentController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'شارك تجربتك مع هذا الكورس...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),

          const SizedBox(height: 24),

          // Submit Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _rating > 0 && !_isSubmitting ? _submitReview : null,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(0, 48),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('إرسال المراجعة'),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  String _getRatingText(int rating) {
    switch (rating) {
      case 1:
        return 'ضعيف جداً';
      case 2:
        return 'ضعيف';
      case 3:
        return 'مقبول';
      case 4:
        return 'جيد';
      case 5:
        return 'ممتاز';
      default:
        return '';
    }
  }

  Future<void> _submitReview() async {
    setState(() {
      _isSubmitting = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      widget.onReviewSubmitted(_rating, _commentController.text.trim());
    }

    setState(() {
      _isSubmitting = false;
    });
  }
}
