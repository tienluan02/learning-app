import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mentor_mesh_hub/app/controllers/api_controller.dart';
import 'package:mentor_mesh_hub/app/controllers/auth_controller.dart';
import 'package:mentor_mesh_hub/app/data/constants/constants.dart';
import 'package:mentor_mesh_hub/app/models/course.dart';
import 'package:mentor_mesh_hub/app/modules/course_detail/components/course_body_info.dart';
import 'package:mentor_mesh_hub/app/modules/course_detail/course_lessons_view.dart';
import 'package:mentor_mesh_hub/app/modules/course_detail/project_view.dart';
import 'package:mentor_mesh_hub/app/modules/course_detail/reviews_view.dart';
import 'package:mentor_mesh_hub/app/modules/home/components/flexible_header.dart';

class CourseDetailView extends StatefulWidget {
  final Course course;
  const CourseDetailView({required this.course, super.key});

  @override
  State<CourseDetailView> createState() => _CourseDetailViewState();
}

class _CourseDetailViewState extends State<CourseDetailView> {
  @override
  void initState() {
    super.initState();
    // Load enrolled courses to check enrollment status
    final apiController = Get.isRegistered<ApiController>()
        ? Get.find<ApiController>()
        : Get.put(ApiController());
    apiController.loadMyCourses();
  }

  @override
  Widget build(BuildContext context) {
    final course = widget.course;
    final lessons = course.lessons;
    
    // Check if current user is the course instructor
    final authController = Get.isRegistered<AuthController>()
        ? Get.find<AuthController>()
        : Get.put(AuthController());
    final currentUser = authController.currentUser.value;
    final currentUserId = currentUser?.id;
    final currentUserIdString = currentUserId?.toString();
    
    // Check if user is teacher by role
    final userIsTeacher = authController.isTeacher;
    
    // Check if user owns the course
    final ownsCourse = (course.owner?.id.toString() == currentUserIdString) ||
        (course.instructorId?.toString() == currentUserIdString);
    
    // User can upload if they are a teacher AND own the course
    final isTeacher = userIsTeacher && ownsCourse;
    
    // Parse course ID to int
    int? courseId;
    try {
      courseId = int.parse(course.id);
    } on FormatException {
      // If parsing fails, courseId will be null
      courseId = null;
    }
    
    return DefaultTabController(
      length: 3, // Removed Videos tab
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            FlexibleHeader(course: course),
            SliverToBoxAdapter(
              child: CourseBodyInfo(course: course),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _TabBarHeaderDelegate(
                tabBar: TabBar(
                  indicatorSize: TabBarIndicatorSize.label,
                  indicatorWeight: 3.h,
                  indicatorPadding: EdgeInsets.only(top: 8.h),
                  labelPadding: EdgeInsets.only(top: 12.h),
                  labelStyle: AppTypography.kBold18,
                  unselectedLabelStyle: AppTypography.kLight16,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: AppColors.kAccent1,
                  ),
                  tabs: const [
                    Tab(text: 'Lessons'),
                    Tab(text: 'Reviews'),
                    Tab(text: 'Projects'),
                  ],
                ),
              ),
            ),
          ],
          body: TabBarView(
            children: [
              CourseLessonsView(
                lesson: lessons,
                courseId: courseId,
                isTeacher: isTeacher,
              ),
              ReviewsView(course: course),
              const ProjectView(),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabBarHeaderDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  
  @override
  double get maxExtent {
    final height = tabBar.preferredSize.height;
    return height;
  }

  @override
  double get minExtent {
    final height = tabBar.preferredSize.height;
    return height;
  }
  
  _TabBarHeaderDelegate({required this.tabBar});

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    bool isDarkMode(BuildContext context) =>
        Theme.of(context).brightness == Brightness.dark;

    return ColoredBox(
      color: isDarkMode(context) ? AppColors.kSecondary : Colors.white,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_TabBarHeaderDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar;
  }
}
