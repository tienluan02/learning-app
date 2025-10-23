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

class SignInView extends StatefulWidget {
  const SignInView({super.key});

  @override
  State<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _shakeKey = GlobalKey<ShakeWidgetState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthController authController = Get.find<AuthController>();
  
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
                  'Welcome Back',
                  style: AppTypography.kBold32,
                  textAlign: TextAlign.center,
                ),
              ),
              Center(
                child: Text(
                  'Sign in to unlock exclusive features and personalized content',
                  style: AppTypography.kLight16,
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 50.h),
              AuthField(
                controller: _emailController,
                hintText: 'Enter Email',
              ),
              SizedBox(height: AppSpacing.thirtyVertical),
              AuthField(
                controller: _passwordController,
                hintText: 'Enter Password',
              ),
              Align(
                alignment: Alignment.centerRight,
                child: CustomTextButton(
                  onPressed: () {},
                  text: 'Forget Password?',
                ),
              ),
              SizedBox(height: AppSpacing.twentyVertical),
              ShakeWidget(
                key: _shakeKey,
                shakeOffset: 10.0,
                shakeDuration: const Duration(milliseconds: 500),
                child: Obx(() => PrimaryButton(
                  onTap: () async {
                    if (_emailController.text.isNotEmpty &&
                        _passwordController.text.isNotEmpty) {
                      final success = await authController.login(
                        email: _emailController.text.trim(),
                        password: _passwordController.text,
                      );
                      
                      if (success) {
                        Get.offAllNamed<dynamic>(AppRoutes.getLandingPageRoute());
                      } else {
                        _shakeKey.currentState?.shake();
                        Get.snackbar(
                          'Login Failed',
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
                  text: authController.isLoading.value ? 'Logging in...' : 'Login',
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
            ],
          ),
        ),
      ),
    );
  }
}