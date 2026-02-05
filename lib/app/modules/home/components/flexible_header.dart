import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mentor_mesh_hub/app/data/constants/constants.dart';
import 'package:mentor_mesh_hub/app/models/course.dart';
import 'package:mentor_mesh_hub/app/modules/widgets/widgets.dart';

class FlexibleHeader extends StatelessWidget {
  final Course course;
  const FlexibleHeader({required this.course, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 360.h,
      automaticallyImplyLeading: false,
      pinned: true,
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final percent = (constraints.maxHeight - kToolbarHeight) /
              (360.h - kToolbarHeight);
          final clamped = percent.clamp(0.0, 1.0);
          return Stack(
            fit: StackFit.expand,
            children: [
              Hero(
                tag: course.image,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: _resolveImage(course.image),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.15 * clamped),
                      Colors.black.withValues(alpha: 0.65),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 16.w,
                right: 16.w,
                top: MediaQuery.of(context).padding.top + 12.h,
                child: Row(
                  children: [
                    CustomIconButton(
                      onTap: () {
                        if (Navigator.of(context).canPop()) {
                          Navigator.of(context).maybePop();
                        } else {
                          Get.back<void>();
                        }
                      },
                      iconColor: AppColors.kWhite,
                      color: Colors.black.withValues(alpha: 0.35),
                      icon: AppAssets.kArrowBackIos,
                    ),
                    const Spacer(),
                    CustomIconButton(
                      iconColor: AppColors.kWhite,
                      color: Colors.black.withValues(alpha: 0.35),
                      icon: AppAssets.kMoreVert,
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  ImageProvider _resolveImage(String path) {
    // Handle base64 data URLs
    if (path.startsWith('data:image')) {
      try {
        final base64Part = path.substring(path.indexOf(',') + 1);
        final bytes = base64Decode(base64Part);
        return MemoryImage(bytes);
      } on Exception {
        // Fallback if base64 decoding fails
        return AssetImage(AppAssets.kFlutterCourse1);
      }
    }
    // Handle network images
    if (path.startsWith('http')) {
      return NetworkImage(path);
    }
    // Handle asset images
    if (path.isNotEmpty) {
      return AssetImage(path);
    }
    // Fallback
    return AssetImage(AppAssets.kFlutterCourse1);
  }
}
