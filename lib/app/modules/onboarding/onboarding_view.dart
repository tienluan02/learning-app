import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mentor_mesh_hub/app/data/constants/constants.dart';
import 'package:mentor_mesh_hub/app/models/onboarding.dart';
import 'package:mentor_mesh_hub/app/modules/onboarding/components/custom_indicator.dart';
import 'package:mentor_mesh_hub/app/modules/onboarding/components/onboarding_card.dart';
import 'package:mentor_mesh_hub/app/modules/widgets/widgets.dart';
import 'package:mentor_mesh_hub/app/routes/app_routes.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({
    super.key,
  });

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode(BuildContext context) =>
        Theme.of(context).brightness == Brightness.dark;
    
    SystemChrome.setSystemUIOverlayStyle(
      isDarkMode(context) ? defaultOverlay : customOverlay,
    );
    
    final currentOnboarding = onboardingList[_currentIndex];
    final isLastPage = _currentIndex == (onboardingList.length - 1);
    
    return Scaffold(
      backgroundColor: AppColors.kWhite,
      extendBodyBehindAppBar: true,
      appBar: _currentIndex > 0
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leadingWidth: 70.w,
              leading: Padding(
                padding: EdgeInsets.all(7.h),
                child: CustomIconButton(
                  onTap: () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.ease,
                    );
                  },
                  icon: AppAssets.kArrowBackIos,
                ),
              ),
            )
          : null,
      body: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              const WaveCard(),
              Positioned(
                top: 100.h,
                child: Image.asset(currentOnboarding.image),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: onboardingList.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return OnboardingCard(
                  onboarding: onboardingList[index],
                );
              },
            ),
          ),
          CustomIndicator(
            controller: _pageController,
            dotsLength: onboardingList.length,
          ),
          SizedBox(height: 30.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: PrimaryButton(
              onTap: () {
                if (isLastPage) {
                  // Navigate to welcome screen
                  Get.offAllNamed<dynamic>(AppRoutes.getWelcomeRoute());
                } else {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.ease,
                  );
                }
              },
              text: isLastPage ? 'Get Started' : 'Continue',
            ),
          ),
          CustomTextButton(
            onPressed: () {
              if (isLastPage) {
                // Navigate to sign in
                Get.offAllNamed<dynamic>(AppRoutes.getSignInRoute());
              } else {
                // Skip to welcome screen
                Get.offAllNamed<dynamic>(AppRoutes.getWelcomeRoute());
              }
            },
            text: isLastPage ? 'Sign in instead' : 'Skip',
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }
}
