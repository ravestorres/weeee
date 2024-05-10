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
    this.onNext,
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
        _trackLength = _formatDuration(_duration);
      });
    });
    widget.audioPlayer.positionStream.listen((position) {
      setState(() {
        _position = position ?? Duration.zero;
        _currentPosition = _formatDuration(_position);
      });
    });
    _loadSong(widget.songPath); // Load the initial song
  }

  @override
  void didUpdateWidget(covariant PlayerBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.songPath != oldWidget.songPath) {
      _loadSong(widget.songPath);
    }
  }

  void _loadSong(String songPath) async {
    try {
      await widget.audioPlayer.setFilePath(songPath);
      widget.audioPlayer.play(); // Start playback after loading the song
      setState(() {
        isPlaying = true; // Update UI state to indicate playback started
      });
    } catch (e) {
      print('Error loading audio: $e');
      // Handle the error, such as displaying a message to the user
      // or falling back to a default song.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0),
      color: Colors.grey[200],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _currentPosition,
                style: TextStyle(fontSize: 16),
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
                  onChangeEnd: (value) {
                    final newPosition = Duration(milliseconds: value.toInt());
                    widget.audioPlayer.seek(newPosition);
                  },
                ),
              ),
              Text(
                _trackLength,
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.volume_down),
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
                onChangeEnd: (value) {
                  setVolume(value);
                },
              ),
              IconButton(
                icon: Icon(Icons.volume_up),
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
                icon: Icon(Icons.skip_previous),
                onPressed: widget.onPrevious,
              ),
              IconButton(
                icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                onPressed: _playPause,
              ),
              IconButton(
                icon: Icon(Icons.skip_next),
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
      widget.audioPlayer.pause();
    } else {
      widget.audioPlayer.play();
    }
    setState(() {
      isPlaying = !isPlaying;
    });
  }
}
