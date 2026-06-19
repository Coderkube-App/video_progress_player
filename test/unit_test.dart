import 'package:flutter_test/flutter_test.dart';
import 'package:video_progress_player/src/models/video_progress.dart';
import 'package:video_progress_player/src/strategy/percentage_completion_strategy.dart';

void main() {
  group('VideoProgress Unit Tests', () {
    test('Calculates watched correctly', () {
      final progress = VideoProgress(
        watched: const Duration(seconds: 50),
        total: const Duration(seconds: 100),
        percentage: 50.0,
      );
      expect(progress.percentage, 50.0);
    });

    test('Handles zero total duration gracefully', () {
      final progress = VideoProgress(
        watched: Duration.zero,
        total: Duration.zero,
        percentage: 0.0,
      );
      expect(progress.percentage, 0.0);
    });
  });

  group('PercentageCompletionStrategy Unit Tests', () {
    test('Returns false when below threshold', () {
      final strategy = PercentageCompletionStrategy(90);
      final progress = VideoProgress(
        watched: const Duration(seconds: 50),
        total: const Duration(seconds: 100),
        percentage: 50.0,
      );
      expect(strategy.isCompleted(progress), isFalse);
    });

    test('Returns true when exactly at threshold', () {
      final strategy = PercentageCompletionStrategy(90);
      final progress = VideoProgress(
        watched: const Duration(seconds: 90),
        total: const Duration(seconds: 100),
        percentage: 90.0,
      );
      expect(strategy.isCompleted(progress), isTrue);
    });

    test('Returns true when above threshold', () {
      final strategy = PercentageCompletionStrategy(90);
      final progress = VideoProgress(
        watched: const Duration(seconds: 95),
        total: const Duration(seconds: 100),
        percentage: 95.0,
      );
      expect(strategy.isCompleted(progress), isTrue);
    });
  });
}
