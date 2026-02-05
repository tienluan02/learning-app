import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:mentor_mesh_hub/app/data/constants/constants.dart';
import 'package:mentor_mesh_hub/app/models/course_video.dart';
import 'package:mentor_mesh_hub/app/models/lessons.dart';
import 'package:mentor_mesh_hub/app/modules/course_detail/components/lesson_card.dart';
import 'package:mentor_mesh_hub/app/modules/course_videos/upload_video_view.dart';
import 'package:mentor_mesh_hub/app/modules/course_videos/video_player_view.dart';
import 'package:mentor_mesh_hub/app/modules/widgets/containers/primary_container.dart';
import 'package:mentor_mesh_hub/app/services/api_service.dart';

class CourseLessonsView extends StatefulWidget {
  final List<Lessons> lesson;
  final int? courseId;
  final bool isTeacher;
  const CourseLessonsView({
    required this.lesson,
    this.courseId,
    this.isTeacher = false,
    super.key,
  });

  @override
  State<CourseLessonsView> createState() => _CourseLessonsViewState();
}

class _CourseLessonsViewState extends State<CourseLessonsView> {
  bool _isDownloadAll = true;
  List<CourseVideo> _videos = [];

  @override
  void initState() {
    super.initState();
    if (widget.courseId != null) {
      _loadVideos();
    }
  }

  Future<void> _navigateToUpload() async {
    if (widget.courseId == null) return;
    
    final result = await Get.to(() => UploadVideoView(courseId: widget.courseId!));
    if (result == true && mounted) {
      // Refresh videos list after successful upload
      _loadVideos();
    }
  }

  Future<void> _loadVideos() async {
    if (widget.courseId == null) return;

    try {
      final response = await ApiService.getCourseVideos(widget.courseId!);
      
      if (response['success'] == true) {
        final videosData = response['data']['videos'] as List;
        if (mounted) {
          setState(() {
            _videos = videosData
                .map((v) => CourseVideo.fromJson(v as Map<String, dynamic>))
                .toList();
          });
        }
      } else {
        throw Exception(response['message'] as String? ?? 'Failed to load videos');
      }
    } on Exception {
      // Silently fail - videos are optional
      if (mounted) {
        setState(() {
          _videos = [];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.twentyHorizontal),
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        children: [
          SizedBox(height: 30.h),
          
          // Videos Section (if available)
          if (widget.courseId != null) ...[
            Padding(
              padding: EdgeInsets.only(top: 16.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Videos',
                    style: AppTypography.kBold18,
                  ),
                  if (widget.isTeacher)
                    ElevatedButton.icon(
                      onPressed: _navigateToUpload,
                      icon: const Icon(Icons.add, size: 20),
                      label: const Text('Upload'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.kPrimary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: 8.h),
            if (_videos.isEmpty && widget.isTeacher) ...[
              PrimaryContainer(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  children: [
                    Icon(
                      Icons.video_library_outlined,
                      size: 48.sp,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'No videos yet',
                      style: AppTypography.kLight16.copyWith(color: Colors.grey),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Upload your first video to get started',
                      style: AppTypography.kLight14.copyWith(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16.h),
                    ElevatedButton.icon(
                      onPressed: _navigateToUpload,
                      icon: const Icon(Icons.add),
                      label: const Text('Upload Video'),
                    ),
                  ],
                ),
              ),
            ],
            if (_videos.isNotEmpty) ...[
              ListView.separated(
                itemBuilder: (context, index) {
                  final video = _videos[index];
                  return GestureDetector(
                    onTap: () {
                      final baseUrl = ApiService.baseUrl.replaceAll('/api', '');
                      Get.to(() => VideoPlayerView(
                        video: video,
                        baseUrl: baseUrl,
                      ));
                    },
                    child: PrimaryContainer(
                      padding: EdgeInsets.all(12.w),
                      child: Row(
                        children: [
                          Container(
                            height: 50.h,
                            width: 50.w,
                            decoration: BoxDecoration(
                              color: AppColors.kPrimary,
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: const Icon(
                              Icons.play_arrow,
                              color: AppColors.kWhite,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  video.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.kBold16,
                                ),
                                SizedBox(height: 4.h),
                                if (video.viewCount > 0)
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.visibility, size: 12.sp, color: Colors.grey),
                                      SizedBox(width: 4.w),
                                      Flexible(
                                        child: Text(
                                          '${video.viewCount} views',
                                          style: AppTypography.kLight14.copyWith(
                                            color: Colors.grey,
                                            fontSize: 12.sp,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: Colors.grey),
                        ],
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, index) => SizedBox(height: 12.h),
                itemCount: _videos.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
              ),
              SizedBox(height: 24.h),
            ],
          ],
          
          // Lessons Section
          if (widget.lesson.isNotEmpty) ...[
            Text(
              'Lessons',
              style: AppTypography.kBold18,
            ),
            SizedBox(height: 12.h),
            ListView.separated(
              itemBuilder: (context, index) {
                return LessonCard(
                  index: index,
                  lesson: widget.lesson[index],
                );
              },
              separatorBuilder: (context, index) => Divider(height: 30.h),
              itemCount: widget.lesson.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
            ),
          ] else if (widget.lesson.isEmpty && _videos.isEmpty) ...[
            Padding(
              padding: EdgeInsets.all(40.h),
              child: Column(
                children: [
                  Icon(
                    Icons.video_library_outlined,
                    size: 64.sp,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'No content yet',
                    style: AppTypography.kLight16.copyWith(color: Colors.grey),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Lessons and videos will appear here once they are added to the course',
                    style: AppTypography.kLight14.copyWith(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

