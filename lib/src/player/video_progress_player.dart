import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../controller/video_progress_controller.dart';
import '../models/video_progress.dart';
import '../config/video_progress_config.dart';
import '../theme/video_progress_theme.dart';
import '../source/video_source.dart';
import '../source/network_video_source.dart';
import '../source/asset_video_source.dart';
import '../source/file_video_source.dart';
import '../storage/progress_storage_provider.dart';
import '../storage/shared_preferences_storage_provider.dart';
import '../analytics/analytics_provider.dart';
import '../analytics/no_analytics_provider.dart';
import '../strategy/completion_strategy.dart';
import '../strategy/percentage_completion_strategy.dart';
import 'progress_tracker.dart';
import 'controls_overlay.dart';
import 'fullscreen_manager.dart';

typedef ControlsBuilder = Widget Function(
  BuildContext context,
  VideoProgressController controller,
  VideoPlayerController videoPlayerController,
);

/// A video player widget with built-in progress tracking, resume watching,
/// and completion detection designed for LMS and educational applications.
class VideoProgressPlayer extends StatefulWidget {
  /// The source of the video to play.
  final VideoSource videoSource;

  /// Controls playback programmatically.
  final VideoProgressController? controller;

  /// Unique key used to save and restore playback progress.
  final String? resumeKey;

  /// Configuration options for the player.
  final VideoProgressConfig? config;

  /// Theming options for the default controls.
  final VideoProgressTheme? theme;

  /// Provider that handles saving and loading video progress.
  final ProgressStorageProvider? storageProvider;

  /// Provider that handles analytics events.
  final AnalyticsProvider? analyticsProvider;

  /// Strategy used to determine if a video has been completed.
  final CompletionStrategy? completionStrategy;

  /// Custom builder for the UI controls overlay.
  final ControlsBuilder? controlsBuilder;

  /// Called whenever watched progress changes.
  final ValueChanged<VideoProgress>? onProgressChanged;

  /// Called when the fullscreen state changes.
  final ValueChanged<bool>? onFullscreenChanged;

  /// Called when the video meets the criteria defined by [completionStrategy].
  final VoidCallback? onCompleted;

  /// Creates a [VideoProgressPlayer] from a given [VideoSource].
  const VideoProgressPlayer({
    super.key,
    required this.videoSource,
    this.controller,
    this.resumeKey,
    this.config,
    this.theme,
    this.storageProvider,
    this.analyticsProvider,
    this.completionStrategy,
    this.controlsBuilder,
    this.onProgressChanged,
    this.onFullscreenChanged,
    this.onCompleted,
  });

  /// Convenience constructor to play a video from a network URL.
  ///
  /// The [url] must point to a valid video resource.
  factory VideoProgressPlayer.network({
    Key? key,
    required String url,
    VideoProgressController? controller,
    String? resumeKey,
    VideoProgressConfig? config,
    VideoProgressTheme? theme,
    ProgressStorageProvider? storageProvider,
    AnalyticsProvider? analyticsProvider,
    CompletionStrategy? completionStrategy,
    ControlsBuilder? controlsBuilder,
    ValueChanged<VideoProgress>? onProgressChanged,
    ValueChanged<bool>? onFullscreenChanged,
    VoidCallback? onCompleted,
  }) {
    return VideoProgressPlayer(
      key: key,
      videoSource: NetworkVideoSource(url: url),
      controller: controller,
      resumeKey: resumeKey,
      config: config,
      theme: theme,
      storageProvider: storageProvider,
      analyticsProvider: analyticsProvider,
      completionStrategy: completionStrategy,
      controlsBuilder: controlsBuilder,
      onProgressChanged: onProgressChanged,
      onFullscreenChanged: onFullscreenChanged,
      onCompleted: onCompleted,
    );
  }

