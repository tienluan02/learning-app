import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:mentor_mesh_hub/app/controllers/api_controller.dart';
import 'package:mentor_mesh_hub/app/data/constants/constants.dart';
import 'package:mentor_mesh_hub/app/modules/auth/components/custom_chips.dart';

class CreateLessons extends StatefulWidget {
  final void Function(int)? onCategorySelected;
  final int? selectedCategoryId;
  final void Function(Uint8List)? onImagePicked;
  final Uint8List? pickedImageBytes;
  final String selectedLevel;
  final void Function(String)? onLevelSelected;

  const CreateLessons({
    super.key,
    this.onCategorySelected,
    this.selectedCategoryId,
    this.onImagePicked,
    this.pickedImageBytes,
    this.selectedLevel = 'beginner',
    this.onLevelSelected,
  });

  @override
  State<CreateLessons> createState() => _CreateLessonsState();
}

class _CreateLessonsState extends State<CreateLessons> {
  final ApiController apiController =
      Get.isRegistered<ApiController>() ? Get.find<ApiController>() : Get.put(ApiController());
  final ImagePicker _picker = ImagePicker();
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.selectedCategoryId;
    // Load categories if not already loaded
    if (apiController.categories.isEmpty) {
      apiController.loadCategories().ignore();
    }
  }

  Future<void> _pickImage() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        if (widget.onImagePicked != null) {
          widget.onImagePicked!(bytes);
        }
      }
    } on Exception catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Course Image Picker
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.twentyVertical),
          child: GestureDetector(
            onTap: _pickImage,
            child: Container(
              height: 150.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: widget.pickedImageBytes != null
                    ? Colors.transparent
                    : AppColors.kPrimary.withValues(alpha: (0.15 * 255).round().toDouble()),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: AppColors.kPrimary,
                  width: 2,
                ),
                image: widget.pickedImageBytes != null
                    ? DecorationImage(
                        image: MemoryImage(widget.pickedImageBytes!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: widget.pickedImageBytes == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate,
                          color: AppColors.kPrimary,
                          size: 48.sp,
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Add Course Image',
                          style: AppTypography.kBold16.copyWith(
                            color: AppColors.kPrimary,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Tap to select from gallery',
                          style: AppTypography.kLight14.copyWith(
                            color: AppColors.kPrimary.withValues(alpha: (0.7 * 255).round().toDouble()),
                          ),
                        ),
                      ],
                    )
                  : null,
            ),
          ),
        ),
        SizedBox(height: 20.h),
        
        // Level Selection
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.twentyVertical),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Course Level',
                style: AppTypography.kLight16,
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(
                    child: _buildLevelChip('beginner', 'Beginner'),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildLevelChip('intermediate', 'Intermediate'),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildLevelChip('advanced', 'Advanced'),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 30.h),
        
        // Category Selection
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.twentyVertical),
          child: Text(
            'Choose or type category',
            style: AppTypography.kLight16,
          ),
        ),
        SizedBox(height: AppSpacing.twentyVertical),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.twentyVertical),
          child: Obx(() {
            final categories = apiController.categories;
            if (categories.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            return Wrap(
              spacing: 15.w,
              runSpacing: 20.h,
              children: categories.asMap().entries.map((entry) {
                final index = entry.key;
                final category = entry.value;
                final categoryId = int.tryParse(category.id);
                final isSelected = categoryId != null && categoryId == _selectedCategoryId;

                return CustomChips(
                  onTap: () {
                    setState(() {
                      _selectedCategoryId = categoryId;
                    });
                    if (widget.onCategorySelected != null && categoryId != null) {
                      widget.onCategorySelected!(categoryId);
                    }
                  },
                  index: index,
                  category: category,
                  isSelected: isSelected,
                );
              }).toList(),
            );
          }),
        ),
        SizedBox(height: 20.h),
      ],
    );
  }

  Widget _buildLevelChip(String level, String label) {
    final isSelected = widget.selectedLevel == level;
    const primaryColor = AppColors.kPrimary;
    final primaryAlpha10 = primaryColor.withValues(alpha: (0.1 * 255).round().toDouble());
    final primaryAlpha30 = primaryColor.withValues(alpha: (0.3 * 255).round().toDouble());
    
    return GestureDetector(
      onTap: () {
        widget.onLevelSelected?.call(level);
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : primaryAlpha10,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isSelected ? primaryColor : primaryAlpha30,
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTypography.kBold14.copyWith(
              color: isSelected ? Colors.white : primaryColor,
            ),
          ),
        ),
      ),
    );
  }
}
