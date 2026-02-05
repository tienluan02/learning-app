import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mentor_mesh_hub/app/data/constants/constants.dart';
import 'package:mentor_mesh_hub/app/models/user_model.dart';

class CourseOwnerCard extends StatelessWidget {
  final UserModel? user;
  const CourseOwnerCard({required this.user, super.key});

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const SizedBox.shrink();
    }
    
    return Row(
      children: [
        Container(
          height: 50.h,
          width: 50.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.r),
            image: DecorationImage(
              image: _resolveImage(user!.profileImage),
              fit: BoxFit.cover,
            ),
          ),
        ),
        SizedBox(width: AppSpacing.tenHorizontal),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user!.name,
                style: AppTypography.kBold16,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                (user!.jobTitle?.isNotEmpty ?? false) ? user!.jobTitle! : user!.bio,
                style: AppTypography.kLight14,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  ImageProvider _resolveImage(String? path) {
    if (path == null || path.isEmpty) {
      return AssetImage(AppAssets.kUser5);
    }

    if (path.startsWith('http')) {
      return NetworkImage(path);
    }

    if (path.startsWith('assets/')) {
      return AssetImage(path);
    }

    return AssetImage(AppAssets.kUser5);
  }
}
