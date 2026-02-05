import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:mentor_mesh_hub/app/controllers/auth_controller.dart';
import 'package:mentor_mesh_hub/app/controllers/theme_controller.dart';
import 'package:mentor_mesh_hub/app/data/constants/constants.dart';
import 'package:mentor_mesh_hub/app/modules/profile/components/profile_image_picker.dart';
import 'package:mentor_mesh_hub/app/modules/profile/components/setting_tile.dart';
import 'package:mentor_mesh_hub/app/modules/widgets/widgets.dart';
import 'package:mentor_mesh_hub/app/routes/app_routes.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  final AuthController authController = Get.find<AuthController>();
  bool isUpdatingProfile = false;
  @override
  Widget build(BuildContext context) {
    bool isDarkMode(BuildContext context) =>
        Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: EdgeInsets.all(8.h),
          child: CustomIconButton(
            color: isDarkMode(context)
                ? Colors.black
                : AppColors.kPrimary.withValues(alpha: 0.14),
            icon: AppAssets.kArrowBackIos,
            onTap: () {
              Get.back<void>();
            },
          ),
        ),
        centerTitle: true,
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          children: [
            Obx(() {
              final user = authController.currentUser.value;
              return SettingTile(
              icon: AppAssets.kProfile,
              title: 'Name',
                subtitle: user?.name ?? 'Not available',
              onTap: _showEditProfileSheet,
              );
            }),
            const Divider(height: 0.5),
            Obx(() {
              final user = authController.currentUser.value;
              return SettingTile(
              icon: AppAssets.kEmail,
              title: 'Email',
                subtitle: user?.email ?? 'Not available',
              onTap: () {},
              );
            }),            
            const Divider(height: 0.5),
            SettingTile(
              icon: AppAssets.kPassword,
              title: 'Password',
              subtitle: 'Tap to update your password',
              onTap: _showChangePasswordSheet,
            ),
            const Divider(),
            GetBuilder<ThemeController>(
              init: ThemeController(),
              initState: (_) {},
              builder: (_) {
                final isLightMode = _.theme == 'light';
                return SettingTile(
                  icon: AppAssets.kTheme,
                  isSwitch: true,
                  title: 'Light Mode',
                  switchValue: isLightMode,
                  onChanged: (value) {
                    if (isLightMode) {
                      _.setTheme('dark');
                    } else {
                      _.setTheme('light');
                    }
                  },
                );
              },
            ),
            const Divider(),
            SettingTile(
              icon: AppAssets.kHelp,
              title: 'Help & Feedback',
              onTap: _showHelpSheet,
            ),
            const Divider(),
            SettingTile(
              icon: AppAssets.kPrivacy,
              title: 'Privacy',
              onTap: _showPrivacySheet,
            ),
            const Spacer(),
            PrimaryButton(
              onTap: () async {
                final authController = Get.find<AuthController>();
                await authController.logout();
                await Get.offAllNamed<dynamic>(AppRoutes.getLandingPageRoute());
              },
              text: 'Sign Out',
            ),
            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangePasswordSheet(
        authController: authController,
      ),
    );
  }

  void _showEditProfileSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EditProfileSheet(
        authController: authController,
      ),
    );
  }

  void _showHelpSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _InfoSheet(
        title: 'Help & Feedback',
        body:
            '• Need help? Contact support at support@mentormesh.com\n• Found a bug? Send feedback from this app or email us.\n• Check FAQ in the upcoming Help Center.',
      ),
    );
  }

  void _showPrivacySheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _InfoSheet(
        title: 'Privacy',
        body:
            '• We use your data only to deliver core learning features.\n• You can update your profile and password anytime.\n• Contact support to request data deletion or export.',
      ),
    );
  }
}

