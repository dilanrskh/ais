import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  Position? _currentPosition;
  String _weatherDescription = '';
  double _temperature = 0.0;
  double _humidity = 0.0;
  double _windSpeed = 0.0;

  @override
  void initState() {
    super.initState();
    _initGeolocation();
  }

  _initGeolocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition = position;
    });

    final apiKey = '563c04d425b4652f1f1fa24231fb6613';
    final url = 'http://api.openweathermap.org/data/2.5/weather?lat=${_currentPosition!.latitude}&lon=${_currentPosition!.longitude}&appid=$apiKey';
    final response = await http.get(Uri.parse(url));
    final jsonData = jsonDecode(response.body);

    setState(() {
      _weatherDescription = jsonData['weather'][0]['description'];
      _temperature = jsonData['main']['temp'].toDouble(); // Convert to double
      _humidity = jsonData['main']['humidity'].toDouble(); // Convert to double
      _windSpeed = jsonData['wind']['speed'].toDouble(); // Convert to double
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Cuaca Terkini'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Current Location: ${_currentPosition?.latitude}, ${_currentPosition?.longitude}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.location_pin, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          'Weather:',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${_temperature}°C',
                      style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildWeatherData(Icons.water, 'Humidity', '${_humidity}%'),
                    _buildWeatherData(Icons.wind_power, 'Wind Speed', '${_windSpeed} m/s'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherData(IconData icon, String label, String value) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.blue, size: 32),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
