import 'dart:io';
import 'video_source.dart';

class FileVideoSource extends VideoSource {
  final File file;
  
  const FileVideoSource({required this.file});

  @override
  bool operator ==(Object other) => identical(this, other) || other is FileVideoSource && runtimeType == other.runtimeType && file.path == other.file.path;

  @override
  int get hashCode => file.path.hashCode;
}
