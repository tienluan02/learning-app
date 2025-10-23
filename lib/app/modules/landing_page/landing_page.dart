import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:mentor_mesh_hub/app/controllers/api_controller.dart';
import 'package:mentor_mesh_hub/app/data/constants/constants.dart';
import 'package:mentor_mesh_hub/app/services/api_service.dart';
import 'package:mentor_mesh_hub/app/modules/activity/activity_view.dart';
import 'package:mentor_mesh_hub/app/modules/auth/sign_in_view.dart';
import 'package:mentor_mesh_hub/app/modules/auth/sign_up_view.dart';
import 'package:mentor_mesh_hub/app/modules/create_course/create_course_view.dart';
import 'package:mentor_mesh_hub/app/modules/home/home_view.dart';
import 'package:mentor_mesh_hub/app/modules/my_courses/my_courses_view.dart';
import 'package:mentor_mesh_hub/app/modules/profile/profile_view.dart';
import 'package:mentor_mesh_hub/app/modules/widgets/widgets.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final ApiController apiController = Get.put(ApiController());
  int _currentIndex = 0;
  
  // Get pages based on authentication status
  List<Widget> get _pages {
    if (ApiService.isLoggedIn) {
      return [
        const HomeView(),
        const MyCoursesView(),
        const CreateCourseView(),
        const ActivityView(),
        const ProfileView(),
      ];
    } else {
      return [
        const WelcomeScreen(),
        const WelcomeScreen(),
        const WelcomeScreen(),
        const WelcomeScreen(),
        const WelcomeScreen(),
      ];
    }
  }
  
  @override
  void initState() {
    super.initState();
    // Check authentication status when the page loads
    apiController.loadToken();
  }
  
  @override
  Widget build(BuildContext context) {
    bool isDarkMode(BuildContext context) =>
        Theme.of(context).brightness == Brightness.dark;

    return Obx(() => Scaffold(
      extendBody: true,
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        height: 113.h,
        padding: EdgeInsets.only(top: 5.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusForty),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.kPrimary.withValues(alpha: 0.2),
              blurRadius: 7,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusForty),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            selectedItemColor: Colors.white,
            onTap: (index) {
              // If not logged in and trying to access restricted pages, show welcome
              if (!ApiService.isLoggedIn && index > 0) {
                setState(() {
                  _currentIndex = 0; // Always go to welcome screen
                });
                return;
              }
              
              setState(() {
                _currentIndex = index;
              });
            },
            items: [
              BottomNavigationBarItem(
                icon: Icon(
                  ApiService.isLoggedIn 
                    ? Icons.home_outlined 
                    : Icons.home_outlined,
                  color: Colors.grey,
                ),
                label: ApiService.isLoggedIn ? 'Home' : 'Welcome',
                activeIcon: Icon(
                  ApiService.isLoggedIn 
                    ? Icons.home 
                    : Icons.home,
                  color: isDarkMode(context) ? Colors.white : Colors.grey,
                ),
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.my_library_books_outlined,
                  color: ApiService.isLoggedIn 
                    ? Colors.grey 
                    : Colors.grey.withValues(alpha: 0.5),
                ),
                label: 'My Courses',
                activeIcon: Icon(
                  Icons.my_library_books,
                  color: isDarkMode(context) ? Colors.white : Colors.grey,
                ),
              ),
              BottomNavigationBarItem(
                icon: Container(
                  height: 40.h,
                  width: 40.w,
                  decoration: BoxDecoration(
                    color: ApiService.isLoggedIn 
                      ? AppColors.kPrimary 
                      : AppColors.kPrimary.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add,
                    color: AppColors.kWhite,
                  ),
                ),
                label: 'Create',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.notifications_none_rounded,
                  color: ApiService.isLoggedIn 
                    ? Colors.grey 
                    : Colors.grey.withValues(alpha: 0.5),
                ),
                label: 'Activity',
                activeIcon: Icon(
                  Icons.notifications,
                  color: isDarkMode(context) ? Colors.white : Colors.grey,
                ),
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.person_outline, 
                  color: ApiService.isLoggedIn 
                    ? Colors.grey 
                    : Colors.grey.withValues(alpha: 0.5),
                ),
                label: 'Profile',
                activeIcon: Icon(
                  Icons.person_outline,
                  color: isDarkMode(context) ? Colors.white : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = AppColors.kPrimary;
    const primaryOpacity = 0.1;
    const borderRadius = 20.0;
    const buttonBorderRadius = 10.0;
    
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            children: [
              SizedBox(height: 50.h),
              // Logo or App Name
              Text(
                'MentorMesh',
                style: AppTypography.kBold32.copyWith(
                  color: primaryColor,
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                'Learn. Teach. Grow.',
                style: AppTypography.kLight16,
              ),
              SizedBox(height: 80.h),
              
              // Hero Image or Illustration
              Container(
                height: 200.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: primaryOpacity),
                  borderRadius: BorderRadius.circular(borderRadius.r),
                ),
                child: Icon(
                  Icons.school,
                  size: 80.sp,
                  color: primaryColor,
                ),
              ),
              SizedBox(height: 60.h),
              
              // Welcome Text
              Text(
                'Welcome to MentorMesh',
                style: AppTypography.kBold24,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20.h),
              Text(
                'Join thousands of students and teachers in our learning community. Create courses, learn new skills, and grow together.',
                style: AppTypography.kLight16,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 60.h),
              
              // Action Buttons
              PrimaryButton(
                onTap: () {
                  Get.to(() => const SignUpView());
                },
                text: 'Get Started',
              ),
              SizedBox(height: 20.h),
              GestureDetector(
                onTap: () {
                  Get.to(() => const SignInView());
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 15.h),
                  decoration: BoxDecoration(
                    border: Border.all(color: primaryColor),
                    borderRadius: BorderRadius.circular(buttonBorderRadius.r),
                  ),
                  child: Text(
                    'Sign In',
                    style: AppTypography.kBold16.copyWith(
                      color: primaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }
}