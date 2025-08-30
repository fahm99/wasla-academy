import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../common/models/live_session.dart' as models;
import '../../common/models/course.dart';
import '../../common/widgets/custom_app_bar.dart';
import '../../common/themes/app_theme.dart';
import '../../common/bloc/live_session/live_session_bloc.dart';
import '../../common/bloc/live_session/live_session_event.dart';
import '../../common/bloc/live_session/live_session_state.dart';

class CreateLiveSessionScreen extends StatefulWidget {
  final Course? course;
  final models.LiveSession? session; // For editing

  const CreateLiveSessionScreen({
    super.key,
    this.course,
    this.session,
  });

  @override
  State<CreateLiveSessionScreen> createState() =>
      _CreateLiveSessionScreenState();
}

class _CreateLiveSessionScreenState extends State<CreateLiveSessionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _tagsController = TextEditingController();

  DateTime _scheduledDate = DateTime.now().add(const Duration(hours: 1));
  TimeOfDay _scheduledTime = TimeOfDay.now();
  int _duration = 60;
  int _maxParticipants = 100;
  bool _allowChat = true;
  bool _allowParticipantsVideo = false;
  bool _allowParticipantsAudio = false;
  bool _isRecorded = false;
  models.StreamQuality _quality = models.StreamQuality.auto;
  Course? _selectedCourse;

  bool get _isEditing => widget.session != null;

  @override
  void initState() {
    super.initState();
    _selectedCourse = widget.course;

    if (_isEditing) {
      _loadSessionData();
    }
  }

  void _loadSessionData() {
    final session = widget.session!;
    _titleController.text = session.title;
    _descriptionController.text = session.description;
    _tagsController.text = session.tags.join(', ');
    _scheduledDate = session.scheduledAt;
    _scheduledTime = TimeOfDay.fromDateTime(session.scheduledAt);
    _duration = session.duration;
    _maxParticipants = session.maxParticipants;
    _allowChat = session.allowChat;
    _allowParticipantsVideo = session.allowParticipantsVideo;
    _allowParticipantsAudio = session.allowParticipantsAudio;
    _isRecorded = session.isRecorded;
    _quality = session.quality;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: _isEditing ? 'تحرير الجلسة المباشرة' : 'إنشاء جلسة مباشرة جديدة',
        actions: [
          BlocBuilder<LiveSessionBloc, LiveSessionState>(
            builder: (context, state) {
              return TextButton(
                onPressed: state.status == LiveSessionStatus.loading
                    ? null
                    : _saveSession,
                child: Text(
                  _isEditing ? 'حفظ' : 'إنشاء',
                  style: TextStyle(
                    color: state.status == LiveSessionStatus.loading
                        ? Colors.grey
                        : AppTheme.primaryColor,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocListener<LiveSessionBloc, LiveSessionState>(
        listener: (context, state) {
          if (state.status == LiveSessionStatus.loaded &&
              state.currentSession != null) {
            Navigator.of(context).pop(state.currentSession);
          } else if (state.status == LiveSessionStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error ?? 'حدث خطأ غير معروف'),
                backgroundColor: AppTheme.errorColor,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBasicInfoSection(theme),
                const SizedBox(height: 24),
                _buildScheduleSection(theme),
                const SizedBox(height: 24),
                _buildSettingsSection(theme),
                const SizedBox(height: 24),
                _buildAdvancedSection(theme),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'المعلومات الأساسية',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'عنوان الجلسة',
                hintText: 'أدخل عنوان الجلسة المباشرة',
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'يرجى إدخال عنوان الجلسة';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'وصف الجلسة',
                hintText: 'أدخل وصف مفصل للجلسة المباشرة',
                prefixIcon: Icon(Icons.description),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'يرجى إدخال وصف الجلسة';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Course Selection
            DropdownButtonFormField<Course>(
              value: _selectedCourse,
              decoration: const InputDecoration(
                labelText: 'الكورس المرتبط',
                prefixIcon: Icon(Icons.school),
              ),
              items: _generateCourseItems(),
              onChanged: (Course? course) {
                setState(() {
                  _selectedCourse = course;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'يرجى اختيار الكورس المرتبط';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Tags
            TextFormField(
              controller: _tagsController,
              decoration: const InputDecoration(
                labelText: 'الوسوم',
                hintText: 'أدخل الوسوم مفصولة بفاصلة',
                prefixIcon: Icon(Icons.tag),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'الجدولة والتوقيت',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Date
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('تاريخ الجلسة'),
              subtitle: Text(DateFormat('dd/MM/yyyy').format(_scheduledDate)),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: _selectDate,
            ),

            const Divider(),

            // Time
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('وقت الجلسة'),
              subtitle: Text(_scheduledTime.format(context)),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: _selectTime,
            ),

            const Divider(),

            // Duration
            ListTile(
              leading: const Icon(Icons.timer),
              title: const Text('مدة الجلسة'),
              subtitle: Text('$_duration دقيقة'),
              trailing: SizedBox(
                width: 120,
                child: DropdownButton<int>(
                  value: _duration,
                  isExpanded: true,
                  items: [30, 45, 60, 90, 120, 180].map((duration) {
                    return DropdownMenuItem(
                      value: duration,
                      child: Text('$duration دقيقة'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _duration = value;
                      });
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'إعدادات الجلسة',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Max Participants
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('الحد الأقصى للمشاركين'),
              subtitle: Text('$_maxParticipants مشارك'),
              trailing: SizedBox(
                width: 120,
                child: DropdownButton<int>(
                  value: _maxParticipants,
                  isExpanded: true,
                  items: [50, 100, 200, 500, 1000].map((count) {
                    return DropdownMenuItem(
                      value: count,
                      child: Text('$count'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _maxParticipants = value;
                      });
                    }
                  },
                ),
              ),
            ),

            const Divider(),

            // Allow Chat
            SwitchListTile(
              secondary: const Icon(Icons.chat),
              title: const Text('السماح بالدردشة'),
              subtitle: const Text('السماح للمشاركين بإرسال الرسائل'),
              value: _allowChat,
              onChanged: (value) {
                setState(() {
                  _allowChat = value;
                });
              },
            ),

            const Divider(),

            // Allow Participants Video
            SwitchListTile(
              secondary: const Icon(Icons.videocam),
              title: const Text('السماح بفيديو المشاركين'),
              subtitle: const Text('السماح للمشاركين بتشغيل الكاميرا'),
              value: _allowParticipantsVideo,
              onChanged: (value) {
                setState(() {
                  _allowParticipantsVideo = value;
                });
              },
            ),

            const Divider(),

            // Allow Participants Audio
            SwitchListTile(
              secondary: const Icon(Icons.mic),
              title: const Text('السماح بصوت المشاركين'),
              subtitle: const Text('السماح للمشاركين بتشغيل الميكروفون'),
              value: _allowParticipantsAudio,
              onChanged: (value) {
                setState(() {
                  _allowParticipantsAudio = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'إعدادات متقدمة',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Recording
            SwitchListTile(
              secondary: const Icon(Icons.fiber_manual_record),
              title: const Text('تسجيل الجلسة'),
              subtitle: const Text('حفظ تسجيل للجلسة المباشرة'),
              value: _isRecorded,
              onChanged: (value) {
                setState(() {
                  _isRecorded = value;
                });
              },
            ),

            const Divider(),

            // Video Quality
            ListTile(
              leading: const Icon(Icons.high_quality),
              title: const Text('جودة الفيديو'),
              subtitle: Text(_getQualityText(_quality)),
              trailing: SizedBox(
                width: 120,
                child: DropdownButton<models.StreamQuality>(
                  value: _quality,
                  isExpanded: true,
                  items: models.StreamQuality.values.map((quality) {
                    return DropdownMenuItem(
                      value: quality,
                      child: Text(_getQualityText(quality)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _quality = value;
                      });
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<DropdownMenuItem<Course>> _generateCourseItems() {
    // Mock courses - Replace with actual course data
    final courses = [
      Course(
        id: '1',
        title: 'دورة البرمجة الأساسية',
        description: 'تعلم أساسيات البرمجة',
        instructorId: 'instructor1',
        instructorName: 'د. أحمد محمد',
        price: 299.0,
        duration: 1200, // duration in minutes
        lessonsCount: 20,
        level: CourseLevel.beginner,
        status: CourseStatus.published,
        category: 'البرمجة',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Course(
        id: '2',
        title: 'تطوير تطبيقات الموبايل',
        description: 'تعلم تطوير التطبيقات',
        instructorId: 'instructor1',
        instructorName: 'د. أحمد محمد',
        price: 499.0,
        duration: 1800, // duration in minutes
        lessonsCount: 30,
        level: CourseLevel.intermediate,
        status: CourseStatus.published,
        category: 'البرمجة',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    return courses.map((course) {
      return DropdownMenuItem(
        value: course,
        child: Text(course.title),
      );
    }).toList();
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _scheduledDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() {
        _scheduledDate = date;
      });
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _scheduledTime,
    );

    if (time != null) {
      setState(() {
        _scheduledTime = time;
      });
    }
  }

  void _saveSession() {
    if (!_formKey.currentState!.validate()) return;

    final scheduledDateTime = DateTime(
      _scheduledDate.year,
      _scheduledDate.month,
      _scheduledDate.day,
      _scheduledTime.hour,
      _scheduledTime.minute,
    );

    final tags = _tagsController.text
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();

    final session = models.LiveSession(
      id: _isEditing
          ? widget.session!.id
          : DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      instructorId:
          'current_instructor_id', // Replace with actual instructor ID
      instructorName:
          'Current Instructor', // Replace with actual instructor name
      courseId: _selectedCourse!.id,
      courseName: _selectedCourse!.title,
      scheduledAt: scheduledDateTime,
      duration: _duration,
      status: models.LiveSessionStatus.scheduled,
      maxParticipants: _maxParticipants,
      tags: tags,
      allowChat: _allowChat,
      allowParticipantsVideo: _allowParticipantsVideo,
      allowParticipantsAudio: _allowParticipantsAudio,
      isRecorded: _isRecorded,
      quality: _quality,
      createdAt: _isEditing ? widget.session!.createdAt : DateTime.now(),
      updatedAt: DateTime.now(),
    );

    context.read<LiveSessionBloc>().add(CreateLiveSession(session));
  }

  String _getQualityText(models.StreamQuality quality) {
    switch (quality) {
      case models.StreamQuality.low:
        return 'منخفضة';
      case models.StreamQuality.medium:
        return 'متوسطة';
      case models.StreamQuality.high:
        return 'عالية';
      case models.StreamQuality.auto:
        return 'تلقائي';
    }
  }
}
