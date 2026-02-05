import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:mentor_mesh_hub/app/controllers/api_controller.dart';
import 'package:mentor_mesh_hub/app/controllers/auth_controller.dart';
import 'package:mentor_mesh_hub/app/data/constants/constants.dart';
import 'package:mentor_mesh_hub/app/modules/create_course/components/create_lessons.dart';
import 'package:mentor_mesh_hub/app/modules/create_course/components/publish_course_view.dart';
import 'package:mentor_mesh_hub/app/modules/create_course/course_published.dart';
import 'package:mentor_mesh_hub/app/modules/profile/components/profile_image_card.dart';
import 'package:mentor_mesh_hub/app/modules/widgets/buttons/buttons.dart';

class CreateCourseView extends StatefulWidget {
  const CreateCourseView({super.key});

  @override
  State<CreateCourseView> createState() => _CreateCourseViewState();
}

class _CreateCourseViewState extends State<CreateCourseView> {
  bool _createLessons = true;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _shortDescriptionController = TextEditingController();
  late final ApiController apiController;
  late final AuthController authController;
  int? _selectedCategoryId;
  String _selectedLevel = 'beginner';
  double? _price;
  String? _courseImage;
  Uint8List? _pickedImageBytes;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    apiController = Get.isRegistered<ApiController>()
        ? Get.find<ApiController>()
        : Get.put(ApiController());
    authController = Get.isRegistered<AuthController>()
        ? Get.find<AuthController>()
        : Get.put(AuthController());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _shortDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create a new course '),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Get.back<void>();
          },
        ),
      ),
      body: Container(
        margin: EdgeInsets.only(top: 20.h),
        decoration: BoxDecoration(
          color: AppColors.kPrimary.withValues(alpha: (0.081 * 255).round().toDouble()),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(40.r),
          ),
        ),
        child: ListView(
          padding: EdgeInsets.only(bottom: 20.h),
          children: [
            Padding(
              padding: EdgeInsets.all(AppSpacing.twentyVertical),
              child: Row(
                children: [
                  ProfileImageCard(size: 50.h),
                  Expanded(
                    child: TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        hintText: 'Course Title',
                        labelText: 'Title',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.twentyVertical),
              child: TextField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Full course description...',
                  labelText: 'Description *',
                ),
              ),
            ),
            SizedBox(height: 12.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.twentyVertical),
              child: TextField(
                controller: _shortDescriptionController,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: 'Brief summary (optional)',
                  labelText: 'Short Description',
                ),
              ),
            ),
            SizedBox(height: AppSpacing.tenVertical),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 500),
              firstChild: CreateLessons(
                onCategorySelected: (categoryId) {
                  setState(() {
                    _selectedCategoryId = categoryId;
                  });
                },
                selectedCategoryId: _selectedCategoryId,
                onImagePicked: (imageBytes) {
                  setState(() {
                    _pickedImageBytes = imageBytes;
                    _courseImage = 'data:image/png;base64,${base64Encode(imageBytes)}';
                  });
                },
                pickedImageBytes: _pickedImageBytes,
                selectedLevel: _selectedLevel,
                onLevelSelected: (level) {
                  setState(() {
                    _selectedLevel = level;
                  });
                },
              ),
              secondChild: PublishCourseView(
                onPriceChanged: (price) {
                  setState(() {
                    _price = price;
                  });
                },
                price: _price,
                courseImage: _pickedImageBytes,
              ),
              crossFadeState: _createLessons
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: PrimaryButton(
                onTap: _isSubmitting ? () {} : _handleContinue,
                text: _isSubmitting
                    ? 'Please wait...'
                    : (_createLessons ? 'Continue' : 'Publish'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleContinue() async {
    if (_createLessons) {
      // Validate required fields
      final title = _titleController.text.trim();
      if (title.isEmpty) {
        Get.snackbar(
          'Title Required',
          'Please enter a course title',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Validate title has at least one uppercase letter
      if (!title.contains(RegExp('[A-Z]'))) {
        Get.snackbar(
          'Invalid Title',
          'Title must contain at least one uppercase letter',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      if (_descriptionController.text.trim().isEmpty) {
        Get.snackbar(
          'Description Required',
          'Please enter a course description',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      if (_selectedCategoryId == null) {
        Get.snackbar(
          'Category Required',
          'Please select a category for your course',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      if (_pickedImageBytes == null) {
        Get.snackbar(
          'Image Required',
          'Please select a course image',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      setState(() {
        _createLessons = false;
      });
    } else {
      // Validate price
      final price = _price;
      if (price == null || price < 0) {
        Get.snackbar(
          'Price Required',
          'Please enter a valid price',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Ensure image is provided
      final courseImage = _courseImage;
      if (courseImage == null || courseImage.isEmpty) {
        Get.snackbar(
          'Image Required',
          'Please select a course image',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Create the course
      setState(() {
        _isSubmitting = true;
      });

      final shortDesc = _shortDescriptionController.text.trim();
      final selectedCategoryId = _selectedCategoryId;
      if (selectedCategoryId == null) {
        Get.snackbar(
          'Category Required',
          'Please select a category',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        setState(() {
          _isSubmitting = false;
        });
        return;
      }

      final courseId = await apiController.createCourse(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        shortDescription: shortDesc.isNotEmpty ? shortDesc : null,
        categoryId: selectedCategoryId,
        price: price,
        image: courseImage,
        level: _selectedLevel,
        isPublished: true,
      );

      setState(() {
        _isSubmitting = false;
      });

      if (courseId != null) {
        await Get.to<void>(() => CoursePublished(courseId: courseId));
      } else {
        Get.snackbar(
          'Failed to Create Course',
          apiController.errorMessage.value.isNotEmpty
              ? apiController.errorMessage.value
              : 'Could not create course. Please try again.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }
}
