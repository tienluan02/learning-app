import 'package:mentor_mesh_hub/app/data/constants/constants.dart';

class Category {
  String id;
  String name;
  String image;
  String? description;
  String? color;
  bool? isActive;
  int? courseCount;
  int? sortOrder;

  Category({
    required this.id,
    required this.name,
    required this.image,
    this.description,
    this.color,
    this.isActive,
    this.courseCount,
    this.sortOrder,
  });

  // Factory constructor from JSON
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      description: json['description'],
      color: json['color'],
      isActive: json['isActive'],
      courseCount: json['courseCount'],
      sortOrder: json['sortOrder'],
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'description': description,
      'color': color,
      'isActive': isActive,
      'courseCount': courseCount,
      'sortOrder': sortOrder,
    };
  }
}

List<Category> categoriesList = [
  Category(id: '1', name: 'Gaming', image: AppAssets.kGaming),
  Category(id: '2', name: 'Music', image: AppAssets.kMusic),
  Category(id: '3', name: 'Photography', image: AppAssets.kPhotography),
  Category(id: '4', name: 'Art', image: AppAssets.kArt),
  Category(id: '5', name: 'Design', image: AppAssets.kDesign),
  Category(id: '6', name: 'Business', image: AppAssets.kBusiness),
  Category(id: '7', name: 'LifeStyle', image: AppAssets.kLifeStyle),
  Category(id: '8', name: 'Coding', image: AppAssets.kCoding),
];
