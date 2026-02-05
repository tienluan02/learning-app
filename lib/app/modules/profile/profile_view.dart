import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:mentor_mesh_hub/app/controllers/api_controller.dart';
import 'package:mentor_mesh_hub/app/controllers/auth_controller.dart';
import 'package:mentor_mesh_hub/app/data/constants/constants.dart';
import 'package:mentor_mesh_hub/app/modules/home/components/course_card.dart';
import 'package:mentor_mesh_hub/app/modules/home/components/custom_menu_card.dart';
import 'package:mentor_mesh_hub/app/modules/message/message_view.dart';
import 'package:mentor_mesh_hub/app/modules/profile/components/profile_image_card.dart';
import 'package:mentor_mesh_hub/app/modules/widgets/widgets.dart';
import 'package:mentor_mesh_hub/app/routes/app_routes.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final AuthController authController = Get.find<AuthController>();
  final ApiController apiController = Get.isRegistered<ApiController>()
      ? Get.find<ApiController>()
      : Get.put(ApiController());
  bool showAllFeaturedCourses = false;

  @override
  void initState() {
    super.initState();
    apiController.loadUserMetrics();
    apiController.loadFeaturedCourses();
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode(BuildContext context) =>
        Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode(context) ? Colors.black : AppColors.kPrimary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: [
          CustomIconButton(
            onTap: () {
              Get.toNamed<dynamic>(AppRoutes.getSettingPageRoute());
            },
            icon: AppAssets.kMoreVert,
            iconColor: AppColors.kWhite,
            color: AppColors.kWhite.withValues(alpha: 0.15),
          ),
          SizedBox(width: AppSpacing.twentyHorizontal),
        ],
      ),
      body: ScrollConfiguration(
        behavior: const ScrollBehavior().copyWith(overscroll: false),
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: isDarkMode(context)
                      ? AppColors.kSecondary
                      : AppColors.kWhite,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(AppSpacing.radiusThirty),
                  ),
                ),
                margin: EdgeInsets.only(top: 40.h),
                child: Column(
                  children: [
                    SizedBox(height: 65.h),
                    Obx(() {
                      final user = authController.currentUser.value;
                      final subtitle =
                          ((user?.bio ?? '').isNotEmpty) ? user!.bio : (user?.role ?? 'Learner');
                      return Column(
                        children: [
                    Text(
                            user?.name ?? 'Mentor',
                      style: AppTypography.kBold32,
                    ),
                    Text(
                            subtitle,
                      style: AppTypography.kLight14,
                    ),
                        ],
                      );
                    }),
                    SizedBox(height: 30.h),
                    _buildMetricsSection(),
                    SizedBox(height: 30.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomMenuCard(
                          isSelected: false,
                          icon: AppAssets.kMessage,
                          onTap: () {
                            Get.to<dynamic>(() => const MessageView());
                          },
                          title: 'Message',
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.thirtyVertical),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20.h),
                      decoration: BoxDecoration(
                        color: isDarkMode(context)
                            ? AppColors.kPrimary.withValues(alpha: 0.08)
                            : AppColors.kPrimary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(AppSpacing.radiusThirty),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: AppSpacing.thirtyVertical),
                          Text(
                            'About',
                            style: AppTypography.kBold18,
                          ),
                          Obx(() {
                            final user = authController.currentUser.value;
                            final about = (user?.bio ?? '').isNotEmpty
                                ? user!.bio
                                : 'Tell students a bit about yourself to personalize your profile.';
                            return Text(
                              about,
                            style: AppTypography.kLight14,
                            );
                          }),
                          SizedBox(height: AppSpacing.fortyVertical),
                          Row(
                            children: [
                              Text(
                                'Featured Courses',
                                style: AppTypography.kBold18,
                              ),
                              const Spacer(),
                              Obx(() {
                                final featuredCourses = apiController.featuredCourses;
                                if (featuredCourses.length > 1) {
                                  return IconButton(
                                    onPressed: () {
                                      setState(() {
                                        showAllFeaturedCourses = !showAllFeaturedCourses;
                                      });
                                    },
                                    icon: Icon(
                                      showAllFeaturedCourses
                                          ? Icons.keyboard_arrow_down
                                          : Icons.keyboard_arrow_right,
                                      color: AppColors.kPrimary,
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              }),
                            ],
                          ),
                          SizedBox(height: 10.h),
                          Obx(() {
                            final isLoading = apiController.isFeaturedLoading.value;
                            final featuredCourses = apiController.featuredCourses;

                            if (isLoading && featuredCourses.isEmpty) {
                              return SizedBox(
                                height: 280.h,
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }

                            if (featuredCourses.isEmpty) {
                              return SizedBox(
                                height: 160.h,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.star_outline,
                                        size: 48.sp,
                                        color: Colors.grey,
                                      ),
                                      SizedBox(height: 12.h),
                                      Text(
                                        'No featured courses yet',
                                        style: AppTypography.kBold16,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            return SizedBox(
                            height: 280.h,
                            child: ListView.separated(
                              clipBehavior: Clip.none,
                              separatorBuilder: (context, index) => SizedBox(
                                width: 30.w,
                              ),
                              scrollDirection: Axis.horizontal,
                                itemCount: showAllFeaturedCourses
                                    ? featuredCourses.length
                                    : (featuredCourses.isNotEmpty ? 1 : 0),
                              itemBuilder: (context, index) {
                                return CourseCard(
                                    course: featuredCourses[index],
                                );
                              },
                            ),
                            );
                          }),
                          SizedBox(height: 90.h),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Obx(() {
                final image = authController.currentUser.value?.profileImage;
                return ProfileImageCard(image: image);
              }),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildMetricsSection() {
    return Obx(() {
      final user = authController.currentUser.value;
      final metrics = apiController.userMetrics.value;
      final isTeacher = user?.isTeacher ?? false;

      if (isTeacher) {
        final teacherMetrics = metrics?.teacher;
        return Column(
          children: [
            Row(
              children: [
                _ProfileMetricCard(
                  label: 'Courses Created',
                  value: _formatCount(teacherMetrics?.coursesCreated ?? user?.totalCoursesCreated),
                ),
                SizedBox(width: 12.w),
                _ProfileMetricCard(
                  label: 'Total Purchases',
                  value: _formatCount(teacherMetrics?.totalPurchases),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                _ProfileMetricCard(
                  label: 'Total Students',
                  value: _formatCount(teacherMetrics?.totalStudents),
                ),
                SizedBox(width: 12.w),
                _ProfileMetricCard(
                  label: 'Avg Rating',
                  value: _formatRating(teacherMetrics?.averageRating ?? user?.averageRating),
                ),
              ],
            ),
          ],
        );
      }

      final studentMetrics = metrics?.student;
      return Column(
        children: [
          Row(
            children: [
              _ProfileMetricCard(
                label: 'Courses Bought',
                value: _formatCount(
                  studentMetrics?.coursesBought ?? user?.totalCoursesEnrolled,
                ),
              ),
              SizedBox(width: 12.w),
              _ProfileMetricCard(
                label: 'Study Time',
                value: _formatStudyTime(studentMetrics?.studyMinutes ?? user?.totalHoursWatched ?? 0),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              _ProfileMetricCard(
                label: 'Lessons Completed',
                value: _formatCount(studentMetrics?.lessonsCompleted ?? user?.totalLessonsCompleted),
              ),
              SizedBox(width: 12.w),
              _ProfileMetricCard(
                label: 'Hours Watched',
                value: _formatStudyTime(studentMetrics?.totalHoursWatched ?? user?.totalHoursWatched ?? 0),
              ),
            ],
          ),
        ],
      );
    });
  }

  String _formatCount(int? value) {
    if (value == null) {
      return '--';
    }
    return value.toString();
  }

  String _formatRating(double? value) {
    if (value == null) {
      return '--';
    }
    return value.toStringAsFixed(1);
  }

  String _formatStudyTime(int minutes) {
    if (minutes <= 0) {
      return '0m';
    }
    final hours = minutes ~/ 60;
    final remaining = minutes % 60;
    if (hours == 0) {
      return '${remaining}m';
    }
    if (remaining == 0) {
      return '${hours}h';
    }
    return '${hours}h ${remaining}m';
  }
}

class _ProfileMetricCard extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileMetricCard({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 18.w,
          vertical: 16.h,
        ),
        decoration: BoxDecoration(
          color: AppColors.kPrimary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(18.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: AppTypography.kBold20,
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: AppTypography.kLight14,
            ),
          ],
        ),
      ),
    );
  }
}
