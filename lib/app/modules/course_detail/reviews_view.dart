import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mentor_mesh_hub/app/controllers/api_controller.dart';
import 'package:mentor_mesh_hub/app/controllers/auth_controller.dart';
import 'package:mentor_mesh_hub/app/data/constants/constants.dart';
import 'package:mentor_mesh_hub/app/models/course.dart';
import 'package:mentor_mesh_hub/app/modules/course_detail/components/review_card.dart';
import 'package:mentor_mesh_hub/app/modules/widgets/buttons/primary_button.dart';
import 'package:mentor_mesh_hub/app/modules/widgets/containers/primary_container.dart';
import 'package:mentor_mesh_hub/app/modules/widgets/rating/custom_rating_bar.dart';

class ReviewsView extends StatefulWidget {
  final Course course;
  const ReviewsView({required this.course, super.key});

  @override
  State<ReviewsView> createState() => _ReviewsViewState();
}

class _ReviewsViewState extends State<ReviewsView> {
  final ApiController apiController = Get.find<ApiController>();
  final AuthController authController = Get.find<AuthController>();
  final TextEditingController _reviewController = TextEditingController();
  double _selectedRating = 0.0;
  bool _isLoading = false;
  bool _isSubmitting = false;
  List<Map<String, dynamic>> _reviews = [];
  Map<int, int> _ratingDistribution = {}; // Rating count by star level (1-5)

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _loadReviews() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final reviews = await apiController.getCourseReviews(widget.course.id);
      final currentUserId = authController.currentUser.value?.id;
      
      // Calculate rating distribution
      final distribution = <int, int>{1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
      Map<String, dynamic>? userReview;
      
      for (final review in reviews) {
        final rating = review['rating'] as int?;
        if (rating != null && rating >= 1 && rating <= 5) {
          distribution[rating] = (distribution[rating] ?? 0) + 1;
        }
        
        // Check if this is the current user's review
        if (currentUserId != null && review['userId'] == currentUserId) {
          userReview = review;
        }
      }

      // Pre-populate form if user already rated
      if (userReview != null) {
        final existingRating = userReview['rating'] as int?;
        final existingReview = userReview['review'] as String?;
        if (existingRating != null && existingRating > 0) {
          _selectedRating = existingRating.toDouble();
        }
        if (existingReview != null && existingReview.isNotEmpty) {
          _reviewController.text = existingReview;
        }
      }

      setState(() {
        _reviews = reviews;
        _ratingDistribution = distribution;
        _isLoading = false;
      });
    } on Exception catch (e) {
      setState(() {
        _isLoading = false;
      });
      Get.snackbar(
        'Error',
        'Failed to load reviews: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _submitRating() async {
    if (_selectedRating == 0) {
      Get.snackbar(
        'Rating Required',
        'Please select a rating',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final success = await apiController.rateCourse(
      courseId: widget.course.id,
      rating: _selectedRating,
      review: _reviewController.text.trim().isNotEmpty ? _reviewController.text.trim() : null,
    );

    setState(() {
      _isSubmitting = false;
    });

    if (success) {
      Get.snackbar(
        'Success',
        _selectedRating > 0 && _reviews.any((r) => r['userId'] == authController.currentUser.value?.id)
            ? 'Rating updated successfully!'
            : 'Rating submitted successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      // Don't clear the form - keep the rating and review so user can see what they submitted
      await _loadReviews();
      // Reload course to update average rating
      await apiController.loadCourses(limit: 50);
    } else {
      Get.snackbar(
        'Error',
        apiController.errorMessage.value.isNotEmpty
            ? apiController.errorMessage.value
            : 'Failed to submit rating',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isStudent = authController.currentUser.value?.role == 'student';
    final isEnrolled = apiController.isEnrolledInCourse(widget.course.id);
    final canRate = isStudent && isEnrolled;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.twentyHorizontal),
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: AppSpacing.thirtyVertical),
          
          // Rating Distribution
          if (_ratingDistribution.isNotEmpty) ...[
            Text('Rating Distribution', style: AppTypography.kBold18),
            SizedBox(height: 12.h),
            ...List.generate(5, (index) {
              final starLevel = 5 - index;
              final count = _ratingDistribution[starLevel] ?? 0;
              final total = _reviews.length;
              final percentage = total > 0 ? (count / total * 100) : 0.0;
              
              return Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Row(
                  children: [
                    Text('$starLevel', style: AppTypography.kBold14),
                    SizedBox(width: 8.w),
                    Icon(Icons.star, color: Colors.amber, size: 16.sp),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: percentage / 100,
                        backgroundColor: Colors.grey[200],
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.kPrimary),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      '$count',
                      style: AppTypography.kLight14,
                    ),
                  ],
                ),
              );
            }),
            SizedBox(height: 24.h),
          ],

          // Rating Form (only for enrolled students)
          if (canRate) ...[
            Text(
              _selectedRating > 0 ? 'Update your rating' : 'Rate this course',
              style: AppTypography.kBold18,
            ),
            if (_selectedRating > 0) ...[
              SizedBox(height: 4.h),
              Text(
                'You can update your rating at any time',
                style: AppTypography.kLight14.copyWith(
                  fontSize: 12.sp,
                  color: Colors.grey,
                ),
              ),
            ],
            SizedBox(height: 12.h),
            CustomRatingBar(
              initialRating: _selectedRating,
              itemSize: 32.sp,
              onRatingUpdate: (rating) {
                setState(() {
                  _selectedRating = rating;
                });
              },
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: _reviewController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Write your review (optional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            PrimaryButton(
              onTap: _isSubmitting ? () {} : _submitRating,
              text: _isSubmitting ? 'Submitting...' : 'Submit Rating',
            ),
            SizedBox(height: 30.h),
          ] else if (isStudent && !isEnrolled) ...[
            PrimaryContainer(
              padding: EdgeInsets.all(16.h),
              child: Text(
                'Enroll in this course to leave a rating',
                style: AppTypography.kLight16,
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 30.h),
          ],

          // Reviews List
          Text('Reviews (${_reviews.length})', style: AppTypography.kBold18),
          SizedBox(height: 16.h),
          
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40.0),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_reviews.isEmpty)
            PrimaryContainer(
              padding: EdgeInsets.all(40.h),
              child: Column(
                children: [
                  Icon(
                    Icons.reviews_outlined,
                    size: 64.sp,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'No reviews yet',
                    style: AppTypography.kLight16.copyWith(color: Colors.grey),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Be the first to review this course!',
                    style: AppTypography.kLight14.copyWith(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final review = _reviews[index];
                return ReviewCard(
                  userName: review['userName'] as String? ?? 'Anonymous',
                  userImage: review['userImage'] as String?,
                  rating: review['rating'] as int? ?? 0,
                  review: review['review'] as String?,
                  reviewDate: review['reviewDate'] != null
                      ? DateTime.parse(review['reviewDate'] as String)
                      : null,
                );
              },
              separatorBuilder: (context, index) => SizedBox(height: 15.h),
              itemCount: _reviews.length,
            ),
          SizedBox(height: 30.h),
        ],
      ),
    );
  }
}
