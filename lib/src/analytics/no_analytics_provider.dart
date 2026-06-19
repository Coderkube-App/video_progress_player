import 'analytics_provider.dart';

class NoAnalyticsProvider implements AnalyticsProvider {
  const NoAnalyticsProvider();

  @override
  void onPlay() {}
  @override
  void onPause() {}
  @override
  void onSeek(Duration from, Duration to) {}
  @override
  void onResume(Duration position) {}
  @override
  void onComplete() {}
  @override
  void onFullscreen(bool isFullscreen) {}
}
