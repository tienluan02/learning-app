import 'package:mentor_mesh_hub/app/data/constants/constants.dart';
import 'package:mentor_mesh_hub/app/models/category.dart';
import 'package:mentor_mesh_hub/app/models/lessons.dart';
import 'package:mentor_mesh_hub/app/models/user_model.dart';

class Course {
  String id;
  String image;
  String name;
  double price;
  Category? category;
  List<Lessons> lessons;
  String description;
  UserModel? owner;
  String? shortDescription;
  double? originalPrice;
  String? categoryId;
  String? instructorId;
  String? level;
  String? language;
  int? duration;
  bool? isPublished;
  bool? isFeatured;
  List<String>? tags;
  List<String>? requirements;
  List<String>? whatYouWillLearn;
  double? averageRating;
  int? ratingCount;
  int? totalEnrollments;
  int? totalLessons;
  int? totalDuration;
  String? startDate;
  String? endDate;
  bool? isSelfPaced;

  Course({
    required this.id,
    required this.image,
    required this.name,
    required this.price,
    this.category,
    required this.lessons,
    required this.description,
    this.owner,
    this.shortDescription,
    this.originalPrice,
    this.categoryId,
    this.instructorId,
    this.level,
    this.language,
    this.duration,
    this.isPublished,
    this.isFeatured,
    this.tags,
    this.requirements,
    this.whatYouWillLearn,
    this.averageRating,
    this.ratingCount,
    this.totalEnrollments,
    this.totalLessons,
    this.totalDuration,
    this.startDate,
    this.endDate,
    this.isSelfPaced,
  });

  // Factory constructor from JSON
  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'].toString(),
      image: json['image'] ?? '',
      name: json['title'] ?? '',
      price: (json['price'] as num? ?? 0).toDouble(),
      description: json['description'] ?? '',
      lessons: [], // Will be populated separately
      shortDescription: json['shortDescription'],
      originalPrice: (json['originalPrice'] as num?)?.toDouble(),
      categoryId: json['categoryId']?.toString(),
      instructorId: json['instructorId']?.toString(),
      level: json['level'],
      language: json['language'],
      duration: json['duration'],
      isPublished: json['isPublished'],
      isFeatured: json['isFeatured'],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      requirements: json['requirements'] != null ? List<String>.from(json['requirements']) : null,
      whatYouWillLearn: json['whatYouWillLearn'] != null ? List<String>.from(json['whatYouWillLearn']) : null,
      averageRating: (json['averageRating'] as num?)?.toDouble(),
      ratingCount: json['ratingCount'],
      totalEnrollments: json['totalEnrollments'],
      totalLessons: json['totalLessons'],
      totalDuration: json['totalDuration'],
      startDate: json['startDate'],
      endDate: json['endDate'],
      isSelfPaced: json['isSelfPaced'],
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': name,
      'image': image,
      'price': price,
      'description': description,
      'shortDescription': shortDescription,
      'originalPrice': originalPrice,
      'categoryId': categoryId,
      'instructorId': instructorId,
      'level': level,
      'language': language,
      'duration': duration,
      'isPublished': isPublished,
      'isFeatured': isFeatured,
      'tags': tags,
      'requirements': requirements,
      'whatYouWillLearn': whatYouWillLearn,
      'averageRating': averageRating,
      'ratingCount': ratingCount,
      'totalEnrollments': totalEnrollments,
      'totalLessons': totalLessons,
      'totalDuration': totalDuration,
      'startDate': startDate,
      'endDate': endDate,
      'isSelfPaced': isSelfPaced,
    };
  }
}

