import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:mentor_mesh_hub/app/modules/auth/sign_in_view.dart';
import 'package:mentor_mesh_hub/app/modules/auth/sign_up_view.dart';
import 'package:mentor_mesh_hub/app/modules/auth/welcome_view.dart';
import 'package:mentor_mesh_hub/app/modules/landing_page/role_based_landing.dart';
import 'package:mentor_mesh_hub/app/modules/onboarding/onboarding_view.dart';
import 'package:mentor_mesh_hub/app/modules/profile/settings_view.dart';

class AppRoutes {
  static String onboarding = '/onboarding';
  static String welcome = '/welcome';
  static String signIn = '/sign-in';
  static String signUp = '/sign-up';
  static String landing = '/landing-page';
  static String settings = '/settings';

  static List<GetPage> routes = [
    GetPage<Route<dynamic>>(
      name: landing,
      page: () => const RoleBasedLandingPage(),
    ),
    GetPage<Route<dynamic>>(
      name: onboarding,
      page: () => const OnboardingView(),
    ),
    GetPage<Route<dynamic>>(
      name: welcome,
      page: () => const WelcomeView(),
    ),
    GetPage<Route<dynamic>>(
      name: signIn,
      page: () => const SignInView(),
    ),
    GetPage<Route<dynamic>>(
      name: signUp,
      page: () => const SignUpView(),
    ),
    GetPage<Route<dynamic>>(
      name: settings,
      page: () => const SettingsView(),
    ),
  ];

  static String getOnboardingRoute() => onboarding;
  static String getWelcomeRoute() => welcome;
  static String getSignInRoute() => signIn;
  static String getSignUpRoute() => signUp;
  static String getLandingPageRoute() => landing;
  static String getSettingPageRoute() => settings;
}
