import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';
import '../models/video_progress.dart';
import '../strategy/completion_strategy.dart';

class ProgressTracker {
  final VideoPlayerController controller;
  final void Function(VideoProgress)? onProgressChanged;
  final CompletionStrategy? completionStrategy;
  final VoidCallback? onCompleted;
  
  bool _hasCompleted = false;

  ProgressTracker({
    required this.controller,
    this.onProgressChanged,
    this.completionStrategy,
    this.onCompleted,
  }) {
    controller.addListener(_onVideoChanged);
  }

  void _onVideoChanged() {
    if (!controller.value.isInitialized) return;
    
    final position = controller.value.position;
    final duration = controller.value.duration;
    if (duration == Duration.zero) return;

    final percentage = (position.inMilliseconds / duration.inMilliseconds) * 100;
    
    final progress = VideoProgress(
      watched: position,
      total: duration,
      percentage: percentage,
    );

    onProgressChanged?.call(progress);

    if (completionStrategy != null && onCompleted != null && !_hasCompleted) {
      if (completionStrategy!.isCompleted(progress)) {
        _hasCompleted = true;
        onCompleted!();
      }
    }
  }

  void dispose() {
    controller.removeListener(_onVideoChanged);
  }
}
