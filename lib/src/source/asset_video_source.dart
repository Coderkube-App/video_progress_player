import 'video_source.dart';

class AssetVideoSource extends VideoSource {
  final String assetPath;
  
  const AssetVideoSource({required this.assetPath});

  @override
  bool operator ==(Object other) => identical(this, other) || other is AssetVideoSource && runtimeType == other.runtimeType && assetPath == other.assetPath;

  @override
  int get hashCode => assetPath.hashCode;
}
