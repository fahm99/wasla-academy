import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../common/widgets/loading_widget.dart';
import '../../common/widgets/custom_dialog.dart';
import '../../common/themes/app_theme.dart';

class LessonScreen extends StatefulWidget {
  final Map<String, dynamic> lesson;
  
  const LessonScreen({
    super.key,
    required this.lesson,
  });

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  bool _isLoading = true;
  bool _isPlaying = false;
  bool _isFullscreen = false;
  bool _showControls = true;
  double _currentPosition = 0.0;
  final double _totalDuration = 100.0;
  double _playbackSpeed = 1.0;
  bool _isCompleted = false;
  
  Map<String, dynamic> _lessonData = {};
  List<Map<String, dynamic>> _notes = [];
  List<Map<String, dynamic>> _attachments = [];

  @override
  void initState() {
    super.initState();
    _loadLessonData();
  }

  Future<void> _loadLessonData() async {
    setState(() => _isLoading = true);
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    
    // Mock data
    _lessonData = {
      'title': widget.lesson['title'],
      'description': 'في هذا الدرس سنتعلم أساسيات Flutter وكيفية إنشاء أول تطبيق. سنغطي المفاهيم الأساسية والأدوات المطلوبة.',
      'videoUrl': 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4',
      'duration': widget.lesson['duration'],
      'isCompleted': widget.lesson['isCompleted'] ?? false,
      'progress': 0.0,
      'nextLesson': {
        'title': 'إعداد بيئة التطوير',
        'duration': '22:45',
      },
      'previousLesson': null,
    };
    
    _notes = [
      {
        'time': '02:30',
        'note': 'Flutter هو SDK مفتوح المصدر من Google',
        'timestamp': DateTime.now().subtract(const Duration(minutes: 5)),
      },
      {
        'time': '05:15',
        'note': 'يمكن استخدام Flutter لتطوير تطبيقات iOS و Android',
        'timestamp': DateTime.now().subtract(const Duration(minutes: 3)),
      },
    ];
    
    _attachments = [
      {
        'name': 'كود المشروع',
        'type': 'zip',
        'size': '2.5 MB',
        'url': 'https://example.com/project.zip',
      },
      {
        'name': 'الشرائح التقديمية',
        'type': 'pdf',
        'size': '1.2 MB',
        'url': 'https://example.com/slides.pdf',
      },
    ];
    
    _isCompleted = _lessonData['isCompleted'];
    
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Scaffold(
        body: LoadingWidget(message: 'جاري تحميل الدرس...'),
      );
    }