  /// Creates a player from an asset bundle.
  ///
  /// The [assetPath] must be a valid path defined in your pubspec.yaml.
  factory VideoProgressPlayer.asset({
    Key? key,
    required String assetPath,
    VideoProgressController? controller,
    String? resumeKey,
    VideoProgressConfig? config,
    VideoProgressTheme? theme,
    ProgressStorageProvider? storageProvider,
    AnalyticsProvider? analyticsProvider,
    CompletionStrategy? completionStrategy,
    ControlsBuilder? controlsBuilder,
    ValueChanged<VideoProgress>? onProgressChanged,
    ValueChanged<bool>? onFullscreenChanged,
    VoidCallback? onCompleted,
  }) {
    return VideoProgressPlayer(
      key: key,
      videoSource: AssetVideoSource(assetPath: assetPath),
      controller: controller,
      resumeKey: resumeKey,
      config: config,
      theme: theme,
      storageProvider: storageProvider,
      analyticsProvider: analyticsProvider,
      completionStrategy: completionStrategy,
      controlsBuilder: controlsBuilder,
      onProgressChanged: onProgressChanged,
      onFullscreenChanged: onFullscreenChanged,
      onCompleted: onCompleted,
    );
  }

  /// Creates a player from a local file system file.
  ///
  /// The [file] must point to a valid video file on the device.
  factory VideoProgressPlayer.file({
    Key? key,
    required File file,
    VideoProgressController? controller,
    String? resumeKey,
    VideoProgressConfig? config,
    VideoProgressTheme? theme,
    ProgressStorageProvider? storageProvider,
    AnalyticsProvider? analyticsProvider,
    CompletionStrategy? completionStrategy,
    ControlsBuilder? controlsBuilder,
    ValueChanged<VideoProgress>? onProgressChanged,
    ValueChanged<bool>? onFullscreenChanged,
    VoidCallback? onCompleted,
  }) {
    return VideoProgressPlayer(
      key: key,
      videoSource: FileVideoSource(file: file),
      controller: controller,
      resumeKey: resumeKey,
      config: config,
      theme: theme,
      storageProvider: storageProvider,
      analyticsProvider: analyticsProvider,
      completionStrategy: completionStrategy,
      controlsBuilder: controlsBuilder,
      onProgressChanged: onProgressChanged,
      onFullscreenChanged: onFullscreenChanged,
      onCompleted: onCompleted,
    );
  }

  @override
  State<VideoProgressPlayer> createState() => _VideoProgressPlayerState();
}

