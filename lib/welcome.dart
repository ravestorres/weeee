import 'package:flutter/material.dart';
import 'package:flutter_application_1/home_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to ',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.normal, // Keep the default font weight for this part
              ),
            ),
            Text(
              'WeatherNow!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold, // Make this part bold
                color: Colors.black, // Optional: You can set the text color here
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // Set button color to green
              ),
              child: Text(
                'Get Started',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold, // Optional: You can make the button text bold here
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
