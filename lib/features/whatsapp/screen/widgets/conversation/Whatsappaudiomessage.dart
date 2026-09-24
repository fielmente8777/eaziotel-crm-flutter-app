import 'package:audioplayers/audioplayers.dart';
import 'package:eazotel/features/whatsapp/controller/WhatsappImageController.dart.dart';
import 'package:eazotel/features/whatsapp/screen/widgets/conversation/whatsappMessageTime.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WhatsappAudioMessage extends StatefulWidget {
  final String messageId;
  final dynamic media;
  final String? body;
  final String? createdAt;
  final String? status;
  final bool isIncoming;
  final String? ndid;

  const WhatsappAudioMessage({
    super.key,
    required this.messageId,
    required this.media,
    required this.body,
    required this.createdAt,
    required this.status,
    required this.isIncoming,
    required this.ndid,
  });

  @override
  State<WhatsappAudioMessage> createState() => _WhatsappAudioMessageState();
}

class _WhatsappAudioMessageState extends State<WhatsappAudioMessage> {
  late final String _tag;
  late final WhatsappMediaController c;

  final AudioPlayer _player = AudioPlayer();

  bool _playing = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();

    _tag = 'whatsapp_audio_${widget.messageId}';

    c = Get.isRegistered<WhatsappMediaController>(tag: _tag)
        ? Get.find<WhatsappMediaController>(tag: _tag)
        : Get.put(
            WhatsappMediaController(
              messageId: widget.messageId,
              media: widget.media,
              ndid: widget.ndid,
              type: WhatsappMediaType.audio,
            ),
            tag: _tag,
          );

    _player.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
      setState(() => _playing = state == PlayerState.playing);
    });

    _player.onPositionChanged.listen((p) {
      if (!mounted) return;
      setState(() => _position = p);
    });

    _player.onDurationChanged.listen((d) {
      if (!mounted) return;
      setState(() => _duration = d);
    });

    _player.onPlayerComplete.listen((_) {
      if (!mounted) return;
      setState(() {
        _playing = false;
        _position = Duration.zero;
      });
    });
  }

  @override
  void dispose() {
    _player.dispose();

    if (Get.isRegistered<WhatsappMediaController>(tag: _tag)) {
      Get.delete<WhatsappMediaController>(tag: _tag);
    }

    super.dispose();
  }

  Future<void> _onTap() async {
    if (c.isDownloading.value) return;

    if (!c.isDownloaded) {
      await c.download();
      if (!c.isDownloaded) return;
    }

    if (_playing) {
      await _player.pause();
    } else if (_player.state == PlayerState.paused) {
      await _player.resume();
    } else {
      await _player.play(DeviceFileSource(c.localPath.value!));
    }
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final incoming = widget.isIncoming;

    final maxMs = _duration.inMilliseconds;
    final value = maxMs > 0
        ? (_position.inMilliseconds / maxMs).clamp(0.0, 1.0)
        : 0.0;

    return Align(
      alignment: incoming ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.78,
        margin: EdgeInsets.only(
          left: incoming ? 0 : 40,
          right: incoming ? 40 : 0,
          top: 3,
          bottom: 3,
        ),
        padding: const EdgeInsets.fromLTRB(6, 6, 10, 4),
        decoration: BoxDecoration(
          color: incoming
              ? Theme.of(context).cardColor
              : const Color(0xffd9fdd3),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Obx(() {
              final downloading = c.isDownloading.value;
              final downloaded = c.isDownloaded;

              return Row(
                children: [
                  if (downloading)
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          value: c.progress.value > 0 ? c.progress.value : null,
                          strokeWidth: 2.5,
                        ),
                      ),
                    )
                  else
                    IconButton(
                      onPressed: _onTap,
                      icon: Icon(
                        !downloaded
                            ? Icons.download
                            : (_playing ? Icons.pause : Icons.play_arrow),
                      ),
                    ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Audio message',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 5),
                        LinearProgressIndicator(value: value),
                        const SizedBox(height: 3),
                        Text(
                          '${_fmt(_position)} / ${_fmt(_duration)}',
                          style: const TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),
            Align(
              alignment: Alignment.centerRight,
              child: WhatsappMessageTime(
                createdAt: widget.createdAt,
                status: widget.status,
                isIncoming: widget.isIncoming,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
