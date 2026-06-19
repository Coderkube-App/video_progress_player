class VideoProgressConfig {
  final bool enableResume;
  final bool enablePlaybackSpeed;
  final int completionThreshold;
  final bool enableLogging;

  const VideoProgressConfig({
    this.enableResume = false,
    this.enablePlaybackSpeed = false,
    this.completionThreshold = 90,
    this.enableLogging = true,
  });
}
