import 'dart:async';
import 'dart:io';

import 'package:eazotel/features/whatsapp/controller/WhatsappImageController.dart.dart';
 import 'package:eazotel/features/whatsapp/screen/widgets/conversation/whatsappMediaPreview.dart';
import 'package:eazotel/features/whatsapp/screen/widgets/conversation/whatsappMessageTime.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

class WhatsappVideoMessage extends StatelessWidget {
  final String messageId;
  final dynamic media;
  final String? body;
  final String? createdAt;
  final String? status;
  final bool isIncoming;
  final String? ndid;

  const WhatsappVideoMessage({
    super.key,
    required this.messageId,
    required this.media,
    required this.body,
    required this.createdAt,
    required this.status,
    required this.isIncoming,
    required this.ndid,
  });

  String get tag => 'whatsapp_video_$messageId';

  @override
  Widget build(BuildContext context) {
    return GetX<WhatsappMediaController>(
      tag: tag,
      init: WhatsappMediaController(
        messageId: messageId,
        media: media,
        ndid: ndid,
        type: WhatsappMediaType.video,
      ),
      builder: (controller) {
        final path = controller.localPath.value;
        final downloading = controller.isDownloading.value;
        final ready =
            path != null && path.isNotEmpty && File(path).existsSync();

        final maxWidth = MediaQuery.of(context).size.width * 0.78;

        return Align(
          alignment: isIncoming ? Alignment.centerLeft : Alignment.centerRight,
          child: Container(
            margin: EdgeInsets.only(
              left: isIncoming ? 0 : 40,
              right: isIncoming ? 40 : 0,
              top: 3,
              bottom: 3,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                WhatsappMediaPreview(
                  controller: controller,
                  width: maxWidth,
                  height: 220,
                  showPlay: true,
                  onTap: downloading
                      ? null
                      : ready
                      ? () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  WhatsappVideoPlayerPage(path: path),
                            ),
                          );
                        }
                      : controller.download,
                ),
                const SizedBox(height: 2),
                WhatsappMessageTime(
                  createdAt: createdAt,
                  status: status,
                  isIncoming: isIncoming,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ================================================================
// VIDEO PLAYER PAGE
// ================================================================

class WhatsappVideoPlayerPage extends StatefulWidget {
  final String path;

  const WhatsappVideoPlayerPage({super.key, required this.path});

  @override
  State<WhatsappVideoPlayerPage> createState() =>
      _WhatsappVideoPlayerPageState();
}

class _WhatsappVideoPlayerPageState extends State<WhatsappVideoPlayerPage> {
  late final VideoPlayerController _video;

  bool _ready = false;
  bool _error = false;
  bool _showControls = true;
  bool _muted = false;
  double _speed = 1.0;

  Timer? _hideTimer;

  // ------------------------------------------------------------
  // Lifecycle
  // ------------------------------------------------------------

  void _listener() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();

    _video = VideoPlayerController.file(File(widget.path));
    _video.addListener(_listener);

    _video
        .initialize()
        .then((_) {
          if (!mounted) return;
          setState(() => _ready = true);
          _video.play();
          _startHideTimer();
        })
        .catchError((_) {
          if (!mounted) return;
          setState(() => _error = true);
        });
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _video.removeListener(_listener);
    _video.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------
  // Controls visibility
  // ------------------------------------------------------------

  void _startHideTimer() {
    _hideTimer?.cancel();

    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      if (_video.value.isPlaying) {
        setState(() => _showControls = false);
      }
    });
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);

    if (_showControls) _startHideTimer();
  }

  // ------------------------------------------------------------
  // Actions
  // ------------------------------------------------------------

  Future<void> _togglePlay() async {
    final value = _video.value;

    if (value.isPlaying) {
      await _video.pause();
      _hideTimer?.cancel();
      return;
    }

    // video khatam ho gaya ho to shuru se chalao
    if (value.duration > Duration.zero && value.position >= value.duration) {
      await _video.seekTo(Duration.zero);
    }

    await _video.play();
    _startHideTimer();
  }

  Future<void> _seekBy(Duration offset) async {
    final duration = _video.value.duration;

    var target = _video.value.position + offset;

    if (target < Duration.zero) target = Duration.zero;
    if (target > duration) target = duration;

    await _video.seekTo(target);
    _startHideTimer();
  }

  Future<void> _toggleMute() async {
    _muted = !_muted;
    await _video.setVolume(_muted ? 0.0 : 1.0);
    if (mounted) setState(() {});
    _startHideTimer();
  }

  Future<void> _setSpeed(double speed) async {
    _speed = speed;
    await _video.setPlaybackSpeed(speed);
    if (mounted) setState(() {});
    _startHideTimer();
  }

  String _format(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');

    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  // ------------------------------------------------------------
  // UI
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _ready ? _toggleControls : null,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ==================================================
              // VIDEO
              // ==================================================
              Center(child: _buildVideo()),

              // ==================================================
              // BUFFERING
              // ==================================================
              if (_ready && _video.value.isBuffering)
                const Center(child: CircularProgressIndicator()),

              // ==================================================
              // BACK BUTTON (loading / error ke time)
              // ==================================================
              if (!_ready)
                Positioned(
                  top: 0,
                  left: 0,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                ),

              // ==================================================
              // CONTROLS
              // ==================================================
              if (_ready)
                Positioned.fill(
                  child: IgnorePointer(
                    ignoring: !_showControls,
                    child: AnimatedOpacity(
                      opacity: _showControls ? 1 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: _buildControls(),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideo() {
    if (_error) {
      return const Text(
        'Unable to play this video',
        style: TextStyle(color: Colors.white),
      );
    }

    if (!_ready) {
      return const CircularProgressIndicator();
    }

    return AspectRatio(
      aspectRatio: _video.value.aspectRatio,
      child: VideoPlayer(_video),
    );
  }

  Widget _buildControls() {
    final value = _video.value;

    final maxMs = value.duration.inMilliseconds;

    final posMs = value.position.inMilliseconds.clamp(0, maxMs > 0 ? maxMs : 1);

    return Container(
      color: Colors.black38,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ------------------------------------------------
          // TOP BAR
          // ------------------------------------------------
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),

              const Spacer(),

              IconButton(
                onPressed: _toggleMute,
                icon: Icon(
                  _muted ? Icons.volume_off : Icons.volume_up,
                  color: Colors.white,
                ),
              ),

              PopupMenuButton<double>(
                tooltip: 'Speed',
                initialValue: _speed,
                onSelected: _setSpeed,
                icon: const Icon(Icons.speed, color: Colors.white),
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 0.5, child: Text('0.5x')),
                  PopupMenuItem(value: 1.0, child: Text('1x (Normal)')),
                  PopupMenuItem(value: 1.5, child: Text('1.5x')),
                  PopupMenuItem(value: 2.0, child: Text('2x')),
                ],
              ),
            ],
          ),

          // ------------------------------------------------
          // CENTER: -10s / PLAY / +10s
          // ------------------------------------------------
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                iconSize: 40,
                color: Colors.white,
                onPressed: () => _seekBy(const Duration(seconds: -10)),
                icon: const Icon(Icons.replay_10),
              ),

              const SizedBox(width: 20),

              IconButton(
                iconSize: 64,
                color: Colors.white,
                onPressed: _togglePlay,
                icon: Icon(
                  value.isPlaying
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_filled,
                ),
              ),

              const SizedBox(width: 20),

              IconButton(
                iconSize: 40,
                color: Colors.white,
                onPressed: () => _seekBy(const Duration(seconds: 10)),
                icon: const Icon(Icons.forward_10),
              ),
            ],
          ),

          // ------------------------------------------------
          // BOTTOM: TIME + SEEK BAR
          // ------------------------------------------------
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: Row(
              children: [
                Text(
                  _format(value.position),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),

                Expanded(
                  child: Slider(
                    min: 0,
                    max: maxMs > 0 ? maxMs.toDouble() : 1,
                    value: posMs.toDouble(),
                    activeColor: Colors.white,
                    inactiveColor: Colors.white30,
                    onChangeStart: (_) => _hideTimer?.cancel(),
                    onChanged: (v) {
                      _video.seekTo(Duration(milliseconds: v.toInt()));
                    },
                    onChangeEnd: (_) => _startHideTimer(),
                  ),
                ),

                Text(
                  _format(value.duration),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
