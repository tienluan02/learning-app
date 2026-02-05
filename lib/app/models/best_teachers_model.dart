import 'package:mentor_mesh_hub/app/data/constants/constants.dart';

class BestTeachersModel {
  String name;
  String bio;
  String image;
  int position;
  double rating;

  BestTeachersModel({
    required this.name,
    required this.bio,
    required this.image,
    required this.position,
    this.rating = 0.0,
  });
}

// Static fallback list (only used if API has no data)
List<BestTeachersModel> bestTeachers = [
  BestTeachersModel(
    name: 'Martín Abasto',
    bio: 'Illustrator',
    image: AppAssets.kUser3,
    position: 1,
    rating: 4.8,
  ),
  BestTeachersModel(
    name: 'Emmy Elsner',
    bio: 'Design Expert',
    image: AppAssets.kUser6,
    position: 2,
    rating: 4.7,
  ),
  BestTeachersModel(
    name: 'Meng Ru',
    bio: 'Esports Coach',
    image: AppAssets.kUser7,
    position: 3,
    rating: 4.6,
  ),
];
