import 'package:video_player/video_player.dart';
import '../storage/progress_storage_provider.dart';
import '../analytics/analytics_provider.dart';
import '../player/fullscreen_manager.dart';

/// Controls playback programmatically and acts as a facade over 
/// the underlying [VideoPlayerController].
class VideoProgressController {
  VideoPlayerController? _videoPlayerController;
  AnalyticsProvider? _analyticsProvider;

  VideoProgressController();

  void attach({
    required VideoPlayerController controller,
    String? resumeKey,
    ProgressStorageProvider? storageProvider,
    AnalyticsProvider? analyticsProvider,
  }) {
    _videoPlayerController = controller;
    _analyticsProvider = analyticsProvider;
  }

  void detach() {
    _videoPlayerController = null;
    _analyticsProvider = null;
  }

  Future<void> play() async {
    await _videoPlayerController?.play();
    _analyticsProvider?.onPlay();
  }

  Future<void> pause() async {
    await _videoPlayerController?.pause();
    _analyticsProvider?.onPause();
  }

  Future<void> seekTo(Duration position) async {
    if (_videoPlayerController == null) return;
    final currentPos = _videoPlayerController!.value.position;
    await _videoPlayerController!.seekTo(position);
    _analyticsProvider?.onSeek(currentPos, position);
  }

  Future<void> setPlaybackSpeed(double speed) async {
    await _videoPlayerController?.setPlaybackSpeed(speed);
  }

  void Function(bool)? onFullscreenChanged;

  Future<void> enterFullscreen() async {
    await FullscreenManager.enterFullscreen();
    onFullscreenChanged?.call(true);
    _analyticsProvider?.onFullscreen(true);
  }

  Future<void> exitFullscreen() async {
    await FullscreenManager.exitFullscreen();
    onFullscreenChanged?.call(false);
    _analyticsProvider?.onFullscreen(false);
  }

  VideoPlayerController? get videoPlayerController => _videoPlayerController;
}
