# video_progress_player

A Flutter video player built on top of `video_player` with resume watching, progress tracking, completion detection, and fullscreen support.

Designed for learning platforms, coaching apps, fitness apps, and any application that needs to track user video progress.

## Features

* Resume watching automatically
* Track video progress
* Completion detection
* Fullscreen support
* Analytics integration
* Custom controls
* Custom storage providers
* Network, Asset, and File video support

## Why video_progress_player?

Building a video-based learning experience usually requires more than simply playing a video.

Many applications need to:

* Save and restore the user's last watched position
* Track watch progress
* Detect when a video is completed
* Trigger analytics events
* Handle fullscreen orientation changes
* Integrate with custom databases and APIs

video_progress_player provides these capabilities out of the box while remaining flexible and backend-agnostic.

The package focuses on reducing the amount of boilerplate required to build learning, coaching, training, and fitness applications that rely on video content.

### Use Cases

This package is a good fit for:

* Learning Management Systems (LMS)
* Online Courses
* Coaching Platforms
* Fitness Applications
* Employee Training Systems
* Certification Programs
* Video-Based Onboarding Flows

### Key Benefits

* Simple setup with sensible defaults
* Resume watching across app sessions
* Built-in progress tracking
* Configurable completion detection
* Analytics integration points
* Custom storage support
* Custom controls support
* Fullscreen and orientation management
* Works with Network, Asset, and File videos

## Supported Platforms

| Platform | Supported |
| :--- | :--- |
| **Android** | Yes |
| **iOS** | Yes |
| **iPadOS** | Yes |
| **Web** | Based on video_player support |
| **macOS** | Based on video_player support |
| **Windows** | Based on video_player support |
| **Linux** | Based on video_player support |

## Installation

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  video_progress_player: ^0.0.1
```

Then run:

```bash
flutter pub get
```

## Native Setup

Since this package streams video over the internet and manages device orientation, you must configure native permissions for Android and iOS.

### Android Setup
Open `android/app/src/main/AndroidManifest.xml` and add the Internet permission above the `<application>` tag:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
```
*(Optional: If you are streaming HTTP instead of HTTPS, also add `android:usesCleartextTraffic="true"` to the `<application>` tag).*

### iOS Setup

No additional configuration is required for HTTPS video URLs.

If you need to stream non-secure HTTP content, configure App Transport Security (ATS) in your `Info.plist` according to Apple's guidelines.

## Quick Start

The simplest way to use the package:

```dart
import 'package:video_progress_player/video_progress_player.dart';

VideoProgressPlayer.network(
  url: 'https://example.com/video.mp4',
)
```

## Resume Watching

Provide a `resumeKey` to automatically save and restore the user's last watched position.

```dart
VideoProgressPlayer.network(
  url: 'https://example.com/video.mp4',
  resumeKey: 'lesson_1',
)
```

## Progress Tracking

Listen to progress updates:

```dart
VideoProgressPlayer.network(
  url: 'https://example.com/video.mp4',
  onProgressChanged: (progress) {
    print(progress.percentage);
  },
)
```

### VideoProgress

```dart
VideoProgress(
  watched: Duration,
  total: Duration,
  percentage: double,
)
```

## Completion Tracking

Receive a callback when a video reaches the completion threshold.

```dart
VideoProgressPlayer.network(
  url: 'https://example.com/video.mp4',
  onCompleted: () {
    print('Video completed');
  },
)
```

### Custom Completion Threshold

```dart
VideoProgressPlayer.network(
  url: 'https://example.com/video.mp4',
  completionStrategy: PercentageCompletionStrategy(95),
)
```

## Controller

Control playback programmatically.

```dart
final controller = VideoProgressController();

VideoProgressPlayer.network(
  url: videoUrl,
  controller: controller,
);
```

### Available Methods

```dart
controller.play();

controller.pause();

controller.seekTo(
  const Duration(minutes: 5),
);

controller.setPlaybackSpeed(1.5);

controller.enterFullscreen();

controller.exitFullscreen();
```

## Analytics Integration

Create a custom analytics provider:

```dart
class MyAnalyticsProvider implements AnalyticsProvider {
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
```

Use it:

```dart
VideoProgressPlayer.network(
  url: videoUrl,
  analyticsProvider: MyAnalyticsProvider(),
)
```

## Custom Storage

Store progress in your own backend:

```dart
class FirebaseStorageProvider
    implements ProgressStorageProvider {

  @override
  Future<void> saveProgress(
    String key,
    VideoProgress progress,
  ) async {
    // Save progress
  }

  @override
  Future<VideoProgress?> loadProgress(
    String key,
  ) async {
    // Load progress
    return null;
  }
}
```

Use it:

```dart
VideoProgressPlayer.network(
  url: videoUrl,
  resumeKey: 'lesson_1',
  storageProvider: FirebaseStorageProvider(),
)
```

## Custom Controls

Replace the default controls with your own UI.

```dart
VideoProgressPlayer(
  videoSource: NetworkVideoSource(
    url: videoUrl,
  ),
  controlsBuilder: (
    context,
    controller,
    videoController,
  ) {
    return MyCustomControls();
  },
)
```

## Supported Sources

### Network Video

```dart
NetworkVideoSource(
  url: videoUrl,
)
```

### Asset Video

```dart
AssetVideoSource(
  assetPath: 'assets/video.mp4',
)
```

### File Video

```dart
FileVideoSource(
  file: videoFile,
)
```

## Fullscreen Support

Built-in fullscreen support includes:

* Android fullscreen mode
* iPhone fullscreen mode
* iPad support
* Orientation restoration
* Immersive mode

Listen for fullscreen changes:

```dart
VideoProgressPlayer.network(
  url: videoUrl,
  onFullscreenChanged: (isFullscreen) {},
)
```

### iOS / Android Orientation Setup

If your app is strictly portrait-only, but you want to allow landscape *only* when the video is in fullscreen, you must **enable all orientations in your OS settings**:

1. **iOS:** Check `Landscape Left` and `Landscape Right` in XCode (`Info.plist`).
2. **Android:** Do not restrict orientation in `AndroidManifest.xml`.

Then, force your app into portrait at the top level in your `main.dart`:

```dart
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  runApp(MyApp());
}
```

This allows `video_progress_player` to temporarily override the portrait lock when the user taps the fullscreen button!

## Example App

A complete example application is available in the `example/` folder.

It demonstrates:

* Basic playback
* Resume watching
* Progress tracking
* Completion detection
* Custom analytics integration
* Custom storage providers
* Fullscreen handling

## Roadmap

Future releases may include:

* YouTube support
* Vimeo support
* Additional completion strategies
* Offline video support

## Contributing

Issues and pull requests are welcome.

## License

Apache License 2.0
