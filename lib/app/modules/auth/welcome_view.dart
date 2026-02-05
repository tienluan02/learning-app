import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mentor_mesh_hub/app/data/constants/constants.dart';
import 'package:mentor_mesh_hub/app/modules/auth/components/custom_social_button.dart';
import 'package:mentor_mesh_hub/app/modules/auth/components/divider_with_text.dart';
import 'package:mentor_mesh_hub/app/modules/widgets/widgets.dart';
import 'package:mentor_mesh_hub/app/routes/app_routes.dart';

class WelcomeView extends StatelessWidget {
  const WelcomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const WaveCard(),
          const Spacer(),
          FadeInUp(
            duration: const Duration(milliseconds: 500),
            child: Text(
              'Join a community of teachers & students',
              style: AppTypography.kBold32,
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 30.h),
          // Google login disabled
          // FadeInUp(
          //   duration: const Duration(milliseconds: 700),
          //   child: Padding(
          //     padding:
          //         EdgeInsets.symmetric(horizontal: AppSpacing.twentyHorizontal),
          //     child: CustomSocialButton(
          //       onTap: () {
          //         final authController = Get.find<AuthController>();
          //         authController.loginWithGoogle().then((success) {
          //           if (success) {
          //             Get.offAllNamed<dynamic>(AppRoutes.getLandingPageRoute());
          //           } else if (authController.errorMessage.isNotEmpty) {
          //             Get.snackbar(
          //               'Login Failed',
          //               authController.errorMessage.value,
          //               snackPosition: SnackPosition.TOP,
          //               backgroundColor: Colors.red,
          //               colorText: Colors.white,
          //             );
          //           }
          //         });
          //       },
          //       icon: AppAssets.kGoogle,
          //       text: 'Join using Google',
          //     ),
          //   ),
          // ),
          SizedBox(height: AppSpacing.thirtyVertical),
          FadeInUp(
            duration: const Duration(milliseconds: 801),
            child: const DividerWithText(),
          ),
          SizedBox(height: AppSpacing.thirtyVertical),
          FadeInUp(
            duration: const Duration(milliseconds: 900),
            child: Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: AppSpacing.twentyHorizontal),
              child: CustomSocialButton(
                onTap: () {
                  Get.toNamed<dynamic>(AppRoutes.getSignUpRoute());
                },
                icon: AppAssets.kMail,
                text: 'Join using Email',
              ),
            ),
          ),
          SizedBox(height: AppSpacing.tenVertical),
          FadeInUp(
            duration: const Duration(milliseconds: 1000),
            child: CustomTextButton(
              onPressed: () {
                Get.toNamed<dynamic>(AppRoutes.getSignInRoute());
              },
              text: 'Sign In instead',
            ),
          ),
          SizedBox(height: AppSpacing.twentyVertical),
        ],
      ),
    );
  }
}
