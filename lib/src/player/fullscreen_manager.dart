import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class FullscreenManager {
  static const MethodChannel _channel = MethodChannel('com.apogee/orientation');

  static Future<void> enterFullscreen() async {
    debugPrint(
        '[FullscreenManager] Entering fullscreen. Forcing landscape orientation.');
    try {
      if (!kIsWeb && Platform.isIOS) {
        debugPrint(
            '[FullscreenManager] Invoking iOS MethodChannel toLandscape');
        await _channel.invokeMethod('toLandscape');
      }
    } catch (_) {
      // Ignore if channel is not implemented
    }

    try {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } catch (e) {
      debugPrint(
          '[FullscreenManager] Warning: SystemChrome failed on this platform.');
    }
  }

  static Future<void> exitFullscreen() async {
    debugPrint(
        '[FullscreenManager] Exiting fullscreen. Reverting to portrait orientation.');
    try {
      if (!kIsWeb && Platform.isIOS) {
        debugPrint('[FullscreenManager] Invoking iOS MethodChannel toPortrait');
        await _channel.invokeMethod('toPortrait');
      }
    } catch (_) {
      // Ignore if channel is not implemented
    }

    try {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
      await SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: SystemUiOverlay.values,
      );
    } catch (e) {
      debugPrint(
          '[FullscreenManager] Warning: SystemChrome failed on this platform.');
    }
  }
}
