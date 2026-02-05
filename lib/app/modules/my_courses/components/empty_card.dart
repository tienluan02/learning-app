import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mentor_mesh_hub/app/data/constants/constants.dart';

class EmptyCard extends StatelessWidget {
  final String message;
  final String subtitle;
  const EmptyCard({
    super.key,
    this.message = "It's pretty lonely here,\ndon't you think?",
    this.subtitle = 'Create your first course\nand start selling.',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(AppAssets.kNoData),
        Text(
          message,
          style: AppTypography.kBold24,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 5.h),
        Text(
          subtitle,
          style: AppTypography.kLight16,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
