import 'dart:convert';
import 'package:get/get.dart';
import 'package:mentor_mesh_hub/app/models/course.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SavedController extends GetxController {
  static const _storageKey = 'saved_courses';
  List<Course>? get saveCourses => _savedCourses.value;
  final Rx<List<Course>?> _savedCourses = Rx<List<Course>?>([]);

  @override
  void onInit() {
    super.onInit();
    _loadSavedCourses();
  }

  Future<void> _loadSavedCourses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedJson = prefs.getString(_storageKey);
      if (savedJson != null) {
        final decoded = json.decode(savedJson) as List<dynamic>;
        _savedCourses.value = decoded
            .map((json) => Course.fromJson(json as Map<String, dynamic>))
            .toList();
        _savedCourses.refresh();
      } else {
        _savedCourses.value = [];
      }
    } on Exception {
      _savedCourses.value = [];
    }
  }

  Future<void> _persistSavedCourses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_savedCourses.value != null && _savedCourses.value!.isNotEmpty) {
        final jsonList = _savedCourses.value!.map((course) => course.toJson()).toList();
        await prefs.setString(_storageKey, json.encode(jsonList));
      } else {
        await prefs.remove(_storageKey);
      }
    } on Exception {
      // Handle error silently
    }
  }

  void addToSaved(Course course) {
    if (saveCourses != null) {
      if (!isSavedCourse(course)) {
        _savedCourses.value!.add(course);
        _savedCourses.refresh();
        _persistSavedCourses();
      }
    } else {
      _savedCourses.value = [course];
      _savedCourses.refresh();
      _persistSavedCourses();
    }
  }

  void removeFromSaved(Course course) {
    if (saveCourses != null) {
      if (isSavedCourse(course)) {
        _savedCourses.value!.removeWhere((c) => c.id == course.id);
        _savedCourses.refresh();
        _persistSavedCourses();
      }
    }
  }

  bool isSavedCourse(Course course) {
    if (saveCourses == null || saveCourses!.isEmpty) {
      return false;
    }
    return saveCourses!.any((p) => p.id == course.id);
  }
}