List<Course> coursesList = [
  Course(
    id: '1',
    owner: currentUser,
    image: AppAssets.kFlutterCourse1,
    name: 'Android & iOS App Development',
    price: 35,
    category: categoriesList[7],
    description:
        'Discover the power of Flutter and Dart to create stunning, high-performance mobile apps for iOS and Android with the most comprehensive and bestselling Flutter course! With over 30 hours of comprehensive content, this course is the ultimate resource for anyone who wants to build beautiful, responsive, and feature-rich applications from scratch.',
    lessons: [
      Lessons(
        id: '729ru',
        duration: '2m 43s',
        isPaid: false,
        name: 'Introduction to Flutter Development',
        videoUrl: 'https://www.fluttercampus.com/video.mp4',
      ),
      Lessons(
        id: 'caucahu8',
        duration: '1m 43s',
        isPaid: true,
        name: 'Building User Interfaces with Flutter',
        videoUrl: 'https://www.fluttercampus.com/video.mp4',
      ),
      Lessons(
        id: 'def256',
        duration: '3m 12s',
        isPaid: true,
        name: 'State Management in Flutter Apps',
        videoUrl: 'https://www.fluttercampus.com/video.mp4',
      ),
      Lessons(
        id: 'abc123',
        duration: '2m 59s',
        isPaid: true,
        name: 'Working with APIs and Networking',
        videoUrl: 'https://www.fluttercampus.com/video.mp4',
      ),
      Lessons(
        id: 'ghi789',
        duration: '2m 18s',
        isPaid: true,
        name: 'Handling Forms and User Input',
        videoUrl: 'https://www.fluttercampus.com/video.mp4',
      ),
      Lessons(
        id: 'jkl012',
        duration: '3m 27s',
        isPaid: true,
        name: 'Advanced UI Techniques in Flutter',
        videoUrl: 'https://www.fluttercampus.com/video.mp4',
      ),
      Lessons(
        id: 'mno345',
        duration: '2m 51s',
        isPaid: true,
        name: 'Testing and Debugging Flutter Apps',
        videoUrl: 'https://www.fluttercampus.com/video.mp4',
      ),
      Lessons(
        id: 'pqr678',
        duration: '2m 36s',
        isPaid: true,
        name: 'Publishing and Deploying Flutter Apps',
        videoUrl: 'https://www.fluttercampus.com/video.mp4',
      ),
    ],
  ),
  Course(
    id: '2',
    owner: currentUser,
    image: AppAssets.kWebsiteCourse1,
    name: 'Designing an eCommerce Website',
    price: 35,
    category: categoriesList[4],
    description:
        'Learn the foundation of web design\nand how to create stunning websites for\nyour next web design project. ',
    lessons: [
      Lessons(
        id: 'ach87',
        duration: '1m 33s',
        isPaid: false,
        name: 'Introduction to Web Development',
        videoUrl: 'https://www.fluttercampus.com/video.mp4',
      ),
      Lessons(
        id: 'caucahu8',
        duration: '1m 43s',
        isPaid: true,
        name: 'HTML and CSS Fundamentals',
        videoUrl: 'https://www.fluttercampus.com/video.mp4',
      ),
      Lessons(
        id: 'ghd942',
        duration: '2m 10s',
        isPaid: true,
        name: 'JavaScript Basics for Web Development',
        videoUrl: 'https://www.fluttercampus.com/video.mp4',
      ),
      Lessons(
        id: 'plm294',
        duration: '2m 19s',
        isPaid: true,
        name: 'Building Responsive Web Layouts',
        videoUrl: 'https://www.fluttercampus.com/video.mp4',
      ),
      Lessons(
        id: 'bvd097',
        duration: '1m 54s',
        isPaid: true,
        name: 'Working with Front-end Frameworks',
        videoUrl: 'https://www.fluttercampus.com/video.mp4',
      ),
      Lessons(
        id: 'wyv274',
        duration: '2m 33s',
        isPaid: true,
        name: 'Backend Development with Node.js',
        videoUrl: 'https://www.fluttercampus.com/video.mp4',
      ),
      Lessons(
        id: 'rst583',
        duration: '2m 45s',
        isPaid: true,
        name: 'Database Integration and Management',
        videoUrl: 'https://www.fluttercampus.com/video.mp4',
      ),
      Lessons(
        id: 'mnq492',
        duration: '2m 24s',
        isPaid: true,
        name: 'Deploying and Hosting Web Applications',
        videoUrl: 'https://www.fluttercampus.com/video.mp4',
      ),
    ],
  ),
];
