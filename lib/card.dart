import 'package:flutter/material.dart';

class SongCard extends StatelessWidget {
  final String songPath;
  final String albumCoverPath;
  final Function(String) onAlbumCoverChanged;

  const SongCard({
    Key? key,
    required this.songPath,
    required this.albumCoverPath,
    required this.onAlbumCoverChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: Colors.grey[300],
                image: DecorationImage(
                  image: AssetImage(albumCoverPath),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
