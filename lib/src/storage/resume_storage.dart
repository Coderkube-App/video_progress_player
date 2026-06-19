import 'package:shared_preferences/shared_preferences.dart';

class ResumeStorage {
  static const String _prefix = 'video_progress_resume_';

  Future<void> savePosition({
    required String courseId,
    required String lessonId,
    required int positionSeconds,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_prefix${courseId}_$lessonId';
    await prefs.setInt(key, positionSeconds);
  }

  Future<int?> getPosition({
    required String courseId,
    required String lessonId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_prefix${courseId}_$lessonId';
    return prefs.getInt(key);
  }
}
