import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mentor_mesh_hub/app/controllers/api_controller.dart';
import 'package:mentor_mesh_hub/app/controllers/auth_controller.dart';
import 'package:mentor_mesh_hub/app/data/constants/constants.dart';
import 'package:mentor_mesh_hub/app/models/course.dart';
import 'package:mentor_mesh_hub/app/models/course_video.dart';
import 'package:mentor_mesh_hub/app/modules/home/components/course_owner_card.dart';
import 'package:mentor_mesh_hub/app/modules/payment/payment_view.dart';
import 'package:mentor_mesh_hub/app/modules/widgets/buttons/primary_button.dart';
import 'package:mentor_mesh_hub/app/modules/widgets/custom_painter/price_tag.dart';
import 'package:mentor_mesh_hub/app/services/api_service.dart';

class CourseBodyInfo extends StatefulWidget {
  final Course course;
  const CourseBodyInfo({required this.course, super.key});

  @override
  State<CourseBodyInfo> createState() => _CourseBodyInfoState();
}

class _CourseBodyInfoState extends State<CourseBodyInfo> {
  List<CourseVideo> _videos = [];

  @override
  void initState() {
    super.initState();
    _loadVideos();
  }

  Future<void> _loadVideos() async {
    int? courseId;
    try {
      courseId = int.parse(widget.course.id);
    } on FormatException {
      return;
    }

    try {
      final response = await ApiService.getCourseVideos(courseId!);
      if (response['success'] == true && mounted) {
        final videosData = response['data']['videos'] as List;
        setState(() {
          _videos = videosData
              .map((v) => CourseVideo.fromJson(v as Map<String, dynamic>))
              .toList();
        });
      }
    } on Exception {
      // Silently fail - videos are optional
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate total lesson count (lessons + videos)
    final lessonCount = widget.course.lessons.length + _videos.length;
    
    // Calculate total duration from lessons and videos
    var totalDurationSeconds = 0;
    
    // Add lesson durations (assuming duration is in minutes, convert to seconds)
    for (final lesson in widget.course.lessons) {
      // Parse duration string like "10:30" or "5 min"
      final durationStr = lesson.duration;
      if (durationStr.contains(':')) {
        final parts = durationStr.split(':');
        if (parts.length == 2) {
          final minutes = int.tryParse(parts[0]) ?? 0;
          final seconds = int.tryParse(parts[1]) ?? 0;
          totalDurationSeconds += minutes * 60 + seconds;
        }
      } else {
        // Try to parse as minutes
        final minutes = int.tryParse(durationStr.replaceAll(RegExp('[^0-9]'), '')) ?? 0;
        totalDurationSeconds += minutes * 60;
      }
    }
    
    // Add video durations (already in seconds)
    for (final video in _videos) {
      totalDurationSeconds += video.duration;
    }
    
    // Convert to hours (for display)
    final durationHours = (totalDurationSeconds / 3600).toStringAsFixed(1);
    final rating = widget.course.averageRating ?? 0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.course.name,
            style: AppTypography.kBold24,
          ),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 10.w,
            runSpacing: 10.h,
            children: [
              _InfoChip(
                icon: Icons.play_circle_outline,
                label: '$lessonCount lessons',
              ),
              _InfoChip(
                icon: Icons.schedule,
                label: '${durationHours}h total',
              ),
              _InfoChip(
                icon: Icons.star_rounded,
                label: '${rating.toStringAsFixed(1)} rating',
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              const PriceTag(),
              SizedBox(width: 12.w),
              Text(
                '\$${widget.course.price.toStringAsFixed(2)}',
                style: AppTypography.kBold24,
              ),
              if (widget.course.originalPrice != null &&
                  widget.course.originalPrice != 0 &&
                  widget.course.originalPrice != widget.course.price)
                Padding(
                  padding: EdgeInsets.only(left: 8.w),
                  child: Text(
                    '\$${widget.course.originalPrice?.toStringAsFixed(2)}',
                    style: AppTypography.kLight14.copyWith(
                      decoration: TextDecoration.lineThrough,
                      color: AppColors.kGrey,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 20.h),
          Text(
            widget.course.shortDescription ?? widget.course.description,
            style: AppTypography.kLight16,
          ),
          if ((widget.course.tags ?? []).isNotEmpty) ...[
            SizedBox(height: 16.h),
            Wrap(
              spacing: 10.w,
              runSpacing: 10.h,
              children: widget.course.tags!
                  .map(
                    (tag) => Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.kPrimary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                      child: Text(
                        tag,
                        style: AppTypography.kLight14,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
          SizedBox(height: 24.h),
          CourseOwnerCard(user: widget.course.owner),
          SizedBox(height: 24.h),
          Obx(() {
            final apiController = Get.isRegistered<ApiController>()
                ? Get.find<ApiController>()
                : Get.put(ApiController());
            final authController = Get.isRegistered<AuthController>()
                ? Get.find<AuthController>()
                : Get.put(AuthController());
            final isEnrolled = apiController.isEnrolledInCourse(widget.course.id);
            final isLoading = apiController.isLoading.value;
            final isStudent = authController.currentUser.value?.role == 'student';

            if (!isStudent) {
              return const SizedBox.shrink();
            }

            if (isEnrolled) {
              return PrimaryButton(
                text: 'Start Learning',
                onTap: () {
                  // Navigate to course content
                  Get.snackbar(
                    'Course Access',
                    'You are enrolled in this course',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
              );
            }

            final isFree = widget.course.price == 0;
            return PrimaryButton(
              text: isLoading 
                  ? 'Processing...' 
                  : isFree 
                      ? 'Enroll for Free' 
                      : 'Buy Now - \$${widget.course.price.toStringAsFixed(2)}',
              onTap: isLoading
                  ? () {} // No-op when loading
                  : () async {
                      // Navigate to payment view
                      final result = await Get.to<Map<String, dynamic>?>(
                        () => PaymentView(course: widget.course),
                      );
                      
                      // If payment/enrollment successful, refresh data
                      if (result != null && result['success'] == true) {
                        // Refresh enrolled courses
                        await apiController.loadMyCourses(force: true);
                        // Refresh user metrics
                        await apiController.loadUserMetrics(force: true);
                        
                        Get.snackbar(
                          'Success',
                          isFree 
                              ? 'Successfully enrolled in course!'
                              : 'Payment successful! You are now enrolled.',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.green,
                          colorText: Colors.white,
                        );
                      }
                    },
            );
          }),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 12.w,
        vertical: 6.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.kPrimary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16.sp,
            color: AppColors.kPrimary,
          ),
          SizedBox(width: 6.w),
          Text(
            label,
            style: AppTypography.kLight14,
          ),
        ],
      ),
    );
  }
}
