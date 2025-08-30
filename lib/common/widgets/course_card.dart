import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/course.dart';
import '../themes/app_theme.dart';

class CourseCard extends StatelessWidget {
  final Course course;
  final VoidCallback? onTap;
  final bool showProgress;
  final double? progress;
  final bool showInstructor;
  final bool showPrice;
  final bool showFavoriteButton;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;
  final Widget? trailing;

  const CourseCard({
    super.key,
    required this.course,
    this.onTap,
    this.showProgress = false,
    this.progress,
    this.showInstructor = true,
    this.showPrice = true,
    this.showFavoriteButton = true,
    this.isFavorite = false,
    this.onFavoriteToggle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: 245, // Increased height to prevent overflow
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Course Thumbnail
              SizedBox(
                height: 120, // Fixed height for thumbnail
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: double.infinity,
                        child: course.thumbnail != null
                            ? CachedNetworkImage(
                                imageUrl: course.thumbnail!,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: Colors.grey.shade200,
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppTheme.primaryColor.withOpacity(0.8),
                                        AppTheme.accentColor.withOpacity(0.8),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.play_circle_outline,
                                      color: Colors.white,
                                      size: 40,
                                    ),
                                  ),
                                ),
                              )
                            : Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppTheme.primaryColor.withOpacity(0.8),
                                      AppTheme.accentColor.withOpacity(0.8),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.play_circle_outline,
                                    color: Colors.white,
                                    size: 40,
                                  ),
                                ),
                              ),
                      ),
                    ),

                    // Course Status Badge
                    Positioned(
                      top: 8,
                      right: 8,
                      child: _buildStatusBadge(context),
                    ),

                    // Course Level Badge
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          course.levelText,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Course Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Course Title
                      Text(
                        course.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 1),

                      // Course Description
                      Text(
                        course.description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                          fontSize: 10,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 2),

                      // Instructor Info
                      if (showInstructor)
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 8,
                              backgroundImage: course.instructorAvatar != null
                                  ? NetworkImage(course.instructorAvatar!)
                                  : null,
                              backgroundColor: AppTheme.primaryColor,
                              child: course.instructorAvatar == null
                                  ? const Icon(
                                      Icons.person,
                                      color: Colors.white,
                                      size: 10,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                course.instructorName,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.8),
                                  fontSize: 10,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (course.rating > 0) ...[
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 10,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                course.rating.toStringAsFixed(1),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 9,
                                ),
                              ),
                            ],
                          ],
                        ),

                      const SizedBox(height: 2),

                      // Course Progress (if applicable)
                      if (showProgress && progress != null) ...[
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 3,
                                child: LinearProgressIndicator(
                                  value: progress! / 100,
                                  backgroundColor: Colors.grey.shade300,
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                    AppTheme.primaryColor,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${progress!.toInt()}%',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w500,
                                fontSize: 9,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                      ],

                      // Bottom spacer to push last row to bottom
                      const Spacer(),

                      // Course Info Row
                      Row(
                        children: [
                          // Duration
                          Icon(
                            Icons.access_time,
                            size: 10,
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            course.formattedDuration,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.8),
                              fontSize: 9,
                            ),
                          ),

                          const SizedBox(width: 8),

                          // Lessons Count
                          Icon(
                            Icons.play_lesson,
                            size: 10,
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${course.lessonsCount} درس',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.8),
                              fontSize: 9,
                            ),
                          ),

                          const Spacer(),

                          // Price or Trailing Widget
                          if (trailing != null)
                            trailing!
                          else if (showPrice)
                            _buildPriceWidget(theme),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    final theme = Theme.of(context);
    Color badgeColor;
    String badgeText;

    switch (course.status) {
      case CourseStatus.published:
        if (course.enrolledCount > 100) {
          badgeColor = AppTheme.accentColor;
          badgeText = 'شائع';
        } else {
          badgeColor = AppTheme.primaryColor;
          badgeText = 'جديد';
        }
        break;
      case CourseStatus.draft:
        badgeColor = AppTheme.warningColor;
        badgeText = 'مسودة';
        break;
      case CourseStatus.archived:
        badgeColor = Colors.grey;
        badgeText = 'مؤرشف';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        badgeText,
        style: theme.textTheme.bodySmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w500,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildPriceWidget(ThemeData theme) {
    if (course.price == 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: AppTheme.successColor,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          'مجاني',
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 10,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (course.hasDiscount) ...[
          Text(
            '${course.price.toInt()} ر.س',
            style: theme.textTheme.bodySmall?.copyWith(
              decoration: TextDecoration.lineThrough,
              color: theme.colorScheme.onSurface.withOpacity(0.5),
              fontSize: 9,
            ),
          ),
          Text(
            '${course.effectivePrice.toInt()} ر.س',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ] else
          Text(
            '${course.price.toInt()} ر.س',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
      ],
    );
  }
}
