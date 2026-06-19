import 'video_source.dart';

class NetworkVideoSource extends VideoSource {
  final String url;
  
  const NetworkVideoSource({required this.url});

  @override
  bool operator ==(Object other) => identical(this, other) || other is NetworkVideoSource && runtimeType == other.runtimeType && url == other.url;

  @override
  int get hashCode => url.hashCode;
}
