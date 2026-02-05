import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mentor_mesh_hub/app/models/onboarding.dart';

class OnboardingCard extends StatelessWidget {
  final Onboarding onboarding;
  const OnboardingCard({
    required this.onboarding,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FadeInDown(
          duration: const Duration(milliseconds: 500),
          child: Text(
            onboarding.title,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: 10.h),
        FadeInUp(
          duration: const Duration(milliseconds: 500),
          child: Text(
            onboarding.description,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
