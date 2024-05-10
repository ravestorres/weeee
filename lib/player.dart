import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class PlayerBar extends StatefulWidget {
  final String songPath;
  final AudioPlayer audioPlayer;
  final int currentIndex;
  final List<String> songs;
  final Function(int) onSongChanged;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  const PlayerBar({
    Key? key,
    required this.songPath,
    required this.audioPlayer,
    required this.currentIndex,
    required this.songs,
    required this.onSongChanged,
    this.onPrevious,
    this.onNext, Duration? currentPosition,
  }) : super(key: key);

  @override
  _PlayerBarState createState() => _PlayerBarState();
}
class _PlayerBarState extends State<PlayerBar> {
  late bool isPlaying;
  late double volume = 1.0;
  late Duration _duration;
  late Duration _position;
  late String _trackLength;
  late String _currentPosition;

  @override
  void initState() {
    super.initState();
    isPlaying = true;
    _duration = Duration.zero;
    _position = Duration.zero;
    _trackLength = '0:00';
    _currentPosition = '0:00';
    widget.audioPlayer.setVolume(volume);
    widget.audioPlayer.durationStream.listen((duration) {
      setState(() {
        _duration = duration ?? Duration.zero;
        _trackLength = _formatDuration(_duration); // Update track length here
      });
    });
    widget.audioPlayer.positionStream.listen((position) {
      setState(() {
        _position = position ?? Duration.zero;
        _currentPosition = _formatDuration(_position);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0),
      color: Colors.black,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _currentPosition,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              Expanded(
                child: Slider(
                  value: _position.inMilliseconds.toDouble(),
                  onChanged: (value) {
                    final newPosition = Duration(milliseconds: value.toInt());
                    widget.audioPlayer.seek(newPosition);
                  },
                  min: 0,
                  max: _duration.inMilliseconds.toDouble(),
                  activeColor: Colors.white,
                  inactiveColor: Colors.grey[600],
                ),
              ),
              Text(
                _trackLength,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.volume_down, color: Colors.white),
                onPressed: () {
                  setVolume(volume - 0.1);
                },
              ),
              Slider(
                value: volume,
                onChanged: (value) {
                  setVolume(value);
                },
                min: 0.0,
                max: 1.0,
                activeColor: Colors.white,
                inactiveColor: Colors.grey[600],
              ),
              IconButton(
                icon: Icon(Icons.volume_up, color: Colors.white),
                onPressed: () {
                  setVolume(volume + 0.1);
                },
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.skip_previous, color: Colors.white),
                onPressed: widget.onPrevious,
              ),
              IconButton(
                icon: Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                ),
                onPressed: _playPause,
              ),
              IconButton(
                icon: Icon(Icons.skip_next, color: Colors.white),
                onPressed: widget.onNext,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void setVolume(double newVolume) {
    setState(() {
      volume = newVolume.clamp(0.0, 1.0);
    });
    widget.audioPlayer.setVolume(volume);
  }

  void _playPause() {
    if (isPlaying) {
      print('Pausing audio');
      widget.audioPlayer.pause();
    } else {
      print('Resuming audio');
      widget.audioPlayer.play();
    }
    setState(() {
      isPlaying = !isPlaying;
    });
  }
}
