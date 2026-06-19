import 'package:video_player/video_player.dart';
import '../storage/progress_storage_provider.dart';
import '../analytics/analytics_provider.dart';
import '../player/fullscreen_manager.dart';

/// Controls playback programmatically and acts as a facade over 
/// the underlying [VideoPlayerController].
class VideoProgressController {
  VideoPlayerController? _videoPlayerController;
  AnalyticsProvider? _analyticsProvider;

  /// Creates a new [VideoProgressController].
  VideoProgressController();

  /// Attaches the controller to a [VideoPlayerController] and analytics providers.
  /// This is used internally by the [VideoProgressPlayer].
  void attach({
    required VideoPlayerController controller,
    String? resumeKey,
    ProgressStorageProvider? storageProvider,
    AnalyticsProvider? analyticsProvider,
  }) {
    _videoPlayerController = controller;
    _analyticsProvider = analyticsProvider;
  }

  /// Detaches the controller from the current [VideoPlayerController].
  void detach() {
    _videoPlayerController = null;
    _analyticsProvider = null;
  }

  /// Starts video playback.
  Future<void> play() async {
    await _videoPlayerController?.play();
    _analyticsProvider?.onPlay();
  }

  /// Pauses video playback.
  Future<void> pause() async {
    await _videoPlayerController?.pause();
    _analyticsProvider?.onPause();
  }

  /// Seeks the video to the provided [position].
  Future<void> seekTo(Duration position) async {
    if (_videoPlayerController == null) return;
    final currentPos = _videoPlayerController!.value.position;
    await _videoPlayerController!.seekTo(position);
    _analyticsProvider?.onSeek(currentPos, position);
  }

  /// Sets the playback speed (e.g., 1.0 for normal, 2.0 for double speed).
  Future<void> setPlaybackSpeed(double speed) async {
    await _videoPlayerController?.setPlaybackSpeed(speed);
  }

  /// Callback invoked when fullscreen state changes.
  void Function(bool)? onFullscreenChanged;

  /// Enters fullscreen mode, hiding system UI elements.
  Future<void> enterFullscreen() async {
    await FullscreenManager.enterFullscreen();
    onFullscreenChanged?.call(true);
    _analyticsProvider?.onFullscreen(true);
  }

  /// Exits fullscreen mode, restoring system UI elements.
  Future<void> exitFullscreen() async {
    await FullscreenManager.exitFullscreen();
    onFullscreenChanged?.call(false);
    _analyticsProvider?.onFullscreen(false);
  }

  /// Returns the underlying [VideoPlayerController] instance.
  VideoPlayerController? get videoPlayerController => _videoPlayerController;
}
