abstract class AnalyticsProvider {
  void onPlay();
  void onPause();
  void onSeek(Duration from, Duration to);
  void onResume(Duration position);
  void onComplete();
  void onFullscreen(bool isFullscreen);
}
