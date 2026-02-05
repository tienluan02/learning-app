import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mentor_mesh_hub/app/data/constants/constants.dart';
import 'package:mentor_mesh_hub/app/models/course.dart';
import 'package:mentor_mesh_hub/app/modules/course_detail/course_detail_view.dart';
import 'package:mentor_mesh_hub/app/modules/widgets/containers/primary_container.dart';
import 'package:mentor_mesh_hub/app/services/api_service.dart';

class MyCourseCard extends StatefulWidget {
  final Course course;
  const MyCourseCard({required this.course, super.key});

  @override
  State<MyCourseCard> createState() => _MyCourseCardState();
}

class _MyCourseCardState extends State<MyCourseCard> {
  int _videoCount = 0;
  bool _isLoadingVideos = false;

  @override
  void initState() {
    super.initState();
    _loadVideoCount();
  }

  Future<void> _loadVideoCount() async {
    int? courseId;
    try {
      courseId = int.parse(widget.course.id);
    } on FormatException {
      return;
    }

    // courseId is already checked above, continue

    setState(() {
      _isLoadingVideos = true;
    });

    try {
      final response = await ApiService.getCourseVideos(courseId);
      if (response['success'] == true && mounted) {
        final videosData = response['data']['videos'] as List;
        setState(() {
          _videoCount = videosData.length;
          _isLoadingVideos = false;
        });
      } else if (mounted) {
        setState(() {
          _isLoadingVideos = false;
        });
      }
    } on Exception {
      if (mounted) {
        setState(() {
          _isLoadingVideos = false;
        });
      }
    }
  }

  ImageProvider _resolveImage(String path) {
    if (path.startsWith('http')) {
      return NetworkImage(path);
    }
    if (path.isNotEmpty) {
      return AssetImage(path);
    }
    return AssetImage(AppAssets.kFlutterCourse1);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        // Navigate to course detail and refresh video count when returning
        final result = await Get.to<Widget>(() => CourseDetailView(course: widget.course));
        // Refresh video count when returning from course detail
        if (mounted) {
          _loadVideoCount();
        }
      },
      child: PrimaryContainer(
        child: Column(
          children: [
            Expanded(
              flex: 5,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(AppSpacing.radiusFifteen),
                  ),
                    image: DecorationImage(
                      image: _resolveImage(widget.course.image),
                      fit: BoxFit.cover,
                    ),
                ),
              ),
            ),
            Expanded(
              flex: 6,
              child: Container(
                padding: EdgeInsets.all(12.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.course.name,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.kBold16,
                    ),
                    const Spacer(),
                    Text(
                      _isLoadingVideos
                          ? 'Loading...'
                          : '${widget.course.lessons.length + _videoCount} Lessons',
                      style: AppTypography.kLight14,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