class _VideoProgressPlayerState extends State<VideoProgressPlayer>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  late VideoPlayerController _videoPlayerController;

  late VideoProgressController _controller;
  late VideoProgressConfig _config;
  late VideoProgressTheme _theme;
  late ProgressStorageProvider _storageProvider;
  late AnalyticsProvider _analyticsProvider;
  late CompletionStrategy _completionStrategy;

  bool _isInitialized = false;
  ProgressTracker? _progressTracker;

  bool _wasPlaying = false;
  Timer? _periodicSaveTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _applyDefaults();
    _log('Initializing VideoProgressPlayer...');
    _initPlayer();
  }

  void _log(String message) {
    if (_config.enableLogging) {
      debugPrint('[VideoProgressPlayer] $message');
    }
  }

  void _applyDefaults() {
    _controller = widget.controller ?? VideoProgressController();
    _config = widget.config ?? const VideoProgressConfig();
    _theme = widget.theme ?? const VideoProgressTheme();
    _storageProvider =
        widget.storageProvider ?? SharedPreferencesStorageProvider();
    _analyticsProvider =
        widget.analyticsProvider ?? const NoAnalyticsProvider();
    _completionStrategy =
        widget.completionStrategy ?? const PercentageCompletionStrategy(90);
  }

  @override
  void didUpdateWidget(VideoProgressPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.controller != oldWidget.controller) {
      _controller.detach();
    }

    final oldStorageProvider = _storageProvider;
    _applyDefaults();

    if (widget.controller != oldWidget.controller ||
        oldStorageProvider != _storageProvider) {
      _controller.attach(
        controller: _videoPlayerController,
        resumeKey: widget.resumeKey,
        storageProvider: _storageProvider,
        analyticsProvider: _analyticsProvider,
      );
    }

    if (oldWidget.videoSource != widget.videoSource ||
        oldWidget.resumeKey != widget.resumeKey) {
      _saveProgressSafely(oldWidget.resumeKey, oldStorageProvider, _config);
      _disposePlayer(skipSave: true);
      _initPlayer();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _saveCurrentProgress();
    }
  }

  Future<void> _initPlayer() async {
    final source = widget.videoSource;
    _log('Loading video source: $source');
    if (source is NetworkVideoSource) {
      _videoPlayerController =
          VideoPlayerController.networkUrl(Uri.parse(source.url));
    } else if (source is AssetVideoSource) {
      _videoPlayerController = VideoPlayerController.asset(source.assetPath);
    } else if (source is FileVideoSource) {
      _videoPlayerController = VideoPlayerController.file(source.file);
    } else {
      throw UnsupportedError('Unsupported VideoSource');
    }

    await _videoPlayerController.initialize();

    if (_config.enableResume && widget.resumeKey != null) {
      final savedProgress =
          await _storageProvider.loadProgress(widget.resumeKey!);
      if (savedProgress != null) {
        _log(
            'Resuming playback from ${savedProgress.watched} for key: ${widget.resumeKey}');
        await _videoPlayerController.seekTo(savedProgress.watched);
        _analyticsProvider.onResume(savedProgress.watched);
      } else {
        _log('No previous progress found for key: ${widget.resumeKey}');
      }
    }

    _controller.attach(
      controller: _videoPlayerController,
      resumeKey: widget.resumeKey,
      storageProvider: _storageProvider,
      analyticsProvider: _analyticsProvider,
    );

    if (widget.onFullscreenChanged != null) {
      _controller.onFullscreenChanged = widget.onFullscreenChanged;
    }

    _progressTracker = ProgressTracker(
      controller: _videoPlayerController,
      onProgressChanged: widget.onProgressChanged,
      completionStrategy: _completionStrategy,
      onCompleted: () {
        _log('Video completed! Firing onCompleted callbacks.');
        _analyticsProvider.onComplete();
        widget.onCompleted?.call();
        _saveCurrentProgress();
      },
    );

    _videoPlayerController.addListener(_onPlayerStateChanged);

    _periodicSaveTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (_videoPlayerController.value.isPlaying) {
        _saveCurrentProgress();
      }
    });

    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  void _onPlayerStateChanged() {
    final isPlaying = _videoPlayerController.value.isPlaying;
    if (_wasPlaying && !isPlaying) {
      _saveCurrentProgress();
    }
    _wasPlaying = isPlaying;
  }

  void _saveProgressSafely(String? resumeKey,
      ProgressStorageProvider storageProvider, VideoProgressConfig config) {
    if (config.enableResume && resumeKey != null && _isInitialized) {
      final duration = _videoPlayerController.value.duration;
      if (duration == Duration.zero) return;

      final progress = VideoProgress(
        watched: _videoPlayerController.value.position,
        total: duration,
        percentage: (_videoPlayerController.value.position.inMilliseconds /
                duration.inMilliseconds) *
            100,
      );
      _log(
          'Saving progress: ${progress.percentage.toStringAsFixed(1)}% (${progress.watched}) for key: $resumeKey');
      storageProvider.saveProgress(resumeKey, progress);
    }
  }

  void _saveCurrentProgress() {
    _saveProgressSafely(widget.resumeKey, _storageProvider, _config);
  }

  void _disposePlayer({bool skipSave = false, bool isDisposing = false}) {
    _log(
        'Disposing video player. skipSave=$skipSave, isDisposing=$isDisposing');
    if (!skipSave) _saveCurrentProgress();
    _periodicSaveTimer?.cancel();
    _progressTracker?.dispose();
    _videoPlayerController.removeListener(_onPlayerStateChanged);
    _controller.detach();
    _videoPlayerController.dispose();

    if (mounted && !isDisposing) {
      setState(() {
        _isInitialized = false;
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disposePlayer(isDisposing: true);
    FullscreenManager.exitFullscreen();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (!_isInitialized) {
      return Center(
        child: CircularProgressIndicator(color: _theme.primaryColor),
      );
    }

    return AspectRatio(
      aspectRatio: _videoPlayerController.value.aspectRatio,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          VideoPlayer(_videoPlayerController),
          if (widget.controlsBuilder != null)
            widget.controlsBuilder!(
                context, _controller, _videoPlayerController)
          else
            DefaultControls(
              controller: _videoPlayerController,
              videoProgressController: _controller,
              enablePlaybackSpeed: _config.enablePlaybackSpeed,
            ),
        ],
      ),
    );
  }
}
