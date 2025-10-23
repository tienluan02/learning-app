import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:mentor_mesh_hub/app/controllers/auth_controller.dart';
import 'package:mentor_mesh_hub/app/data/constants/constants.dart';
import 'package:mentor_mesh_hub/app/modules/auth/components/auth_field.dart';
import 'package:mentor_mesh_hub/app/modules/auth/components/custom_social_button.dart';
import 'package:mentor_mesh_hub/app/modules/auth/components/divider_with_text.dart';
import 'package:mentor_mesh_hub/app/modules/widgets/animations/shake_animation.dart';
import 'package:mentor_mesh_hub/app/modules/widgets/widgets.dart';
import 'package:mentor_mesh_hub/app/routes/app_routes.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _shakeKey = GlobalKey<ShakeWidgetState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthController authController = Get.find<AuthController>();
  String selectedRole = 'student'; // Default role

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              SizedBox(height: 100.h),
              Center(
                child: Text(
                  'Create Account',
                  style: AppTypography.kBold32,
                  textAlign: TextAlign.center,
                ),
              ),
              Center(
                child: Text(
                  'Join MentorMesh and start your learning journey',
                  style: AppTypography.kLight16,
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 50.h),
              AuthField(
                controller: _nameController,
                hintText: 'Enter Full Name',
              ),
              SizedBox(height: AppSpacing.thirtyVertical),
              AuthField(
                controller: _emailController,
                hintText: 'Enter Email',
              ),
              SizedBox(height: AppSpacing.thirtyVertical),
              AuthField(
                controller: _passwordController,
                hintText: 'Enter Password',
              ),
              SizedBox(height: AppSpacing.twentyVertical),
              
              // Role Selection
              Text(
                'Choose Your Role',
                style: AppTypography.kBold16,
              ),
              SizedBox(height: 15.h),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedRole = 'student';
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 20.w),
                        decoration: BoxDecoration(
                          color: selectedRole == 'student' 
                            ? AppColors.kPrimary.withValues(alpha: 0.1)
                            : Colors.grey.withValues(alpha: 0.1),
                          border: Border.all(
                            color: selectedRole == 'student' 
                              ? AppColors.kPrimary 
                              : Colors.grey,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.school,
                              color: selectedRole == 'student' 
                                ? AppColors.kPrimary 
                                : Colors.grey,
                              size: 30.sp,
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              'Student',
                              style: AppTypography.kBold14.copyWith(
                                color: selectedRole == 'student' 
                                  ? AppColors.kPrimary 
                                  : Colors.grey,
                              ),
                            ),
                            Text(
                              'Learn courses',
                              style: AppTypography.kLight14.copyWith(
                                color: selectedRole == 'student' 
                                  ? AppColors.kPrimary 
                                  : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 15.w),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedRole = 'teacher';
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 20.w),
                        decoration: BoxDecoration(
                          color: selectedRole == 'teacher' 
                            ? AppColors.kPrimary.withValues(alpha: 0.1)
                            : Colors.grey.withValues(alpha: 0.1),
                          border: Border.all(
                            color: selectedRole == 'teacher' 
                              ? AppColors.kPrimary 
                              : Colors.grey,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.person_outline,
                              color: selectedRole == 'teacher' 
                                ? AppColors.kPrimary 
                                : Colors.grey,
                              size: 30.sp,
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              'Teacher',
                              style: AppTypography.kBold14.copyWith(
                                color: selectedRole == 'teacher' 
                                  ? AppColors.kPrimary 
                                  : Colors.grey,
                              ),
                            ),
                            Text(
                              'Create courses',
                              style: AppTypography.kLight14.copyWith(
                                color: selectedRole == 'teacher' 
                                  ? AppColors.kPrimary 
                                  : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.twentyVertical),
              ShakeWidget(
                key: _shakeKey,
                shakeOffset: 10.0,
                shakeDuration: const Duration(milliseconds: 500),
                child: Obx(() => PrimaryButton(
                  onTap: () async {
                    if (_nameController.text.isNotEmpty &&
                        _emailController.text.isNotEmpty &&
                        _passwordController.text.isNotEmpty) {
                      final success = await authController.register(
                        name: _nameController.text.trim(),
                        email: _emailController.text.trim(),
                        password: _passwordController.text,
                        role: selectedRole,
                      );
                      
                      if (success) {
                        Get.offAllNamed<dynamic>(AppRoutes.getLandingPageRoute());
                      } else {
                        _shakeKey.currentState?.shake();
                        Get.snackbar(
                          'Registration Failed',
                          authController.errorMessage.value,
                          snackPosition: SnackPosition.TOP,
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                        );
                      }
                    } else {
                      _shakeKey.currentState?.shake();
                    }
                  },
                  text: authController.isLoading.value ? 'Creating Account...' : 'Create Account',
                )),
              ),
              SizedBox(height: AppSpacing.twentyVertical),
              const DividerWithText(),
              SizedBox(height: AppSpacing.twentyVertical),
              CustomSocialButton(
                onTap: () {},
                icon: AppAssets.kFaceBook,
                text: 'Join using Facebook',
                margin: 0,
              ),
              SizedBox(height: AppSpacing.twentyVertical),
              CustomSocialButton(
                onTap: () {},
                icon: AppAssets.kGoogle,
                text: 'Join using Google',
                margin: 0,
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}