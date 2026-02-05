import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mentor_mesh_hub/app/data/constants/constants.dart';

class ProfileImageCard extends StatelessWidget {
  final double? size;
  final String? image;
  const ProfileImageCard({this.image, this.size, super.key});

  @override
  Widget build(BuildContext context) {
    final resolvedImage = _resolveImageProvider();
    return Container(
      height: size ?? 90.h,
      width: size ?? 90.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
        image: DecorationImage(
          image: resolvedImage,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  ImageProvider _resolveImageProvider() {
    if (image == null || image!.isEmpty) {
      return AssetImage(AppAssets.kTeacher1);
    }

    final img = image!;

    // Handle data URLs from gallery uploads
    if (img.startsWith('data:image')) {
      final base64Part = img.substring(img.indexOf(',') + 1);
      final bytes = base64Decode(base64Part);
      return MemoryImage(bytes);
    }

    if (img.startsWith('http')) {
      return NetworkImage(img);
    }

    if (img.startsWith('assets/')) {
      return AssetImage(img);
    }

    // Fallback to network for any other string
    return NetworkImage(img);
  }
}
