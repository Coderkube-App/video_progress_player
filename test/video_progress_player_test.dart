import 'package:flutter_test/flutter_test.dart';
import 'package:video_progress_player/video_progress_player.dart';

void main() {
  test('VideoProgressPlayer instantiates correctly with NetworkVideoSource', () {
    final player =
        VideoProgressPlayer.network(url: 'https://example.com/video.mp4');

    expect(player, isNotNull);
    expect(player.videoSource, isA<NetworkVideoSource>());
  });
}
