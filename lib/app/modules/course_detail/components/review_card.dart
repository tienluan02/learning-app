import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import 'package:mentor_mesh_hub/app/data/constants/constants.dart';
import 'package:mentor_mesh_hub/app/modules/profile/components/profile_image_card.dart';
import 'package:mentor_mesh_hub/app/modules/widgets/containers/primary_container.dart';

class ReviewCard extends StatelessWidget {
  final String userName;
  final String? userImage;
  final int rating;
  final String? review;
  final DateTime? reviewDate;

  const ReviewCard({
    super.key,
    required this.userName,
    this.userImage,
    this.rating = 0,
    this.review,
    this.reviewDate,
  });

  String _formatDate(DateTime? date) {
    if (date == null) return 'Recently';
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return '1d ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '${weeks}w ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '${months}mo ago';
    } else {
      return DateFormat('MMM yyyy').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PrimaryContainer(
      padding: EdgeInsets.all(18.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ProfileImageCard(
                size: 50.h,
                image: userImage,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(userName, style: AppTypography.kBold16),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          return Icon(
                            index < rating ? Icons.star : Icons.star_border,
                            size: 16.sp,
                            color: index < rating ? Colors.amber : Colors.grey,
                          );
                        }),
                        SizedBox(width: 8.w),
                        Text(
                          _formatDate(reviewDate),
                          style: AppTypography.kLight14.copyWith(color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (review != null && review!.isNotEmpty) ...[
            SizedBox(height: AppSpacing.tenVertical),
            Text(
              review!,
              style: AppTypography.kLight14,
            ),
          ],
        ],
      ),
    );
  }
}
