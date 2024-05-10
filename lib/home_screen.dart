import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/music.dart';
import 'package:flutter_application_1/news.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart'; // Import for date formatting
import 'package:http/http.dart' as http; // Import HTTP package

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GoogleMapController? mapController;
  LatLng? currentLocation;
  String? currentAddress;
  List<dynamic>? hourlyForecast;

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
  }

  void getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse && permission != LocationPermission.always) {
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      currentLocation = LatLng(position.latitude, position.longitude);
    });

    // Fetch current location's address and hourly forecast
    getGeocodeAndHourlyForecast();
  }

  Future<void> getGeocodeAndHourlyForecast() async {
    if (currentLocation != null) {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        currentLocation!.latitude,
        currentLocation!.longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks.first;
        setState(() {
          currentAddress = placemark.street! +
              ', ' +
              placemark.locality! +
              ', ' +
              placemark.administrativeArea! +
              ', ' +
              placemark.country!;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Address not found.'),
          ),
        );
      }

      // Fetch hourly forecast
      fetchHourlyForecast();
    }
  }

  Future<void> fetchHourlyForecast() async {
    if (currentLocation != null) {
      String apiUrl = 'https://api.open-meteo.com/v1/forecast?latitude=${currentLocation!.latitude}&longitude=${currentLocation!.longitude}&hourly=temperature_2m&timezone=Asia%2FSingapore';

      var response = await http.get(Uri.parse(apiUrl));
      print('API Response Code: ${response.statusCode}');
      print('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        var hourlyData = data['hourly']['temperature_2m'];
        
        if (hourlyData.length > 24) {
          hourlyForecast = hourlyData.sublist(0, 24);
        } else {
          hourlyForecast = hourlyData;
        }
        
        setState(() {});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load weather data.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('WeatherNow'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 200, // Adjust the height as needed
              child: Stack(
                children: [
                  if (currentLocation != null)
                    GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: currentLocation!,
                        zoom: 14,
                      ),
                      onMapCreated: (controller) {
                        setState(() {
                          mapController = controller;
                        });
                      },
                      markers: {
                        Marker(
                          markerId: MarkerId('current_location'),
                          position: currentLocation!,
                        ),
                      },
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Current Location Address:',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (currentAddress != null)
                    Text(
                      currentAddress!,
                      style: TextStyle(fontSize: 16),
                    ),
                  SizedBox(height: 16),
                  Text(
                    'Current Time and Temperature:',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Display the current time and temperature
                  if (hourlyForecast != null && hourlyForecast!.isNotEmpty)
                    Card(
                      child: ListTile(
                        title: Row(
                          children: [
                            Text(
                              DateFormat('hh:mm a').format(DateTime.now()),
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Spacer(), // Adds space between time and temperature
                            Text(
                              '${hourlyForecast![0]}°C',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  SizedBox(height: 16),
                  Text(
                    'Next 24-Hour Forecast:',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Display the next 24-hour forecast in a 4x4 grid
                  if (hourlyForecast != null && hourlyForecast!.length > 1)
  GridView.builder(
  shrinkWrap: true,
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 4,
    crossAxisSpacing: 8,
    mainAxisSpacing: 8,
  ),
  itemCount: hourlyForecast!.length,
  itemBuilder: (context, index) {
    var hourData = hourlyForecast![index];
    return SizedBox(
      height: 80, // Adjust the height as needed
      child: Card(
        child: ListTile(
          title: Text(
            DateFormat('hh a').format(DateTime.now().add(Duration(hours: index))),
            style: TextStyle(fontSize: 10), // Adjust the font size as needed
          ),
          subtitle: Text(
            '${hourData}°C',
            style: TextStyle(fontSize: 10), // Adjust the font size as needed
          ),
        ),
      ),
    );
  },
),


                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(Icons.home, color: Colors.blue), // Active color for home button
              onPressed: () {
                // Handle home button press
              },
            ),
            IconButton(
              icon: Icon(Icons.new_releases, color: Colors.grey),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NewsScreen()),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.music_note, color: Colors.grey),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MusicScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
