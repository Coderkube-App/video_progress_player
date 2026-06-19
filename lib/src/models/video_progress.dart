class VideoProgress {
  final Duration watched;
  final Duration total;
  final double percentage;

  const VideoProgress({
    required this.watched,
    required this.total,
    required this.percentage,
  });
}
