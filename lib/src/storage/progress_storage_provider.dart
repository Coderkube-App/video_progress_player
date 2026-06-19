import '../models/video_progress.dart';

abstract class ProgressStorageProvider {
  Future<void> saveProgress(String resumeKey, VideoProgress progress);
  Future<VideoProgress?> loadProgress(String resumeKey);
}
