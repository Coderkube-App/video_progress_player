## 0.0.1

* **Initial Release:** `video_progress_player` - A focused, extensible Flutter package for video playback and progress tracking.
* **Core:** `VideoProgressPlayer` orchestrator widget.
* **Architecture:** Injects `ProgressStorageProvider` and `AnalyticsProvider` for decoupled data persistence and event tracking.
* **Sources:** Extensible `VideoSource` layer (`NetworkVideoSource`, `AssetVideoSource`, `FileVideoSource`).
* **Strategies:** `PercentageCompletionStrategy` included out of the box.
* **Ergonomics:** Simple `.network`, `.asset`, and `.file` factory constructors.
