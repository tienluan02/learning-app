import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mentor_mesh_hub/app/data/constants/constants.dart';
import 'package:mentor_mesh_hub/app/models/course.dart';
import 'package:mentor_mesh_hub/app/modules/home/components/course_card.dart';
import 'package:mentor_mesh_hub/app/modules/widgets/containers/primary_container.dart';

/// Pure UI widget for displaying a horizontal list of courses.
///
/// The parent (e.g. `HomeView`) is responsible for fetching data and
/// passing in the current list, loading state, and whether to show all.
class CourseList extends StatelessWidget {
  final List<Course> courses;
  final bool showAll;
  final bool isLoading;
  final bool showStudentCount;

  const CourseList({
    required this.courses,
    required this.showAll,
    required this.isLoading,
    this.showStudentCount = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoading && courses.isEmpty) {
      return SizedBox(
        height: 280.h,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (courses.isEmpty && !isLoading) {
      return PrimaryContainer(
        height: 160.h,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.school_outlined,
                size: 48.sp,
                color: Colors.grey,
              ),
              SizedBox(height: 12.h),
              Text(
                'No trending courses yet',
                style: AppTypography.kBold16,
              ),
              SizedBox(height: 6.h),
              Text(
                'Try refreshing or explore the catalog to add more interests.',
                style: AppTypography.kLight14,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // When showAll is true, show all courses; otherwise show only 1
    final itemCount =
        showAll && courses.isNotEmpty ? courses.length : 1;

    return SizedBox(
      height: 280.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemBuilder: (context, index) {
          if (index >= courses.length) {
            return const SizedBox.shrink();
          }
          final course = courses[index];
          return Stack(
            clipBehavior: Clip.none,
            children: [
              CourseCard(course: course),
              if (showStudentCount && (course.totalEnrollments != null))
                Positioned(
                  top: 8.h,
                  right: -6.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7 * 255),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      '${course.totalEnrollments} students',
                      style: AppTypography.kLight14.copyWith(
                        color: Colors.white,
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
        separatorBuilder: (context, index) => SizedBox(width: 30.w),
        itemCount: itemCount,
      ),
    );
  }
}
