class UserModel {
  String id;
  String name;
  String email;
  String bio;
  String profileImage;
  String role; // 'student' or 'teacher'
  bool isVerified;
  int totalCoursesEnrolled;
  int totalCoursesCreated;
  int totalLessonsCompleted;
  double averageRating;
  String? website;
  String? linkedin;
  String? twitter;
  String? github;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.bio,
    required this.profileImage,
    required this.role,
    this.isVerified = false,
    this.totalCoursesEnrolled = 0,
    this.totalCoursesCreated = 0,
    this.totalLessonsCompleted = 0,
    this.averageRating = 0.0,
    this.website,
    this.linkedin,
    this.twitter,
    this.github,
  });

  // Factory constructor from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      bio: json['bio'] ?? '',
      profileImage: json['profileImage'] ?? '',
      role: json['role'] ?? 'student',
      isVerified: json['isVerified'] ?? false,
      totalCoursesEnrolled: json['totalCoursesEnrolled'] ?? 0,
      totalCoursesCreated: json['totalCoursesCreated'] ?? 0,
      totalLessonsCompleted: json['totalLessonsCompleted'] ?? 0,
      averageRating: (json['averageRating'] as num? ?? 0.0).toDouble(),
      website: json['website'],
      linkedin: json['linkedin'],
      twitter: json['twitter'],
      github: json['github'],
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'bio': bio,
      'profileImage': profileImage,
      'role': role,
      'isVerified': isVerified,
      'totalCoursesEnrolled': totalCoursesEnrolled,
      'totalCoursesCreated': totalCoursesCreated,
      'totalLessonsCompleted': totalLessonsCompleted,
      'averageRating': averageRating,
      'website': website,
      'linkedin': linkedin,
      'twitter': twitter,
      'github': github,
    };
  }

  // Helper methods
  bool get isStudent => role == 'student';
  bool get isTeacher => role == 'teacher';
  bool get isAdmin => role == 'admin';
}

UserModel currentUser = UserModel(
  id: 'fwj93jfwj',
  name: 'Emmy Clark',
  email: 'emmy@example.com',
  bio: 'Design Expert',
  profileImage: 'https://images.unsplash.com/photo-1491349174775-aaafddd81942?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTB8fHBlcnNvbnxlbnwwfHwwfHx8MA%3D%3D&auto=format&fit=crop&w=500&q=60',
  role: 'teacher',
);