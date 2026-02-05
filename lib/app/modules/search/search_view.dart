import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mentor_mesh_hub/app/controllers/api_controller.dart';
import 'package:mentor_mesh_hub/app/data/constants/constants.dart';
import 'package:mentor_mesh_hub/app/models/category.dart';
import 'package:mentor_mesh_hub/app/models/course.dart';
import 'package:mentor_mesh_hub/app/modules/auth/components/custom_chips.dart';
import 'package:mentor_mesh_hub/app/modules/home/components/course_card.dart';
import 'package:mentor_mesh_hub/app/modules/home/components/search_field.dart';
import 'package:mentor_mesh_hub/app/modules/search/components/filter_sheet.dart';
import 'package:mentor_mesh_hub/app/modules/widgets/containers/primary_container.dart';
import 'package:mentor_mesh_hub/app/modules/widgets/widgets.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  late final ApiController apiController;
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String? _selectedCategoryId;
  int? _selectedChipIndex;

  @override
  void initState() {
    super.initState();
    apiController = Get.isRegistered<ApiController>()
        ? Get.find<ApiController>()
        : Get.put(ApiController());
    if (apiController.courses.isEmpty) {
      apiController.loadCourses();
    }
    _searchController.addListener(() {
      setState(() {
        _query = _searchController.text.trim();
        if (_query.isEmpty) {
          _selectedCategoryId = null;
          _selectedChipIndex = null;
        }
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool isDarkMode(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  List<Course> _filteredCourses(List<Course> courses) {
    final lowerQuery = _query.toLowerCase();
    return courses.where((course) {
      final matchesQuery = _query.isEmpty ||
          [
            course.name,
            course.shortDescription ?? '',
            course.description,
            course.category?.name ?? '',
          ]
              .whereType<String>()
              .any((field) => field.toLowerCase().contains(lowerQuery));

      final matchesCategory = _selectedCategoryId == null ||
          (course.categoryId ?? course.category?.id) == _selectedCategoryId;

      return matchesQuery && matchesCategory;
    }).toList();
  }

  void _onCategorySelected(Category category, int index) {
    setState(() {
      if (_selectedChipIndex == index) {
        _selectedChipIndex = null;
        _selectedCategoryId = null;
      } else {
        _selectedChipIndex = index;
        _selectedCategoryId = category.id;
        _searchController.text = category.name;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomBackAppBar(
        leadingCallback: () {
          Get.back<void>();
        },
        iconColor: isDarkMode(context)
            ? Colors.black
            : AppColors.kPrimary.withValues(alpha: 0.15),
        title: Text(
          'Search',
          style: AppTypography.kBold20.copyWith(color: AppColors.kSecondary),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10.h),
              Row(
                children: [
                  Expanded(
                    child: SearchField(
                      controller: _searchController,
                      isEnabled: true,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  CustomIconButton(
                    size: 50.h,
                    color: isDarkMode(context)
                        ? Colors.black
                        : AppColors.kPrimary.withValues(alpha: 0.151),
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
              SizedBox(height: 40.h),
              Row(
                children: [
                  Text('Popular Categories', style: AppTypography.kBold18),
                  const Spacer(),
                ],
              ),
              SizedBox(height: AppSpacing.tenVertical),
              Obx(
                () => Wrap(
                  spacing: 15.w,
                  runSpacing: 20.h,
                  alignment: WrapAlignment.spaceBetween,
                  children: apiController.categories.take(6).map((category) {
                    final index =
                        apiController.categories.indexOf(category);
                    return CustomChips(
                      onTap: () => _onCategorySelected(category, index),
                      index: index,
                      category: category,
                      isSelected: _selectedChipIndex == index,
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 40.h),
              Row(
                children: [
                  Text('Courses', style: AppTypography.kBold18),
                  const Spacer(),
                  if (_query.isNotEmpty || _selectedCategoryId != null)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _query = '';
                          _selectedCategoryId = null;
                          _selectedChipIndex = null;
                          _searchController.clear();
                        });
                      },
                      child: const Text('Clear filters'),
                    ),
                ],
              ),
              SizedBox(height: AppSpacing.tenVertical),
              Obx(() {
                final courses = apiController.courses;
                final filtered = _filteredCourses(courses);

                if (apiController.isLoading.value && courses.isEmpty) {
                  return SizedBox(
                    height: 200.h,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (filtered.isEmpty) {
                  return PrimaryContainer(
                    padding: EdgeInsets.all(20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('No courses found', style: AppTypography.kBold16),
                        SizedBox(height: 8.h),
                        Text(
                          'Try a different keyword or category.',
                          style: AppTypography.kLight14,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  itemCount: filtered.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  separatorBuilder: (_, __) => SizedBox(height: 20.h),
                  itemBuilder: (context, index) {
                    return SizedBox(
                      height: 280.h,
                      child: CourseCard(course: filtered[index]),
                    );
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
