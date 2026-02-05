import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:mentor_mesh_hub/app/controllers/api_controller.dart';
import 'package:mentor_mesh_hub/app/controllers/auth_controller.dart';
import 'package:mentor_mesh_hub/app/data/constants/constants.dart';
import 'package:mentor_mesh_hub/app/modules/landing_page/role_based_landing.dart';
import 'package:mentor_mesh_hub/app/modules/widgets/buttons/buttons.dart';

class ShareCourseSheet extends StatefulWidget {
  final String courseId;
  const ShareCourseSheet({required this.courseId, super.key});

  @override
  State<ShareCourseSheet> createState() => _ShareCourseSheetState();
}

class _ShareCourseSheetState extends State<ShareCourseSheet> {
  final ApiController apiController = Get.find<ApiController>();
  final AuthController authController = Get.find<AuthController>();
  bool _isLoading = true;
  bool _isSharing = false;
  List<Map<String, dynamic>> _students = [];
  final Set<int> _selectedStudentIds = {};

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load recent students (all students who enrolled in teacher's courses)
      await apiController.loadRecentStudents(days: 365); // Get all students from past year
      final recentStudents = apiController.recentStudents;
      
      // Extract unique students
      final studentMap = <int, Map<String, dynamic>>{};
      for (final enrollment in recentStudents) {
        final student = enrollment['student'] as Map<String, dynamic>?;
        if (student != null) {
          final studentId = student['id'] as int?;
          if (studentId != null && !studentMap.containsKey(studentId)) {
            studentMap[studentId] = student;
          }
        }
      }
      
      setState(() {
        _students = studentMap.values.toList();
        _isLoading = false;
      });
    } on Exception catch (e) {
      setState(() {
        _isLoading = false;
      });
      Get.snackbar(
        'Error',
        'Failed to load students: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _navigateToHome() {
    // Navigate back to home by clearing navigation stack and going to landing page
    Get.until((route) => route.isFirst);
    // If we're not on the landing page, navigate to it
    if (Get.currentRoute != '/') {
      Get.offAll<void>(() => const RoleBasedLandingPage());
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode(BuildContext context) =>
        Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(AppSpacing.twentyVertical),
          child: CustomIconButton(
            onTap: () {
              Navigator.of(context).pop();
              _navigateToHome();
            },
            color: AppColors.kWhite.withValues(alpha: (0.15 * 255).round().toDouble()),
            iconColor: AppColors.kWhite,
            icon: AppAssets.kArrowBackIos,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          decoration: BoxDecoration(
            color: isDarkMode(context) ? AppColors.kSecondary : AppColors.kWhite,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(30.r),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 40.h),
              Text('Share Course', style: AppTypography.kBold24),
              SizedBox(height: 8.h),
              Text(
                'Select students to share this course with',
                style: AppTypography.kLight16,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30.h),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.all(40.0),
                  child: CircularProgressIndicator(),
                )
              else if (_students.isEmpty)
                Padding(
                  padding: EdgeInsets.all(40.h),
                  child: Column(
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 64.sp,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'No students found',
                        style: AppTypography.kLight16.copyWith(color: Colors.grey),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Students will appear here once they enroll in your courses',
                        style: AppTypography.kLight14.copyWith(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              else
                SizedBox(
                  height: 200.h,
                  child: ListView.builder(
                    itemCount: _students.length,
                    itemBuilder: (context, index) {
                      final student = _students[index];
                      final studentId = student['id'] as int?;
                      final studentName = student['name'] as String? ?? 'Unknown';
                      final profileImage = student['profileImage'] as String?;
                      final isSelected = studentId != null && _selectedStudentIds.contains(studentId);

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: profileImage != null && profileImage.isNotEmpty
                              ? NetworkImage(profileImage)
                              : null,
                          child: profileImage == null || profileImage.isEmpty
                              ? Text(
                                  studentName.isNotEmpty ? studentName[0].toUpperCase() : '?',
                                  style: AppTypography.kBold16,
                                )
                              : null,
                        ),
                        title: Text(studentName, style: AppTypography.kBold16),
                        trailing: Checkbox(
                          value: isSelected,
                          onChanged: studentId != null
                              ? (value) {
                                  setState(() {
                                    if (value ?? false) {
                                      _selectedStudentIds.add(studentId);
                                    } else {
                                      _selectedStudentIds.remove(studentId);
                                    }
                                  });
                                }
                              : null,
                        ),
                      );
                    },
                  ),
                ),
              SizedBox(height: 30.h),
              if (_selectedStudentIds.isEmpty)
                PrimaryButton(
                  onTap: () {
                    Navigator.of(context).pop();
                    _navigateToHome();
                  },
                  text: 'Done',
                )
              else
                Column(
                  children: [
                    PrimaryButton(
                      onTap: () async {
                        // Share course with selected students
                        if (!mounted) return;
                        
                        setState(() {
                          _isSharing = true;
                        });

                        final studentIds = _selectedStudentIds.toList();
                        final success = await apiController.shareCourse(
                          courseId: widget.courseId,
                          studentIds: studentIds,
                        );

                        if (!mounted) return;
                        
                        setState(() {
                          _isSharing = false;
                        });

                        if (success) {
                          Get.snackbar(
                            'Course Shared',
                            'Course shared with ${studentIds.length} student(s). They have been automatically enrolled.',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.green,
                            colorText: Colors.white,
                            duration: const Duration(seconds: 2),
                          );
                          if (mounted && context.mounted) {
                            Navigator.of(context).pop();
                            _navigateToHome();
                          }
                        } else {
                          Get.snackbar(
                            'Failed to Share',
                            apiController.errorMessage.value.isNotEmpty
                                ? apiController.errorMessage.value
                                : 'Could not share course. Please try again.',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                        }
                      },
                      text: _isSharing
                          ? 'Sharing...'
                          : 'Share (${_selectedStudentIds.length})',
                    ),
                    SizedBox(height: 12.h),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _navigateToHome();
                        },
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          side: const BorderSide(color: AppColors.kPrimary),
                        ),
                        child: Text(
                          'Skip',
                          style: AppTypography.kBold16.copyWith(color: AppColors.kPrimary),
                        ),
                      ),
                    ),
                  ],
                ),
              SizedBox(height: AppSpacing.twentyVertical),
            ],
          ),
        ),
      ],
    );
  }
}
