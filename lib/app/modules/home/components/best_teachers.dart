import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mentor_mesh_hub/app/controllers/api_controller.dart';
import 'package:mentor_mesh_hub/app/data/constants/constants.dart';
import 'package:mentor_mesh_hub/app/modules/home/components/best_teachers_card.dart';
import 'package:mentor_mesh_hub/app/modules/onboarding/components/custom_indicator.dart';
import 'package:mentor_mesh_hub/app/modules/widgets/containers/primary_container.dart';

class BestTeachers extends StatefulWidget {
  const BestTeachers({super.key});

  @override
  State<BestTeachers> createState() => _BestTeachersState();
}

class _BestTeachersState extends State<BestTeachers> {
  late PageController _pageController;
  late final ApiController apiController;

  @override
  void initState() {
    super.initState();
    apiController = Get.isRegistered<ApiController>()
        ? Get.find<ApiController>()
        : Get.put(ApiController());
    _pageController =
        PageController(initialPage: 1, viewportFraction: 0.57);
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLoading = apiController.isTeachersLoading.value;
      final teachers = apiController.teachersOfWeek;

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: AppSpacing.thirtyVertical),
          Text(
            'Teachers of the Week',
            style: AppTypography.kBold18,
          ),
          SizedBox(height: AppSpacing.twentyVertical),
          if (isLoading && teachers.isEmpty)
            SizedBox(
              height: 220.h,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            )
          else if (teachers.isEmpty)
            PrimaryContainer(
              padding: EdgeInsets.all(20.h),
              child: Column(
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 42.sp,
                    color: AppColors.kSecondary.withValues(alpha: 0.4),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'No teachers to show yet',
                    style: AppTypography.kBold16,
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'Publish a few courses to highlight mentors here.',
                    style: AppTypography.kLight14,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            Column(
              children: [
                SizedBox(
                  height: 260.h,
                  child: PageView.builder(
                    itemCount: teachers.length,
                    clipBehavior: Clip.none,
                    physics: const BouncingScrollPhysics(),
                    controller: _pageController,
                    itemBuilder: (context, index) {
                      return BestTeachersCard(
                        index: index,
                        pageController: _pageController,
                        teacher: teachers[index],
                      );
                    },
                  ),
                ),
                SizedBox(height: 30.h),
                CustomIndicator(
                  controller: _pageController,
                  dotsLength: teachers.length,
                ),
                SizedBox(height: 40.h),
              ],
            ),
        ],
      );
    });
  }
}

