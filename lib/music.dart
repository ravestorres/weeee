import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/card.dart';
import 'package:flutter_application_1/player.dart';
import 'package:just_audio/just_audio.dart';

class Song {
  final String title;
  final String artist;
  final String album;
  final String assetPath;
  final String albumCoverPath;

  Song({
    required this.title,
    required this.artist,
    required this.album,
    required this.assetPath,
    required this.albumCoverPath,
  });
}

class MusicScreen extends StatefulWidget {
  @override
  _MusicScreenState createState() => _MusicScreenState();
}



class _MusicScreenState extends State<MusicScreen> {
  late AudioPlayer _audioPlayer;
  late bool isPlaying;
  late List<Song> _songs;
  late Song _currentSong;
  late String playlist;
  Duration? _position;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    fetchWeatherData();
    _audioPlayer.positionStream.listen((event) {
      setState(() {
        _position = event;
      });
    });
  }

  void fetchWeatherData() {
    double temperature = 20; // Assume 20 degrees
    bool isRaining = true; // Assume it's raining

    if (temperature <= 20 && isRaining) {
      setState(() {
        playlist = 'Rainy Playlist';
        _songs = _getRainyPlaylist();
        _playRandomTrack();
      });
    } else {
      setState(() {
        playlist = 'Sunny Playlist';
        _songs = _getSunnyPlaylist();
        _playRandomTrack();
      });
    }
  }

  void _playRandomTrack() {
    Random random = Random();
    int randomIndex = random.nextInt(_songs.length);
    _currentSong = _songs[randomIndex];
    _loadSong();
  }

  List<Song> _getSunnyPlaylist() {
    // Define your sunny playlist songs here
    return [
      Song(
        title: 'Red Flavor',
        artist: 'Red Velvet',
        album: 'Album 1',
        assetPath: 'assets/musics/sunny/1.mp3',
       albumCoverPath: 'assets/musics/images/sunny/1.jpg',
      ),
      Song(
        title: 'Hype Boy',
        artist: 'NewJeans',
        album: 'Album 2',
        assetPath: 'assets/musics/sunny/2.mp3',
       albumCoverPath: 'assets/musics/images/sunny/2.jpg',
      ),
      Song(
        title: 'SHAKE IT',
        artist: 'SISTAR',
        album: 'Album 3',
        assetPath: 'assets/musics/sunny/3.mp3',
        albumCoverPath: 'assets/musics/images/sunny/3.jpg',
      ),
      Song(
        title: 'Dance The Night Away',
        artist: 'TWICE',
        album: 'Album 4',
        assetPath: 'assets/musics/sunny/4.mp3',
       albumCoverPath: 'assets/musics/images/sunny/4.jpg',
      ),
      Song(
        title: 'LOVEADE',
        artist: 'VIVIZ',
        album: 'Album 5',
        assetPath: 'assets/musics/sunny/5.mp3',
      albumCoverPath: 'assets/musics/images/sunny/5.jpg',
      ),
    ];
  }

  List<Song> _getRainyPlaylist() {
    // Define your rainy playlist songs here
    return [
      Song(
        title: 'Love Poem',
        artist: 'IU',
        album: 'Album 1',
        assetPath: 'assets\musics\rainy\1.mp3',
        albumCoverPath: 'assets/musics/images/rainy/1.jpg',
      ),
      Song(
        title: 'Love wins all',
        artist: 'IU',
        album: 'Album 2',
        assetPath: 'assets/musics/rainy/2.mp3',
        albumCoverPath: 'assets/musics/images/rainy/2.jpg',
      ),
      Song(
        title: 'Spring Day',
        artist: 'BTS',
        album: 'Album 3',
        assetPath: 'assets/musics/rainy/3.mp3',
        albumCoverPath: 'assets/musics/images/rainy/3.jpg',
      ),
      Song(
        title: 'DOWNPOUR',
        artist: 'I.O.I',
        album: 'Album 4',
        assetPath: 'assets/musics/rainy/4.mp3',
       albumCoverPath: 'assets/musics/images/rainy/4.jpg',
      ),
      Song(
        title: 'Dear Me',
        artist: 'Taeyeon',
        album: 'Album 5',
        assetPath: 'assets/musics/rainy/5.mp3',
        albumCoverPath: 'assets/musics/images/rainy/5.jpg',
      ),
    ];
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

void _loadSong() async {
  try {
    await _audioPlayer.setFilePath(_currentSong.assetPath);
    _audioPlayer.play(); // Start playback after loading the song
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Music Player'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            SongCard(
              songPath: _currentSong.assetPath,
              albumCoverPath: _currentSong.albumCoverPath,
              onAlbumCoverChanged: (newPath) {},
            ),
            SizedBox(height: 10),
            Text(
              _currentSong.title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              _currentSong.artist,
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            PlayerBar(
              songPath: _currentSong.assetPath,
              audioPlayer: _audioPlayer,
              songs: _songs.map((song) => song.assetPath).toList(),
              onSongChanged: (index) {
                setState(() {
                  _currentSong = _songs[index];
                });
                _loadSong();
              },
              onPrevious: () {
                int previousIndex = _songs.indexOf(_currentSong) - 1;
                if (previousIndex < 0) {
                  previousIndex = _songs.length - 1;
                }
                setState(() {
                  _currentSong = _songs[previousIndex];
                });
                _loadSong();
              },
              onNext: () {
                int nextIndex = _songs.indexOf(_currentSong) + 1;
                if (nextIndex >= _songs.length) {
                  nextIndex = 0;
                }
                setState(() {
                  _currentSong = _songs[nextIndex];
                });
                _loadSong();
              },
              currentIndex: 1,
              currentPosition: _position,
            ),
          ],
        ),
      ),
    );
  }
}
