import 'package:flutter/material.dart';
import 'package:video_progress_player/video_progress_player.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Course Video Player Examples')),
        body: ListView(
          children: const [
            ListTile(title: Text('1. Basic Network Video')),
            SizedBox(
              height: 250,
              child: BasicExample(),
            ),
            ListTile(title: Text('2. Resume & Completion Tracking')),
            SizedBox(
              height: 250,
              child: ResumeExample(),
            ),
            ListTile(title: Text('3. Advanced Analytics')),
            SizedBox(
              height: 250,
              child: AdvancedExample(),
            ),
          ],
        ),
      ),
    );
  }
}

class BasicExample extends StatelessWidget {
  const BasicExample({super.key});
  @override
  Widget build(BuildContext context) {
    return VideoProgressPlayer.network(
      url:
          'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
    );
  }
}

class ResumeExample extends StatelessWidget {
  const ResumeExample({super.key});
  @override
  Widget build(BuildContext context) {
    return VideoProgressPlayer.network(
      url:
          'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
      resumeKey: 'lesson_1',
      onCompleted: () => debugPrint('Lesson completed!'),
    );
  }
}

class AdvancedExample extends StatelessWidget {
  const AdvancedExample({super.key});
  @override
  Widget build(BuildContext context) {
    return const VideoProgressPlayer(
      videoSource:
          NetworkVideoSource(url: 'https://www.w3schools.com/html/mov_bbb.mp4'),
      analyticsProvider: NoAnalyticsProvider(), // Inject custom analytics here
      config:
          VideoProgressConfig(enableResume: true, enablePlaybackSpeed: true),
    );
  }
}
