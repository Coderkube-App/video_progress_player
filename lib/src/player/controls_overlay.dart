import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../controller/video_progress_controller.dart';

class DefaultControls extends StatefulWidget {
  final VideoPlayerController controller;
  final VideoProgressController? videoProgressController;
  final bool enablePlaybackSpeed;
  final bool isFullscreen;

  const DefaultControls({
    super.key,
    required this.controller,
    this.videoProgressController,
    this.enablePlaybackSpeed = false,
    this.isFullscreen = false,
  });

  @override
  State<DefaultControls> createState() => _DefaultControlsState();
}

class _DefaultControlsState extends State<DefaultControls> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        ValueListenableBuilder(
          valueListenable: widget.controller,
          builder: (context, VideoPlayerValue value, child) {
            final isPlaying = value.isPlaying;
            final isFinished = value.duration.inMilliseconds > 0 &&
                value.position >= value.duration;

            Widget centerChild;
            if (value.isBuffering) {
              centerChild = Container(
                key: const ValueKey('buffering'),
                color: Colors.black26,
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              );
            } else if (isPlaying) {
              centerChild = const SizedBox.shrink(key: ValueKey('playing'));
            } else {
              centerChild = Container(
                key: const ValueKey('paused'),
                color: Colors.black26,
                child: Center(
                  child: Icon(
                    isFinished ? Icons.replay : Icons.play_arrow,
                    color: Colors.white,
                    size: 60.0,
                  ),
                ),
              );
            }

            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 50),
              reverseDuration: const Duration(milliseconds: 200),
              child: centerChild,
            );
          },
        ),
        GestureDetector(
          onTap: () {
            final value = widget.controller.value;
            final isFinished = value.duration.inMilliseconds > 0 &&
                value.position >= value.duration;

            if (isFinished) {
              widget.controller.seekTo(Duration.zero);
              widget.videoProgressController?.play() ??
                  widget.controller.play();
            } else {
              value.isPlaying
                  ? widget.videoProgressController?.pause() ??
                      widget.controller.pause()
                  : widget.videoProgressController?.play() ??
                      widget.controller.play();
            }
          },
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            color: Colors.black54,
            child: Row(
              children: [
                ValueListenableBuilder(
                  valueListenable: widget.controller,
                  builder: (context, VideoPlayerValue value, child) {
                    final position = value.position;
                    final duration = value.duration;
                    final isPlaying = value.isPlaying;
                    final isFinished =
                        duration.inMilliseconds > 0 && position >= duration;

                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            isFinished
                                ? Icons.replay
                                : (isPlaying ? Icons.pause : Icons.play_arrow),
                            color: Colors.white,
                          ),
                          onPressed: () {
                            if (isFinished) {
                              widget.controller.seekTo(Duration.zero);
                              widget.videoProgressController?.play() ??
                                  widget.controller.play();
                            } else {
                              isPlaying
                                  ? widget.videoProgressController?.pause() ??
                                      widget.controller.pause()
                                  : widget.videoProgressController?.play() ??
                                      widget.controller.play();
                            }
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            '${_formatDuration(position)} / ${_formatDuration(duration)}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                Expanded(
                  child: VideoProgressIndicator(
                    widget.controller,
                    allowScrubbing: true,
                    colors: const VideoProgressColors(
                      playedColor: Colors.blueAccent,
                    ),
                  ),
                ),
                if (widget.enablePlaybackSpeed)
                  PopupMenuButton<double>(
                    initialValue: widget.controller.value.playbackSpeed,
                    tooltip: 'Playback speed',
                    onSelected: (speed) {
                      widget.videoProgressController?.setPlaybackSpeed(speed) ??
                          widget.controller.setPlaybackSpeed(speed);
                    },
                    itemBuilder: (context) {
                      return [
                        for (final speed in [0.5, 1.0, 1.25, 1.5, 1.75, 2.0])
                          PopupMenuItem(
                            value: speed,
                            child: Text('${speed}x'),
                          )
                      ];
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        '${widget.controller.value.playbackSpeed}x',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                IconButton(
                  icon: Icon(
                    widget.isFullscreen
                        ? Icons.fullscreen_exit
                        : Icons.fullscreen,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    if (widget.isFullscreen) {
                      Navigator.of(context).pop();
                    } else {
                      widget.videoProgressController?.enterFullscreen();
                      Navigator.of(context)
                          .push(
                        MaterialPageRoute(
                          builder: (context) => Scaffold(
                            backgroundColor: Colors.black,
                            body: SafeArea(
                              child: Center(
                                child: AspectRatio(
                                  aspectRatio:
                                      widget.controller.value.aspectRatio,
                                  child: Stack(
                                    alignment: Alignment.bottomCenter,
                                    children: [
                                      VideoPlayer(widget.controller),
                                      DefaultControls(
                                        controller: widget.controller,
                                        videoProgressController:
                                            widget.videoProgressController,
                                        enablePlaybackSpeed:
                                            widget.enablePlaybackSpeed,
                                        isFullscreen: true,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                          .then((_) {
                        widget.videoProgressController?.exitFullscreen();
                      });
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${duration.inHours > 0 ? '${twoDigits(duration.inHours)}:' : ''}$twoDigitMinutes:$twoDigitSeconds";
  }
}
