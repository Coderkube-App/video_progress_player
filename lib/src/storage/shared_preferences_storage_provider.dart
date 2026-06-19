import 'package:shared_preferences/shared_preferences.dart';
import 'progress_storage_provider.dart';
import '../models/video_progress.dart';

class SharedPreferencesStorageProvider implements ProgressStorageProvider {
  static const String _prefix = 'cvp_';

  @override
  Future<void> saveProgress(String resumeKey, VideoProgress progress) async {
    final prefs = await SharedPreferences.getInstance();
    // Only save the watched position for resume
    await prefs.setInt(
        '${_prefix}progress_$resumeKey', progress.watched.inMilliseconds);
  }

  @override
  Future<VideoProgress?> loadProgress(String resumeKey) async {
    final prefs = await SharedPreferences.getInstance();
    final millis = prefs.getInt('${_prefix}progress_$resumeKey');
    if (millis == null) return null;
    return VideoProgress(
      watched: Duration(milliseconds: millis),
      total: Duration.zero,
      percentage: 0,
    );
  }
}
