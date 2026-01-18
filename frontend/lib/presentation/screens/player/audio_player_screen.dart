import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../../core/theme/app_colors.dart';

class AudioPlayerScreen extends StatefulWidget {
  final String filePath;
  final String? title;
  final String? artist; // Optionally used for platform name
  final String? thumbnailUrl;

  const AudioPlayerScreen({
    super.key,
    required this.filePath,
    this.title,
    this.artist,
    this.thumbnailUrl,
  });

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;
  String? _error;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      final file = File(widget.filePath);
      if (!await file.exists()) {
        throw Exception('File does not exist');
      }

      _controller = VideoPlayerController.file(file);
      await _controller.initialize();

      setState(() {
        _isInitialized = true;
        _duration = _controller.value.duration;
      });

      _controller.addListener(() {
        if (!mounted) return;
        setState(() {
          _position = _controller.value.position;
          _isPlaying = _controller.value.isPlaying;
          if (_controller.value.isCompleted) {
            _isPlaying = false;
            _position = Duration.zero;
            _controller.seekTo(Duration.zero);
            _controller.pause();
          }
        });
      });

      // Auto play
      _togglePlay();
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
        });
      }
    }
  }

  void _togglePlay() {
    if (!_isInitialized) return;

    if (_controller.value.isPlaying) {
      _controller.pause();
    } else {
      _controller.play();
    }
  }

  void _seekTo(double value) {
    if (!_isInitialized) return;
    final position = Duration(milliseconds: value.toInt());
    _controller.seekTo(position);
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "${duration.inHours > 0 ? '${twoDigits(duration.inHours)}:' : ''}$minutes:$seconds";
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: AppColors.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32.0,
                    vertical: 24.0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_error != null)
                        Center(
                          child: Text(
                            'Error: $_error',
                            style: const TextStyle(color: AppColors.error),
                          ),
                        )
                      else ...[
                        // Album Art / Placeholder
                        Container(
                          width: 280,
                          height: 280,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Icon(
                              Icons.music_note,
                              size: 120,
                              color: AppColors.primary.withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                        const SizedBox(height: 48),

                        // Title & Metadata
                        Text(
                          widget.title ?? 'Unknown Track',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (widget.artist != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            widget.artist!.toUpperCase(),
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],

                        const SizedBox(height: 48),

                        // Progress Bar
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 4,
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 8,
                            ),
                            overlayShape: const RoundSliderOverlayShape(
                              overlayRadius: 16,
                            ),
                            activeTrackColor: AppColors.primary,
                            inactiveTrackColor: AppColors.surface,
                            thumbColor: AppColors.primary,
                            overlayColor: AppColors.primary.withValues(
                              alpha: 0.2,
                            ),
                          ),
                          child: Slider(
                            value: _position.inMilliseconds.toDouble().clamp(
                              0,
                              _duration.inMilliseconds.toDouble(),
                            ),
                            min: 0,
                            max: _duration.inMilliseconds.toDouble() > 0
                                ? _duration.inMilliseconds.toDouble()
                                : 1.0,
                            onChanged: (value) {
                              // Optional: Create a "scrubbing" state
                            },
                            onChangeEnd: (value) => _seekTo(value),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDuration(_position),
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                _formatDuration(_duration),
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 48),

                        // Controls
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.replay_10,
                                size: 32,
                                color: AppColors.textSecondary,
                              ),
                              onPressed: () {
                                if (!_isInitialized) return;
                                _seekTo(
                                  (_position.inMilliseconds - 10000)
                                      .toDouble()
                                      .clamp(
                                        0.0,
                                        _duration.inMilliseconds.toDouble(),
                                      ),
                                );
                              },
                            ),
                            const SizedBox(width: 32),
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.4,
                                    ),
                                    blurRadius: 16,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: IconButton(
                                icon: Icon(
                                  _isPlaying ? Icons.pause : Icons.play_arrow,
                                  size: 40,
                                  color: Colors.white,
                                ),
                                onPressed: _togglePlay,
                              ),
                            ),
                            const SizedBox(width: 32),
                            IconButton(
                              icon: const Icon(
                                Icons.forward_10,
                                size: 32,
                                color: AppColors.textSecondary,
                              ),
                              onPressed: () {
                                if (!_isInitialized) return;
                                _seekTo(
                                  (_position.inMilliseconds + 10000)
                                      .toDouble()
                                      .clamp(
                                        0.0,
                                        _duration.inMilliseconds.toDouble(),
                                      ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
