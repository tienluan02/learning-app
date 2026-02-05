import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:mentor_mesh_hub/app/controllers/auth_controller.dart';
import 'package:mentor_mesh_hub/app/data/constants/constants.dart';
import 'package:mentor_mesh_hub/app/modules/auth/components/auth_field.dart';
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
  final GlobalKey<ShakeWidgetState> _shakeKey = GlobalKey<ShakeWidgetState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthController authController = Get.find<AuthController>();
  String selectedRole = 'student'; // Default role

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Name is required';
                  }
                  return null;
                },
              ),
              SizedBox(height: AppSpacing.thirtyVertical),
              AuthField(
                controller: _emailController,
                hintText: 'Enter Email',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Email is required';
                  }
                  if (!GetUtils.isEmail(value.trim())) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              SizedBox(height: AppSpacing.thirtyVertical),
              AuthField(
                controller: _passwordController,
                hintText: 'Enter Password',
                isPassword: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password is required';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              SizedBox(height: AppSpacing.twentyVertical),
              
              // Role Selection with Animated Cards
              FadeInUp(
                duration: const Duration(milliseconds: 1000),
                child: Text(
                  'Choose Your Role',
                  style: AppTypography.kBold16,
                ),
              ),
              SizedBox(height: 30.h),
              FadeInRight(
                duration: const Duration(milliseconds: 1000),
                child: SizedBox(
                  height: 270.h,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        child: UserTypeCard(
                          onTap: () {
                            setState(() {
                              selectedRole = 'teacher';
                            });
                          },
                          isSelected: selectedRole == 'teacher',
                          image: AppAssets.kTeacher,
                          text: 'Teacher',
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: UserTypeCard(
                          onTap: () {
                            setState(() {
                              selectedRole = 'student';
                            });
                          },
                          isSelected: selectedRole == 'student',
                          image: AppAssets.kStudent,
                          text: 'Student',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.twentyVertical),
              ShakeWidget(
                key: _shakeKey,
                shakeOffset: 10.0,
                shakeDuration: const Duration(milliseconds: 500),
                child: Obx(() => PrimaryButton(
                  onTap: () {
                    if (_formKey.currentState!.validate()) {
                      authController.register(
                        name: _nameController.text.trim(),
                        email: _emailController.text.trim(),
                        password: _passwordController.text,
                        role: selectedRole,
                      ).then((success) {
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
                      });
                    } else {
                      _shakeKey.currentState?.shake();
                    }
                  },
                  text: authController.isLoading.value ? 'Creating Account...' : 'Create Account',
                )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UserTypeCard extends StatelessWidget {
  final VoidCallback onTap;
  final String text;
  final bool isSelected;
  final String image;

  const UserTypeCard({
    required this.onTap,
    required this.isSelected,
    required this.text,
    required this.image,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedButton(
        onTap: onTap,
        child: Container(
          width: 160.w,
          height: 270.h,
          padding: EdgeInsets.all(12.w),
          alignment: Alignment.topCenter,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.r),
            color: isSelected ? AppColors.kPrimary : AppColors.kWhite,
            boxShadow: [AppColors.defaultShadow],
          ),
          child: Column(
            children: [
              Text(
                text,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? AppColors.kWhite : AppColors.kSecondary,
                ),
              ),
              const Spacer(),
              Image.asset(
                image,
                width: 120.w,
                height: 120.h,
                fit: BoxFit.contain,
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