class _InfoSheet extends StatelessWidget {
  final String title;
  final String body;
  const _InfoSheet({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20.w,
        right: 20.w,
        top: 20.h,
      ),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(AppSpacing.radiusTwenty),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTypography.kBold20),
            SizedBox(height: 12.h),
            Text(
              body,
              style: AppTypography.kLight14,
            ),
            SizedBox(height: 20.h),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.kPrimary,
                ),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EditProfileSheet extends StatefulWidget {
  final AuthController authController;
  const EditProfileSheet({required this.authController, super.key});

  @override
  State<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<EditProfileSheet> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late final TextEditingController nameController;
  late final TextEditingController jobTitleController;
  late final TextEditingController bioController;
  bool isSubmitting = false;
  Uint8List? pickedAvatarBytes;
  String? existingAvatar;

  @override
  void initState() {
    super.initState();
    final user = widget.authController.currentUser.value;
    nameController = TextEditingController(text: user?.name ?? '');
    jobTitleController = TextEditingController(text: user?.jobTitle ?? '');
    bioController = TextEditingController(text: user?.bio ?? '');
    existingAvatar = user?.profileImage;
  }

  @override
  void dispose() {
    nameController.dispose();
    jobTitleController.dispose();
    bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20.w,
        right: 20.w,
        top: 20.h,
      ),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(AppSpacing.radiusTwenty),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit Profile',
                  style: AppTypography.kBold20,
                ),
                SizedBox(height: 16.h),
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Name is required';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 12.h),
                TextFormField(
                  controller: jobTitleController,
                  decoration: const InputDecoration(
                    labelText: 'Job Title',
                  ),
                ),
                SizedBox(height: 12.h),
                TextFormField(
                  controller: bioController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Bio / Personal info',
                  ),
                ),
                SizedBox(height: 12.h),
                Center(
                  child: ProfileImagePicker(
                    initials: _initialsFromName(nameController.text),
                    initialImageUrl: existingAvatar,
                    onPicked: (bytes) {
                      pickedAvatarBytes = bytes;
                    },
                  ),
                ),
                SizedBox(height: 20.h),
                SizedBox(
                  width: double.infinity,
                  child: PrimaryButton(
                    onTap: isSubmitting ? () {} : _submit,
                    text: isSubmitting ? 'Saving...' : 'Save',
                  ),
                ),
                SizedBox(height: 10.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!formKey.currentState!.validate()) return;
    final auth = widget.authController;
    setState(() {
      isSubmitting = true;
    });
    final success = await auth.updateProfile(
      name: nameController.text.trim(),
      jobTitle: jobTitleController.text.trim(),
      bio: bioController.text.trim(),
      profileImage: pickedAvatarBytes != null
          ? 'data:image/png;base64,${base64Encode(pickedAvatarBytes!)}'
          : (existingAvatar ?? ''),
    );
    if (mounted) {
      setState(() {
        isSubmitting = false;
      });
      if (success) {
        // ignore: cascade_invocations
        Get.back<void>();
        // ignore: cascade_invocations
        Get.snackbar(
          'Profile Updated',
          'Your profile has been saved.',
          snackPosition: SnackPosition.TOP,
        );
      } else {
        final errorMsg = auth.errorMessage.value;
        Get.snackbar(
          'Update Failed',
          errorMsg.isEmpty ? 'Could not update profile' : errorMsg,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  String _initialsFromName(String name) {
    final parts = name.trim().split(RegExp(r'\\s+'));
    if (parts.isEmpty) return '';
    if (parts.length == 1) {
      return parts.first.isNotEmpty ? parts.first[0].toUpperCase() : '';
    }
    return (parts[0].isNotEmpty ? parts[0][0] : '') +
        (parts[1].isNotEmpty ? parts[1][0] : '');
  }
}

class ChangePasswordSheet extends StatefulWidget {
  final AuthController authController;

  const ChangePasswordSheet({
    required this.authController,
    super.key,
  });

  @override
  State<ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<ChangePasswordSheet> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  bool isSubmitting = false;

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20.w,
        right: 20.w,
        top: 20.h,
      ),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(AppSpacing.radiusTwenty),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Change Password',
                  style: AppTypography.kBold20,
                ),
                SizedBox(height: 20.h),
                TextFormField(
                  controller: currentPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Current Password',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter your current password';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),
                TextFormField(
                  controller: newPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'New Password',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter a new password';
                    }
                    if (value.length < 6) {
                      return 'Password should be at least 6 characters';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),
                TextFormField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Confirm New Password',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Confirm your new password';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24.h),
                PrimaryButton(
                  onTap: _handleSubmit,
                  text: isSubmitting ? 'Updating...' : 'Update Password',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (isSubmitting) return;
    if (!formKey.currentState!.validate()) {
      return;
    }
    if (newPasswordController.text.trim() !=
        confirmPasswordController.text.trim()) {
      Get.snackbar(
        'Password mismatch',
        'New password and confirmation do not match',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    final success = await widget.authController.changePassword(
      currentPassword: currentPasswordController.text.trim(),
      newPassword: newPasswordController.text.trim(),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      isSubmitting = false;
    });

    if (success) {
      Navigator.of(context).pop();
      Get.snackbar(
        'Password updated',
        'Your password has been changed successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      final message = widget.authController.errorMessage.value.isNotEmpty
          ? widget.authController.errorMessage.value
          : 'Unable to update password';
      Get.snackbar(
        'Update failed',
        message,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
