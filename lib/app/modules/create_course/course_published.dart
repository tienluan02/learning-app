import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:mentor_mesh_hub/app/data/constants/constants.dart';
import 'package:mentor_mesh_hub/app/modules/create_course/components/share_course_sheet.dart';
import 'package:mentor_mesh_hub/app/modules/landing_page/role_based_landing.dart';
import 'package:mentor_mesh_hub/app/modules/widgets/buttons/buttons.dart';

class CoursePublished extends StatelessWidget {
  final String courseId;
  const CoursePublished({required this.courseId, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: EdgeInsets.all(7.h),
          child: CustomIconButton(
            color: AppColors.kPrimary.withValues(alpha: (0.08 * 255).round().toDouble()),
            icon: AppAssets.kArrowBackIos,
            onTap: () {
              Get.back<void>();
            },
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(AppSpacing.twentyVertical),
        child: Column(
          children: [
            const Spacer(),
            Text(
              'Congratulations! You have \npublished a new course.',
              style: AppTypography.kBold24,
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            PrimaryButton(
              onTap: () {
                showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(30.r),
                    ),
                  ),
                  builder: (context) {
                    return ShareCourseSheet(courseId: courseId);
                  },
                ).then((_) {
                  // Navigate to home after sheet is closed
                  Get.until((route) => route.isFirst);
                  if (Get.currentRoute != '/') {
                    Get.offAll<void>(() => const RoleBasedLandingPage());
                  }
                });
              },
              text: 'Share',
            ),
            SizedBox(height: 16.h),
            OutlinedButton(
              onPressed: () {
                // Navigate to home without sharing
                Get.until((route) => route.isFirst);
                if (Get.currentRoute != '/') {
                  Get.offAll<void>(() => const RoleBasedLandingPage());
                }
              },
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 32.w),
                side: const BorderSide(color: AppColors.kPrimary),
              ),
              child: Text(
                'Skip',
                style: AppTypography.kBold16.copyWith(color: AppColors.kPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
