import 'package:flutter/material.dart';
import 'package:flutter_application_1/welcome.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(WeatherNow());
}

class WeatherNow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
       
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: WelcomeScreen(),
    );
  }
}
