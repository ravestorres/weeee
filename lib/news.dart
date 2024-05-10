import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/home_screen.dart';
import 'package:flutter_application_1/music.dart';
import 'package:http/http.dart' as http;

class NewsScreen extends StatefulWidget {
  @override
  _NewsScreenState createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  List<Article>? weatherNews;

  @override
  void initState() {
    super.initState();
    fetchWeatherNews();
  }

  Future<void> fetchWeatherNews() async {
    String apiUrl = 'https://newsapi.org/v2/top-headlines?country=ph&apiKey=6a9da81d549c466ab942e12ae986ddfb';

    var response = await http.get(Uri.parse(apiUrl));
    print('News API Response Code: ${response.statusCode}');
    print('News API Response Body: ${response.body}');

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (data['status'] == 'ok') {
        List<dynamic> articles = data['articles'];
        setState(() {
          weatherNews = articles.map((article) => Article.fromJson(article)).toList();
        });
      } else {
        setState(() {
          weatherNews = [];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load weather news.'),
          ),
        );
      }
    } else {
      setState(() {
        weatherNews = [];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to fetch weather news. Status code: ${response.statusCode}'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather News'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              fetchWeatherNews();
            },
          ),
        ],
      ),
      body: weatherNews == null
          ? Center(child: CircularProgressIndicator())
          : weatherNews!.isEmpty
              ? Center(child: Text('No weather news available.'))
              : ListView.builder(
                  itemCount: weatherNews!.length * 2 - 1, // Adjusted for dividers
                  itemBuilder: (context, index) {
                    if (index.isOdd) {
                      return Divider(); // Adds a divider after every news item
                    }
                    final itemIndex = index ~/ 2;
                    return ListTile(
                      title: Text(weatherNews![itemIndex].title ?? ''),
                      subtitle: Text(weatherNews![itemIndex].description ?? ''),
                      onTap: () {
                        // Handle news item tap
                      },
                    );
                  },
                ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(Icons.home),
              onPressed: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
              },
            ),
            IconButton(
              icon: Icon(Icons.new_releases, color: Colors.blue), // Active color
              onPressed: () {
                // Stay on NewsScreen
              },
            ),
            IconButton(
              icon: Icon(Icons.music_note),
              onPressed: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MusicScreen()));
              },
            ),
          ],
        ),
      ),
    );
  }
}

class Article {
  String? title;
  String? description;

  Article({
    this.title,
    this.description,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      title: json['title'],
      description: json['description'],
    );
  }
}
