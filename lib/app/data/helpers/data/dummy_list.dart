import 'package:mentor_mesh_hub/app/data/constants/constants.dart';
import 'package:mentor_mesh_hub/app/models/activity.dart';

List<String> reviews = [
  AppAssets.kAngry,
  AppAssets.kFrown,
  AppAssets.kNeutral,
  AppAssets.kSmile,
  AppAssets.kHappy,
];


List<String> userImages = [
  ...todayActivities.map((activity) => activity.userImage),
  ...recentWeek.map((activity) => activity.userImage),
];

