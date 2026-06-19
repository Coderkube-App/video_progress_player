import 'completion_strategy.dart';
import '../models/video_progress.dart';

class PercentageCompletionStrategy implements CompletionStrategy {
  final int thresholdPercentage;

  const PercentageCompletionStrategy(this.thresholdPercentage);

  @override
  bool isCompleted(VideoProgress progress) {
    return progress.percentage >= thresholdPercentage;
  }
}
