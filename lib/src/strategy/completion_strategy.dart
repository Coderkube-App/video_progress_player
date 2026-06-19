import '../models/video_progress.dart';

abstract class CompletionStrategy {
  bool isCompleted(VideoProgress progress);
}