    return Scaffold(
      backgroundColor: _isFullscreen ? Colors.black : null,
      appBar: _isFullscreen ? null : AppBar(
        title: Text(
          _lessonData['title'],
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            onPressed: _toggleBookmark,
            icon: const Icon(Icons.bookmark_border),
          ),
          IconButton(
            onPressed: _shareLesson,
            icon: const Icon(Icons.share),
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'report',
                child: Row(
                  children: [
                    Icon(Icons.report),
                    SizedBox(width: 8),
                    Text('الإبلاغ عن مشكلة'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'download',
                child: Row(
                  children: [
                    Icon(Icons.download),
                    SizedBox(width: 8),
                    Text('تحميل للمشاهدة لاحقاً'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Video Player
          _buildVideoPlayer(theme),
          
          // Content
          if (!_isFullscreen)
            Expanded(
              child: DefaultTabController(
                length: 3,
                child: Column(
                  children: [
                    // Tab Bar
                    Container(
                      color: theme.appBarTheme.backgroundColor,
                      child: const TabBar(
                        tabs: [
                          Tab(text: 'الوصف'),
                          Tab(text: 'الملاحظات'),
                          Tab(text: 'المرفقات'),
                        ],
                        labelColor: AppTheme.primaryColor,
                        indicatorColor: AppTheme.primaryColor,
                      ),
                    ),
                    
                    // Tab Content
                    Expanded(
                      child: TabBarView(
                        children: [
                          _buildDescriptionTab(theme),
                          _buildNotesTab(theme),
                          _buildAttachmentsTab(theme),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: _isFullscreen ? null : _buildBottomBar(theme),
    );
  }

  Widget _buildVideoPlayer(ThemeData theme) {
    return Container(
      width: double.infinity,
      height: _isFullscreen 
          ? MediaQuery.of(context).size.height
          : MediaQuery.of(context).size.width * 9 / 16,
      color: Colors.black,
      child: Stack(
        children: [
          // Video placeholder
          Center(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.grey[800]!,
                    Colors.grey[900]!,
                  ],
                ),
              ),
              child: const Icon(
                Icons.play_circle_outline,
                size: 80,
                color: Colors.white,
              ),
            ),
          ),
          
          // Video Controls
          if (_showControls)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.3),
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    // Top Controls
                    if (_isFullscreen)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _isFullscreen = false;
                                });
                                SystemChrome.setPreferredOrientations([
                                  DeviceOrientation.portraitUp,
                                ]);
                              },
                              icon: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                _lessonData['title'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    const Spacer(),
                    
                    // Center Play Button
                    GestureDetector(
                      onTap: _togglePlayPause,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),
                    
                    const Spacer(),
                    
                    // Bottom Controls
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          // Progress Bar
                          Row(
                            children: [
                              Text(
                                _formatDuration(_currentPosition),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                              Expanded(
                                child: Slider(
                                  value: _currentPosition,
                                  max: _totalDuration,
                                  onChanged: (value) {
                                    setState(() {
                                      _currentPosition = value;
                                    });
                                  },
                                  activeColor: AppTheme.primaryColor,
                                  inactiveColor: Colors.white.withOpacity(0.3),
                                ),
                              ),
                              Text(
                                _formatDuration(_totalDuration),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          
                          // Control Buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: _rewind10,
                                    icon: const Icon(
                                      Icons.replay_10,
                                      color: Colors.white,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: _togglePlayPause,
                                    icon: Icon(
                                      _isPlaying ? Icons.pause : Icons.play_arrow,
                                      color: Colors.white,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: _forward10,
                                    icon: const Icon(
                                      Icons.forward_10,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  // Playback Speed
                                  GestureDetector(
                                    onTap: _showSpeedDialog,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.5),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        '${_playbackSpeed}x',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    onPressed: _toggleFullscreen,
                                    icon: Icon(
                                      _isFullscreen
                                          ? Icons.fullscreen_exit
                                          : Icons.fullscreen,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          // Tap to show/hide controls
          GestureDetector(
            onTap: () {
              setState(() {
                _showControls = !_showControls;
              });
            },
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.transparent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Lesson Info
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _isCompleted 
                      ? AppTheme.successColor.withOpacity(0.1)
                      : AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isCompleted ? Icons.check_circle : Icons.play_circle,
                      size: 16,
                      color: _isCompleted ? AppTheme.successColor : AppTheme.primaryColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _isCompleted ? 'مكتمل' : 'قيد المشاهدة',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: _isCompleted ? AppTheme.successColor : AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                _lessonData['duration'],
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Description
          Text(
            'وصف الدرس',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _lessonData['description'],
            style: theme.textTheme.bodyLarge,
          ),
          
          const SizedBox(height: 24),
          
          // Progress
          if (!_isCompleted)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'التقدم في الدرس',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${(_lessonData['progress'] * 100).toInt()}%',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: _lessonData['progress'],
                  backgroundColor: theme.colorScheme.outline.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                ),
                const SizedBox(height: 16),
              ],
            ),
          
          // Mark as Complete Button
          if (!_isCompleted)
            ElevatedButton.icon(
              onPressed: _markAsComplete,
              icon: const Icon(Icons.check_circle),
              label: const Text('تحديد كمكتمل'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNotesTab(ThemeData theme) {
    return Column(
      children: [
        // Add Note Button
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: _addNote,
            icon: const Icon(Icons.note_add),
            label: const Text('إضافة ملاحظة'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ),
        
        // Notes List
        Expanded(
          child: _notes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.note_outlined,
                        size: 80,
                        color: theme.colorScheme.onSurface.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'لا توجد ملاحظات بعد',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'اضغط على "إضافة ملاحظة" لإضافة ملاحظاتك',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _notes.length,
                  itemBuilder: (context, index) {
                    final note = _notes[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              note['time'],
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        title: Text(note['note']),
                        subtitle: Text(
                          _formatTimestamp(note['timestamp']),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) => _handleNoteAction(note, value),
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
                        onTap: () => _jumpToTime(note['time']),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildAttachmentsTab(ThemeData theme) {
    return _attachments.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.attach_file,
                  size: 80,
                  color: theme.colorScheme.onSurface.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  'لا توجد مرفقات',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _attachments.length,
            itemBuilder: (context, index) {
              final attachment = _attachments[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _getFileTypeColor(attachment['type']).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getFileTypeIcon(attachment['type']),
                      color: _getFileTypeColor(attachment['type']),
                    ),
                  ),
                  title: Text(attachment['name']),
                  subtitle: Text(attachment['size']),
                  trailing: IconButton(
                    onPressed: () => _downloadAttachment(attachment),
                    icon: const Icon(Icons.download),
                  ),
                ),
              );
            },
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
          // Previous Lesson
          if (_lessonData['previousLesson'] != null)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _goToPreviousLesson,
                icon: const Icon(Icons.skip_previous),
                label: const Text('الدرس السابق'),
              ),
            ),
          
          if (_lessonData['previousLesson'] != null && _lessonData['nextLesson'] != null)
            const SizedBox(width: 16),
          
          // Next Lesson
          if (_lessonData['nextLesson'] != null)
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _goToNextLesson,
                icon: const Icon(Icons.skip_next),
                label: const Text('الدرس التالي'),
              ),
            ),
        ],
      ),
    );
  }

  String _formatDuration(double seconds) {
    final duration = Duration(seconds: seconds.toInt());
    final minutes = duration.inMinutes;
    final remainingSeconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'الآن';
    } else if (difference.inMinutes < 60) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inHours < 24) {
      return 'منذ ${difference.inHours} ساعة';
    } else {
      return 'منذ ${difference.inDays} يوم';
    }
  }

  IconData _getFileTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'zip':
        return Icons.archive;
      case 'doc':
      case 'docx':
        return Icons.description;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _getFileTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'pdf':
        return Colors.red;
      case 'zip':
        return Colors.orange;
      case 'doc':
      case 'docx':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  void _rewind10() {
    setState(() {
      _currentPosition = (_currentPosition - 10).clamp(0, _totalDuration);
    });
  }

  void _forward10() {
    setState(() {
      _currentPosition = (_currentPosition + 10).clamp(0, _totalDuration);
    });
  }

  void _toggleFullscreen() {
    setState(() {
      _isFullscreen = !_isFullscreen;
    });
    
    if (_isFullscreen) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    }
  }

  void _showSpeedDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('سرعة التشغيل'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [0.5, 0.75, 1.0, 1.25, 1.5, 2.0].map((speed) {
              return RadioListTile<double>(
                title: Text('${speed}x'),
                value: speed,
                groupValue: _playbackSpeed,
                onChanged: (value) {
                  setState(() {
                    _playbackSpeed = value!;
                  });
                  Navigator.of(context).pop();
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _toggleBookmark() {
    CustomDialog.showSuccess(
      context: context,
      title: 'تم الحفظ',
      message: 'تم إضافة الدرس إلى المفضلة',
    );
  }

  void _shareLesson() {
    CustomDialog.show(
      context: context,
      type: DialogType.info,
      title: 'مشاركة الدرس',
      message: 'ميزة المشاركة قيد التطوير',
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'report':
        CustomDialog.show(
          context: context,
          type: DialogType.info,
          title: 'الإبلاغ عن مشكلة',
          message: 'ميزة الإبلاغ قيد التطوير',
        );
        break;
      case 'download':
        CustomDialog.show(
          context: context,
          type: DialogType.info,
          title: 'تحميل الدرس',
          message: 'ميزة التحميل قيد التطوير',
        );
        break;
    }
  }

  void _markAsComplete() {
    setState(() {
      _isCompleted = true;
      _lessonData['isCompleted'] = true;
    });
    
    CustomDialog.showSuccess(
      context: context,
      title: 'تم الإكمال',
      message: 'تم تحديد الدرس كمكتمل بنجاح',
    );
  }

  void _addNote() {
    CustomDialog.show(
      context: context,
      type: DialogType.info,
      title: 'إضافة ملاحظة',
      message: 'ميزة إضافة الملاحظات قيد التطوير',
    );
  }

  void _handleNoteAction(Map<String, dynamic> note, String action) {
    switch (action) {
      case 'edit':
        CustomDialog.show(
          context: context,
          type: DialogType.info,
          title: 'تعديل الملاحظة',
          message: 'ميزة تعديل الملاحظات قيد التطوير',
        );
        break;
      case 'delete':
        setState(() {
          _notes.remove(note);
        });
        CustomDialog.showSuccess(
          context: context,
          title: 'تم الحذف',
          message: 'تم حذف الملاحظة بنجاح',
        );
        break;
    }
  }

  void _jumpToTime(String time) {
    // Parse time and jump to that position in video
    CustomDialog.show(
      context: context,
      type: DialogType.info,
      title: 'الانتقال للوقت',
      message: 'ميزة الانتقال للوقت المحدد قيد التطوير',
    );
  }

  void _downloadAttachment(Map<String, dynamic> attachment) {
    CustomDialog.show(
      context: context,
      type: DialogType.info,
      title: 'تحميل المرفق',
      message: 'ميزة تحميل المرفقات قيد التطوير',
    );
  }

  void _goToPreviousLesson() {
    Navigator.of(context).pop();
  }

  void _goToNextLesson() {
    Navigator.pushReplacementNamed(
      context,
      '/student/lesson',
      arguments: _lessonData['nextLesson'],
    );
  }
}

