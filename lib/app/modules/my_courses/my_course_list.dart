import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mentor_mesh_hub/app/controllers/api_controller.dart';
import 'package:mentor_mesh_hub/app/controllers/auth_controller.dart';
import 'package:mentor_mesh_hub/app/data/constants/constants.dart';
import 'package:mentor_mesh_hub/app/modules/my_courses/components/empty_card.dart';
import 'package:mentor_mesh_hub/app/modules/my_courses/components/my_course_card.dart';

class MyCourseList extends StatefulWidget {
  const MyCourseList({super.key});

  @override
  State<MyCourseList> createState() => _MyCourseListState();
}

class _MyCourseListState extends State<MyCourseList> {
  late final ApiController apiController;
  late final AuthController authController;

  @override
  void initState() {
    super.initState();
    authController = Get.isRegistered<AuthController>()
        ? Get.find<AuthController>()
        : Get.put(AuthController());
    apiController = Get.isRegistered<ApiController>()
        ? Get.find<ApiController>()
        : Get.put(ApiController());
    _loadCourses();
  }

  Future<void> _loadCourses({bool force = false}) async {
    if (authController.isTeacher) {
      final teacherId = authController.currentUser.value?.id.toString();
      await apiController.loadCourses(limit: 50, teacherId: teacherId);
    } else {
      await apiController.loadMyCourses(force: force);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isTeacher = authController.isTeacher;
      final teacherId = authController.currentUser.value?.id.toString();
      final isLoading = isTeacher
          ? apiController.isLoading.value
          : apiController.isMyCoursesLoading.value;
      final courses = isTeacher
          ? apiController.courses
              .where((c) =>
                  (c.owner != null && c.owner!.id.toString() == teacherId) ||
                  (c.instructorId != null &&
                      c.instructorId.toString() == teacherId))
              .toList()
          : apiController.enrolledCourses;

      if (isLoading && courses.isEmpty) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      if (courses.isEmpty) {
        return RefreshIndicator(
          onRefresh: () async {
            await _loadCourses(force: true);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: const Center(child: EmptyCard(
                message: 'No courses yet',
                subtitle: 'Create a course to see it here',
              )),
            ),
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () async {
          await _loadCourses(force: true);
        },
        child: GridView.builder(
          itemCount: courses.length,
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 150 / 215,
            crossAxisSpacing: AppSpacing.twentyHorizontal,
            mainAxisSpacing: AppSpacing.twentyVertical,
          ),
          itemBuilder: (context, index) {
            return MyCourseCard(
              course: courses[index],
            );
          },
        ),
      );
    });
  }
}
