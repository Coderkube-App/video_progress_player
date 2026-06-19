import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:video_progress_player/video_progress_player.dart';

void main() {
  group('VideoProgressPlayer Widget Tests', () {
    testWidgets('VideoProgressPlayer renders loading indicator initially',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VideoProgressPlayer.network(
              url:
                  'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
            ),
          ),
        ),
      );

      // Verify that a CircularProgressIndicator is rendered while video initializes
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Progress callback can be passed successfully',
        (WidgetTester tester) async {
      bool callbackFired = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VideoProgressPlayer.network(
              url:
                  'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
              onProgressChanged: (progress) {
                callbackFired = true;
              },
            ),
          ),
        ),
      );

      expect(callbackFired, isFalse);
    });

    testWidgets('Completion callback can be passed successfully',
        (WidgetTester tester) async {
      bool completionFired = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VideoProgressPlayer.network(
              url:
                  'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
              onCompleted: () {
                completionFired = true;
              },
            ),
          ),
        ),
      );

      expect(completionFired, isFalse);
    });
  });
}
