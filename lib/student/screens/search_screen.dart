import 'package:flutter/material.dart';
import '../../common/widgets/custom_app_bar.dart';
import '../../common/widgets/course_card.dart';
import '../../common/widgets/loading_widget.dart';
import '../../common/themes/app_theme.dart';
import '../../common/models/course.dart';
import '../../common/services/supabase_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  bool _isLoading = false;
  bool _isLoadingMore = false;
  String _currentQuery = '';
  List<Course> _searchResults = [];
  List<String> _recentSearches = [];
  List<String> _popularSearches = [];
  List<Map<String, dynamic>> _categories = [];
  final List<Map<String, dynamic>> _filters = [];

  String _selectedCategory = '';
  String _selectedLevel = '';
  String _selectedPriceRange = '';
  String _selectedRating = '';
  String _sortBy = 'relevance';

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);

    try {
      // Fetch data from database
      _recentSearches = await SupabaseService.instance.getRecentSearches('user_id'); // Replace with actual user ID
      _popularSearches = await SupabaseService.instance.getPopularSearches();
      _categories = await SupabaseService.instance.getCategoriesWithCounts();
    } catch (e) {
      // Fallback to mock data if there's an error
      _recentSearches = [
        'Flutter',
        'تطوير تطبيقات الموبايل',
        'البرمجة للمبتدئين',
        'React Native',
      ];

      _popularSearches = [
        'Flutter',
        'React',
        'Python',
        'JavaScript',
        'تطوير الويب',
        'علوم البيانات',
        'الذكاء الاصطناعي',
        'التصميم',
      ];

      _categories = [
        {'name': 'البرمجة', 'count': 45, 'icon': Icons.code},
        {'name': 'التصميم', 'count': 32, 'icon': Icons.design_services},
        {'name': 'التسويق', 'count': 28, 'icon': Icons.campaign},
        {'name': 'الأعمال', 'count': 24, 'icon': Icons.business},
        {'name': 'اللغات', 'count': 18, 'icon': Icons.language},
        {'name': 'الصحة', 'count': 15, 'icon': Icons.health_and_safety},
      ];
    }

    setState(() => _isLoading = false);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore && _searchResults.isNotEmpty) {
        _loadMoreResults();
      }
    }
  }

  Future<void> _loadMoreResults() async {
    setState(() => _isLoadingMore = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    // Mock additional results
    final moreResults = _generateMockCourses(5);

    setState(() {
      _searchResults.addAll(moreResults);
      _isLoadingMore = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'البحث',
        actions: [
          IconButton(
            onPressed: _showFilters,
            icon: Stack(
              children: [
                const Icon(Icons.tune),
                if (_hasActiveFilters())
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          _buildSearchBar(theme),

          // Content
          Expanded(
            child: _isLoading
                ? const LoadingWidget(message: 'جاري التحميل...')
                : _currentQuery.isEmpty
                    ? _buildSearchHome(theme)
                    : _buildSearchResults(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return Container(
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
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'ابحث عن الكورسات والمدربين...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: _clearSearch,
                        icon: const Icon(Icons.clear),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: theme.colorScheme.surface,
              ),
              onChanged: _onSearchChanged,
              onSubmitted: _performSearch,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: () => _performSearch(_searchController.text),
              icon: const Icon(
                Icons.search,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchHome(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recent Searches
          if (_recentSearches.isNotEmpty) ...[
            _buildSectionHeader('البحث الأخير', theme),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _recentSearches.map((search) {
                return _buildSearchChip(
                  search,
                  Icons.history,
                  () => _performSearch(search),
                  onDelete: () => _removeRecentSearch(search),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],

          // Popular Searches
          _buildSectionHeader('البحث الشائع', theme),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _popularSearches.map((search) {
              return _buildSearchChip(
                search,
                Icons.trending_up,
                () => _performSearch(search),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // Categories
          _buildSectionHeader('التصنيفات', theme),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.5,
            ),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              return _buildCategoryCard(category, theme);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(ThemeData theme) {
    if (_searchResults.isEmpty && !_isLoading) {
      return _buildEmptyResults(theme);
    }

    return Column(
      children: [
        // Results Header
        _buildResultsHeader(theme),

        // Results List
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: _searchResults.length + (_isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == _searchResults.length) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final course = _searchResults[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: CourseCard(
                  course: course,
                  onTap: () => _navigateToCourse(course),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Text(
      title,
      style: theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildSearchChip(
    String text,
    IconData icon,
    VoidCallback onTap, {
    VoidCallback? onDelete,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Chip(
        avatar: Icon(icon, size: 16),
        label: Text(text),
        deleteIcon: onDelete != null ? const Icon(Icons.close, size: 16) : null,
        onDeleted: onDelete,
        backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
        side: BorderSide(
          color: AppTheme.primaryColor.withOpacity(0.3),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category, ThemeData theme) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => _searchByCategory(category['name']),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  category['icon'],
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      category['name'],
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${category['count']} كورس',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultsHeader(ThemeData theme) {
    return Container(
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
              'نتائج البحث عن "$_currentQuery"',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          PopupMenuButton<String>(
            onSelected: _changeSortBy,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'relevance',
                child: Text('الأكثر صلة'),
              ),
              const PopupMenuItem(
                value: 'rating',
                child: Text('الأعلى تقييماً'),
              ),
              const PopupMenuItem(
                value: 'price_low',
                child: Text('السعر: من الأقل للأعلى'),
              ),
              const PopupMenuItem(
                value: 'price_high',
                child: Text('السعر: من الأعلى للأقل'),
              ),
              const PopupMenuItem(
                value: 'newest',
                child: Text('الأحدث'),
              ),
            ],
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.5),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _getSortByText(_sortBy),
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_drop_down, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyResults(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد نتائج',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'لم نجد أي كورسات تطابق بحثك عن "$_currentQuery"',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _clearSearch,
              icon: const Icon(Icons.refresh),
              label: const Text('بحث جديد'),
            ),
          ],
        ),
      ),
    );
  }

  void _onSearchChanged(String value) {
    // Implement real-time search suggestions if needed
  }

  void _performSearch(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _currentQuery = query.trim();
      _isLoading = true;
      _searchResults.clear();
    });

    // Add to recent searches
    if (!_recentSearches.contains(query)) {
      _recentSearches.insert(0, query);
      if (_recentSearches.length > 5) {
        _recentSearches.removeLast();
      }
    }

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    // Mock search results
    final results = _generateMockCourses(10);

    setState(() {
      _searchResults = results;
      _isLoading = false;
    });

    _searchController.text = query;
  }

  void _clearSearch() {
    setState(() {
      _currentQuery = '';
      _searchResults.clear();
      _searchController.clear();
    });
  }

  void _removeRecentSearch(String search) {
    setState(() {
      _recentSearches.remove(search);
    });
  }

  void _searchByCategory(String category) {
    _performSearch(category);
  }

  void _changeSortBy(String sortBy) {
    setState(() {
      _sortBy = sortBy;
    });
    // Re-sort results
    _performSearch(_currentQuery);
  }

  String _getSortByText(String sortBy) {
    switch (sortBy) {
      case 'relevance':
        return 'الأكثر صلة';
      case 'rating':
        return 'الأعلى تقييماً';
      case 'price_low':
        return 'السعر ↑';
      case 'price_high':
        return 'السعر ↓';
      case 'newest':
        return 'الأحدث';
      default:
        return 'ترتيب';
    }
  }

  bool _hasActiveFilters() {
    return _selectedCategory.isNotEmpty ||
        _selectedLevel.isNotEmpty ||
        _selectedPriceRange.isNotEmpty ||
        _selectedRating.isNotEmpty;
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildFiltersSheet(),
    );
  }

  Widget _buildFiltersSheet() {
    return StatefulBuilder(
      builder: (context, setModalState) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'تصفية النتائج',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setModalState(() {
                        _selectedCategory = '';
                        _selectedLevel = '';
                        _selectedPriceRange = '';
                        _selectedRating = '';
                      });
                    },
                    child: const Text('مسح الكل'),
                  ),
                ],
              ),

              const Divider(),

              // Filters Content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category Filter
                      _buildFilterSection(
                        'التصنيف',
                        ['البرمجة', 'التصميم', 'التسويق', 'الأعمال'],
                        _selectedCategory,
                        (value) =>
                            setModalState(() => _selectedCategory = value),
                      ),

                      // Level Filter
                      _buildFilterSection(
                        'المستوى',
                        ['مبتدئ', 'متوسط', 'متقدم'],
                        _selectedLevel,
                        (value) => setModalState(() => _selectedLevel = value),
                      ),

                      // Price Filter
                      _buildFilterSection(
                        'السعر',
                        [
                          'مجاني',
                          'أقل من 100 ر.س',
                          '100-500 ر.س',
                          'أكثر من 500 ر.س'
                        ],
                        _selectedPriceRange,
                        (value) =>
                            setModalState(() => _selectedPriceRange = value),
                      ),

                      // Rating Filter
                      _buildFilterSection(
                        'التقييم',
                        ['4.5 نجوم فأكثر', '4 نجوم فأكثر', '3 نجوم فأكثر'],
                        _selectedRating,
                        (value) => setModalState(() => _selectedRating = value),
                      ),
                    ],
                  ),
                ),
              ),

              // Apply Button
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _applyFilters();
                  },
                  child: const Text('تطبيق التصفية'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterSection(
    String title,
    List<String> options,
    String selectedValue,
    Function(String) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ...options.map((option) {
          return RadioListTile<String>(
            title: Text(option),
            value: option,
            groupValue: selectedValue,
            onChanged: (value) => onChanged(value ?? ''),
            contentPadding: EdgeInsets.zero,
          );
        }),
        const SizedBox(height: 16),
      ],
    );
  }

  void _applyFilters() {
    // Apply filters and refresh search results
    _performSearch(_currentQuery);
  }

  void _navigateToCourse(Course course) {
    Navigator.pushNamed(
      context,
      '/student/course-details',
      arguments: course,
    );
  }

  List<Course> _generateMockCourses(int count) {
    return List.generate(count, (index) {
      return Course(
        id: 'course_$index',
        title: 'كورس تطوير التطبيقات ${index + 1}',
        description: 'وصف الكورس رقم ${index + 1}',
        thumbnail:
            'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=300&h=200&fit=crop',
        price: (100 + (index * 50)).toDouble(),
        discountPrice: index % 3 == 0 ? (80 + (index * 40)).toDouble() : null,
        rating: 4.0 + (index % 10) * 0.1,
        reviewsCount: 50 + (index * 10),
        enrolledCount: 100 + (index * 20),
        duration: 120 + (index * 30),
        lessonsCount: 10 + (index * 2),
        level: CourseLevel.values[index % 3],
        category: 'البرمجة',
        tags: ['Flutter', 'Dart', 'Mobile'],
        instructorId: 'instructor_$index',
        instructorName: 'المدرب ${index + 1}',
        instructorAvatar:
            'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=50&h=50&fit=crop&crop=face',
        status: CourseStatus.published,
        createdAt: DateTime.now().subtract(Duration(days: index * 10)),
        updatedAt: DateTime.now().subtract(Duration(days: index * 5)),
      );
    });
  }
}


