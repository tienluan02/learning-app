import 'package:mentor_mesh_hub/app/data/constants/constants.dart';
import 'package:mentor_mesh_hub/app/models/category.dart';
import 'package:mentor_mesh_hub/app/models/course.dart';
import 'package:mentor_mesh_hub/app/modules/auth/components/custom_chips.dart';
import 'package:mentor_mesh_hub/app/modules/home/components/course_card.dart';
import 'package:mentor_mesh_hub/app/modules/home/components/search_field.dart';
import 'package:mentor_mesh_hub/app/modules/search/components/filter_sheet.dart';
import 'package:mentor_mesh_hub/app/modules/widgets/widgets.dart';
import 'package:mentor_mesh_hub/app/controllers/api_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class SearchView extends StatelessWidget {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    final ApiController apiController = Get.find<ApiController>();
    bool isDarkMode(BuildContext context) =>
        Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: CustomBackAppBar(
        leadingCallback: () {
          Get.back<void>();
        },
        iconColor: isDarkMode(context)
            ? Colors.black
            : AppColors.kPrimary.withOpacity(0.15),
        title: Text(
          'Search',
          style: AppTypography.kBold20.copyWith(color: AppColors.kSecondary),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 10.h),
              Row(
                children: [
                  Expanded(
                    child: SearchField(
                      controller: TextEditingController(),
                      isEnabled: true,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  CustomIconButton(
                    size: 50.h,
                    color: isDarkMode(context)
                        ? Colors.black
                        : AppColors.kPrimary.withOpacity(0.151),
                    onTap: () {
                      showModalBottomSheet<void>(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                        builder: (context) {
                          return const FilterSheet();
                        },
                      );
                    },
                    icon: AppAssets.kFilter,
                  ),
                ],
              ),
              SizedBox(height: 60.h),
              Row(
                children: [
                  Text('Popular Categories', style: AppTypography.kBold18),
                  const Spacer(),
                  CustomTextButton(
                    onPressed: () {},
                    text: 'See All',
                    color: AppColors.kSecondary.withOpacity(0.3),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.tenVertical),
              Obx(() => Wrap(
                spacing: 15.w,
                runSpacing: 20.h,
                alignment: WrapAlignment.spaceBetween,
                children: apiController.categories.take(4).map(
                  (category) => CustomChips(
                    onTap: () {},
                    index: apiController.categories.indexOf(category),
                    category: category,
                    isSelected: false,
                  ),
                ).toList(),
              )),
              SizedBox(height: 47.h),
              Row(
                children: [
                  Text('Courses', style: AppTypography.kBold18),
                  const Spacer(),
                  CustomTextButton(
                    onPressed: () {},
                    text: 'See All',
                    color: AppColors.kSecondary.withOpacity(0.29),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.tenVertical),
              Obx(() => SizedBox(
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
              )),
            ],
          ),
        ),
      ),
    );
  }
}
