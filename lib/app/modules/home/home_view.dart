import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:mentor_mesh_hub/app/controllers/api_controller.dart';
import 'package:mentor_mesh_hub/app/controllers/auth_controller.dart';
import 'package:mentor_mesh_hub/app/data/constants/constants.dart';
import 'package:mentor_mesh_hub/app/modules/create_course/create_course_view.dart';
import 'package:mentor_mesh_hub/app/modules/home/components/best_teachers.dart';
import 'package:mentor_mesh_hub/app/modules/home/components/course_list.dart';
import 'package:mentor_mesh_hub/app/modules/home/components/custom_menu_card.dart';
import 'package:mentor_mesh_hub/app/modules/home/components/learning_summary_card.dart';
import 'package:mentor_mesh_hub/app/modules/home/components/search_field.dart';
import 'package:mentor_mesh_hub/app/modules/schedule/course_schedule.dart';
import 'package:mentor_mesh_hub/app/modules/search/search_view.dart';
import 'package:mentor_mesh_hub/app/modules/statistics/student_statistics_view.dart';
import 'package:mentor_mesh_hub/app/modules/widgets/containers/primary_container.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final ApiController apiController =
      Get.isRegistered<ApiController>() ? Get.find<ApiController>() : Get.put(ApiController());
  final AuthController authController = Get.find<AuthController>();
  bool showAllTrendingCourses = false;
  bool showAllMyCourses = false;
  bool showAllRecentStudents = false;

  @override
  void initState() {
    super.initState();
    // Load data when the page initializes
    apiController
      ..loadTrendingCourses()
      ..loadTeachersOfWeek()
      ..loadCourses(limit: 50)
      ..loadUserMetrics(force: true)
      ..loadRecentStudents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshHome,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10.h),
                Obx(() {
                  final name = authController.currentUser.value?.name ?? 'there';
                  return Text('Hi $name', style: AppTypography.kBold32);
                }),
                Obx(() {
                  final role = authController.currentUser.value?.role ?? 'student';
                  final subtitle =
                      role == 'teacher' ? 'Ready to inspire learners today? ✨' : 'What do you want to do today? ☀️';
                  return Text(
                    subtitle,
                    style: AppTypography.kLight16,
                  );
                }),
                SizedBox(height: AppSpacing.thirtyVertical),
                GestureDetector(
                  onTap: () {
                    Get.to<void>(() => const SearchView());
                  },
                  child: SearchField(
                    controller: TextEditingController(),
                  ),
                ),
                SizedBox(height: 26.h),
                _buildLearningSummary(),
                if ((authController.currentUser.value?.role ?? 'student') == 'teacher') ...[
                  SizedBox(height: 20.h),
                  _buildTeacherQuickAction(),
                  SizedBox(height: 30.h),
                  _buildTeacherCourses(),
                  SizedBox(height: 30.h),
                  _buildRecentStudents(),
                  SizedBox(height: 20.h),
                ],
                SizedBox(height: 60.h),
                Obx(() {
                  final name = authController.currentUser.value?.name ?? 'there';
                  return Text(
                    'Latest on $name',
                    style: AppTypography.kBold18,
                  );
                }),
                SizedBox(height: AppSpacing.twentyVertical),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    CustomMenuCard(
                      isSelected: selectedIndex == 0,
                      onTap: () => handleCardTap(0),
                      icon: AppAssets.kPopular,
                      title: 'Popular',
                    ),
                    CustomMenuCard(
                      isSelected: selectedIndex == 1,
                      onTap: () => handleCardTap(1),
                      icon: AppAssets.kRecords,
                      title: 'Records',
                    ),
                    CustomMenuCard(
                      isSelected: selectedIndex == 2,
                      onTap: () => handleCardTap(2),
                      icon: AppAssets.kStatistics,
                      title: 'Statistics',
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.fiftyVertical),
                Obx(() {
                  final trending = apiController.trendingCourses;
                  final isTrendingLoading =
                      apiController.isTrendingLoading.value;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Trending Courses',
                            style: AppTypography.kBold18,
                          ),
                          const Spacer(),
                          if (trending.isNotEmpty)
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  showAllTrendingCourses =
                                      !showAllTrendingCourses;
                                });
                              },
                              icon: Icon(
                                showAllTrendingCourses
                                    ? Icons.keyboard_arrow_down
                                    : Icons.keyboard_arrow_right,
                                color: AppColors.kPrimary,
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: AppSpacing.twentyVertical),
                      CourseList(
                        courses: trending,
                        showAll: showAllTrendingCourses,
                        isLoading: isTrendingLoading,
                      ),
                    ],
                  );
                }),
                SizedBox(height: 60.h),
                const BestTeachers(),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  int selectedIndex = -1;

  Widget _buildLearningSummary() {
    return Obx(() {
      final userRole = authController.currentUser.value?.role ?? 'student';
      final teacherMetrics = apiController.userMetrics.value?.teacher;
      final studentMetrics = apiController.userMetrics.value?.student;
      final isLoadingMetrics = apiController.isMetricsLoading.value;
      final metricsAny = userRole == 'teacher' ? teacherMetrics : studentMetrics;

      if (isLoadingMetrics && metricsAny == null) {
        return PrimaryContainer(
          padding: EdgeInsets.all(20.h),
          child: SizedBox(
            height: 80.h,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
        );
      }

      if (userRole == 'teacher') {
        final metrics = teacherMetrics;
        final coursesCreated = metrics?.coursesCreated ?? 0;
        final totalStudents = metrics?.totalStudents ?? 0;
        final avgRating = metrics?.averageRating ?? 0.0;

        return PrimaryContainer(
          padding: EdgeInsets.all(20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your teaching summary',
                style: AppTypography.kBold18,
              ),
              SizedBox(height: 12.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _metricTile('Courses', coursesCreated.toString()),
                  _metricTile('Students', totalStudents.toString()),
                ],
              ),
              SizedBox(height: 12.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _metricTile('Rating', avgRating.toStringAsFixed(1)),
                  const SizedBox.shrink(), // Empty space to maintain layout
                ],
              ),
            ],
          ),
        );
      } else {
        final metrics = studentMetrics;
        final coursesBought = metrics?.coursesBought ?? 0;
        final totalLearningHours = metrics?.totalLearningHours ?? 0.0;

        return LearningSummaryCard(
          coursesBought: coursesBought,
          totalLearningHours: totalLearningHours,
          onSwipe: () => apiController.loadUserMetrics(force: true),
        );
      }
    });
  }

  Widget _buildTeacherQuickAction() {
    return PrimaryContainer(
      padding: EdgeInsets.all(16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quick actions',
                style: AppTypography.kBold18,
              ),
              SizedBox(height: 6.h),
              Text(
                'Create a new course for your students',
                style: AppTypography.kLight14.copyWith(color: Colors.grey),
              ),
            ],
          ),
          ElevatedButton.icon(
            onPressed: () {
              Get.to<void>(() => const CreateCourseView());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.kPrimary,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.add),
            label: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Widget _buildTeacherCourses() {
    return Obx(() {
      final currentUser = authController.currentUser.value;
      if (currentUser == null) return const SizedBox.shrink();
      final teacherId = currentUser.id.toString();

      // Filter courses created by this teacher
      final teacherCourses = apiController.courses.where((c) {
        // Check owner ID
        if (c.owner != null) {
          final ownerId = c.owner!.id.toString();
          if (ownerId == teacherId) return true;
        }
        // Check instructor ID
        if (c.instructorId != null && c.instructorId == teacherId) {
          return true;
        }
        return false;
      }).toList();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'My Courses',
                style: AppTypography.kBold18,
              ),
              if (teacherCourses.length > 1)
                TextButton(
                  onPressed: () {
                    setState(() {
                      showAllMyCourses = !showAllMyCourses;
                    });
                  },
                  child: Text(
                    showAllMyCourses ? 'Show less' : 'Show all',
                  ),
                ),
            ],
          ),
          SizedBox(height: 12.h),
          CourseList(
            courses: teacherCourses,
            showAll: showAllMyCourses,
            isLoading: apiController.isLoading.value && teacherCourses.isEmpty,
            showStudentCount: true,
          ),
        ],
      );
    });
  }

  Widget _buildRecentStudents() {
    return Obx(() {
      final students = apiController.recentStudents;
      if (students.isEmpty) {
        return PrimaryContainer(
          padding: EdgeInsets.all(16.h),
          child: Row(
            children: [
              Icon(Icons.people_outline, color: Colors.grey, size: 28.sp),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  'No new students in the past 3 days',
                  style: AppTypography.kLight14,
                ),
              ),
            ],
          ),
        );
      }

      final itemCount =
          showAllRecentStudents ? students.length : (students.isNotEmpty ? 1 : 0);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Recent Students', style: AppTypography.kBold18),
              if (students.length > 1)
                TextButton(
                  onPressed: () {
                    setState(() {
                      showAllRecentStudents = !showAllRecentStudents;
                    });
                  },
                  child: Text(showAllRecentStudents ? 'Show less' : 'Show all'),
                ),
            ],
          ),
          SizedBox(height: 12.h),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: itemCount,
            separatorBuilder: (_, __) => SizedBox(height: 10.h),
            itemBuilder: (context, index) {
              final s = students[index];
              final student = s['student'] as Map<String, dynamic>?;
              final course = s['course'] as Map<String, dynamic>?;
              final enrolledAt = s['enrolledAt']?.toString();
              var timeLabel = '';
              if (enrolledAt != null && enrolledAt.isNotEmpty) {
                final dt = DateTime.tryParse(enrolledAt);
                if (dt != null) {
                  final diff = DateTime.now().difference(dt);
                  if (diff.inDays >= 1) {
                    timeLabel = '${diff.inDays}d ago';
                  } else if (diff.inHours >= 1) {
                    timeLabel = '${diff.inHours}h ago';
                  } else {
                    timeLabel = '${diff.inMinutes}m ago';
                  }
                }
              }
              final profileUrl = (student?['profileImage'] as String?) ?? '';
              final hasProfile = profileUrl.isNotEmpty;
              return PrimaryContainer(
                padding: EdgeInsets.all(12.h),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22.r,
                      backgroundImage: hasProfile ? NetworkImage(profileUrl) : null,
                      child: hasProfile ? null : const Icon(Icons.person_outline),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            student?['name']?.toString() ?? 'Student',
                            style: AppTypography.kBold16,
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Course: ${course?['title'] ?? 'N/A'}',
                            style: AppTypography.kLight14.copyWith(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    if (timeLabel.isNotEmpty)
                      Text(
                        timeLabel,
                        style: AppTypography.kLight14.copyWith(
                          color: Colors.grey,
                          fontSize: 12.sp,
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      );
    });
  }

  Future<void> _refreshHome() async {
    await Future.wait([
      apiController.loadTrendingCourses(force: true),
      apiController.loadTeachersOfWeek(force: true),
      apiController.loadCourses(limit: 50),
      apiController.loadUserMetrics(force: true),
      apiController.loadRecentStudents(),
    ]);
  }

  Widget _metricTile(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: AppTypography.kBold24,
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: AppTypography.kLight14.copyWith(color: Colors.grey),
        ),
      ],
    );
  }

  void handleCardTap(int index) {
    setState(() {
      if (selectedIndex == index) {
        selectedIndex = -1;
      } else {
        selectedIndex = index;
        if (selectedIndex == 0) {
          // Popular - Navigate to course recommendations
          _navigateTo(const SearchView());
        }
        if (selectedIndex == 1) {
          // Records - Navigate to learning schedule
          _navigateTo(const CourseSchedule());
        }
        if (selectedIndex == 2) {
          // Statistics - Navigate to student statistics
          _navigateTo(const StudentStatisticsView());
        }
      }
    });
  }

  void _navigateTo(Widget page) {
    Future.delayed(const Duration(milliseconds: 300), () {
      Get.to<void>(() => page)?.then((_) {
        if (mounted) {
          setState(() {
            selectedIndex = -1;
          });
        }
      });
    });
  }
}