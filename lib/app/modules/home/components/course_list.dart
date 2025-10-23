import 'package:mentor_mesh_hub/app/data/constants/constants.dart';
import 'package:mentor_mesh_hub/app/models/course.dart';
import 'package:mentor_mesh_hub/app/modules/home/components/course_card.dart';
import 'package:mentor_mesh_hub/app/modules/widgets/widgets.dart';
import 'package:mentor_mesh_hub/app/controllers/api_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class CourseList extends StatelessWidget {
  const CourseList({super.key});

  @override
  Widget build(BuildContext context) {
    final ApiController apiController = Get.find<ApiController>();
    
    return Column(
      children: [
        Row(
          children: [
            Text('Trending Courses', style: AppTypography.kBold18),
            const Spacer(),
            CustomTextButton(
              onPressed: () {
                apiController.loadCourses();
              },
              text: 'Refresh',
              color: AppColors.kSecondary.withOpacity(0.3),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.twentyVertical),
        Obx(() {
          if (apiController.isLoading.value) {
            return SizedBox(
              height: 280.h,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          
          if (apiController.courses.isEmpty) {
            return SizedBox(
              height: 280.h,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.school_outlined,
                      size: 48.sp,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'No courses available',
                      style: AppTypography.kLight16.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Check your connection or try again',
                      style: AppTypography.kLight14.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          
          return SizedBox(
            height: 280.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              itemBuilder: (context, index) {
                return CourseCard(
                  course: apiController.courses[index],
                );
              },
              separatorBuilder: (context, index) => SizedBox(width: 30.w),
              itemCount: apiController.courses.length,
            ),
          );
        }),
      ],
    );
  }
}
