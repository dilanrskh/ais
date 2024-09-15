import 'dart:async';
import 'dart:math';
import 'package:camar_ais/data/models/fish_data.dart';
import 'package:camar_ais/pages/bluetooth_pages.dart';
import 'package:camar_ais/pages/data_pages.dart';
import 'package:camar_ais/pages/setting_page.dart';
import 'package:camar_ais/pages/weather.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

void main() {
  final StreamController<DeviceData> dataController = StreamController<DeviceData>.broadcast();
  runApp(MainPage(dataController: dataController));
}

class MainPage extends StatelessWidget {
  final StreamController<DeviceData> dataController;

  const MainPage({super.key, required this.dataController});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Center Text with Buttons',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CenterTextScreen(dataController: dataController),
      routes: {
        '/bluetooth': (context) => BluePage(title: 'Bluetooth Page', dataController: dataController),
      },
    );
  }
}

class CenterTextScreen extends StatefulWidget {
  final StreamController<DeviceData> dataController;

  const CenterTextScreen({super.key, required this.dataController});

  @override
  _CenterTextScreenState createState() => _CenterTextScreenState();
}

class _CenterTextScreenState extends State<CenterTextScreen> {
  LatLng? currentLocation;
  late MapController mapController;
  List<LatLng> lines = [];
  LatLng? destinationLocation;
  String distanceText = '';

  final List<FishData> fishData = [
    FishData(latitude: -6.1751, longitude: 106.8650, name: "Jakarta"),
    FishData(latitude: -6.524197, longitude: 107.04004, name: "Bogor"),
  ];

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    widget.dataController.stream.listen((deviceData) {
      // Ensure this code runs every time new GPS data arrives
      updateCurrentLocation(LatLng(deviceData.latitude, deviceData.longitude));
    });
  }

  void updateCurrentLocation(LatLng location) {
    if (currentLocation == null || currentLocation != location) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          currentLocation = location;
          mapController.move(location, 10.0);
          
          // Update line and distance if destination is set
          if (destinationLocation != null && lines.isNotEmpty) {
            lines = getRouteLine(currentLocation!, destinationLocation!);
            distanceText = calculateDistance(currentLocation!, destinationLocation!).toStringAsFixed(2) + " km";
          }
        });
      });
    }
  }

  void drawLineToLocation(LatLng destination) {
    if (currentLocation != null) {
      setState(() {
        destinationLocation = destination;
        lines = getRouteLine(currentLocation!, destinationLocation!);
        distanceText = calculateDistance(currentLocation!, destinationLocation!).toStringAsFixed(2) + " km";
      });
    }
  }

  List<LatLng> getRouteLine(LatLng start, LatLng end) {
  List<LatLng> routeLine = [];
  double distance = haversineDistance(start.latitude, start.longitude, end.latitude, end.longitude);
  int numPoints = distance > 0 ? max(2, (distance / 10).toInt()) : 2; 

  for (int i = 0; i < numPoints; i++) {
    double lat = start.latitude + (end.latitude - start.latitude) * i / (numPoints - 1);
    double lon = start.longitude + (end.longitude - start.longitude) * i / (numPoints - 1);
    routeLine.add(LatLng(lat, lon));
  }

  routeLine.add(end);

  return routeLine;
}

  double haversineDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // in kilometers
    double dLat = toRadians(lat2 - lat1);
    double dLon = toRadians(lon2 - lon1);
    double lat1Rad = toRadians(lat1);
    double lat2Rad = toRadians(lat2);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        sin(dLon / 2) * sin(dLon / 2) * cos(lat1Rad) * cos(lat2Rad);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distance = earthRadius * c;

    return distance;
  }

  double toRadians(double deg) {
    return deg * pi / 180;
  }

  double calculateDistance(LatLng start, LatLng end) {
    return haversineDistance(start.latitude, start.longitude, end.latitude, end.longitude);
  }

  Future<bool> _checkInternetConnection() async {
    try {
      final response = await http.get(Uri.parse('https://www.google.com'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _checkInternetConnection(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            return Stack(
              children: [
                StreamBuilder<DeviceData>(
                  stream: widget.dataController.stream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data != null) {
                      final deviceData = snapshot.data!;
                      updateCurrentLocation(LatLng(deviceData.latitude, deviceData.longitude));
                    }
                    return FlutterMap(
                      mapController: mapController,
                      options: MapOptions(
                        initialCenter: currentLocation ?? const LatLng(-6.1751, 106.8650),
                        minZoom: 10.0,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                          subdomains: const ['a', 'b', 'c'],
                        ),
                        if (lines.isNotEmpty)
                          PolylineLayer(
                            polylines: [
                              Polyline(
                                points: lines,
                                strokeWidth: 4.0,
                                color: Colors.blue,
                              ),
                            ],
                          ),
                        MarkerLayer(
                          markers: fishData
                              .map((fish) => Marker(
                                    point: LatLng(fish.latitude, fish.longitude),
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.water_drop_sharp,
                                        color: Color.fromARGB(255, 221, 128, 7),
                                        size: 32,
                                      ),
                                      onPressed: () {
                                        drawLineToLocation(LatLng(fish.latitude, fish.longitude));
                                      },
                                    ),
                                  ))
                              .toList(),
                        ),
                        if (currentLocation != null)
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: currentLocation!,
                                child: const Icon(Icons.location_on_sharp, color: Colors.red, size: 32),
                              ),
                            ],
                          ),
                      ],
                    );
                  },
                ),
                buildBottomButtons(),                  
              ],
            );
          } else {
            return const Center(
              child: Text('Tidak ada koneksi internet'),
            );
          }
        },
      ),
    );
  }

    Widget buildBottomButtons() {
    return Positioned(
      bottom: 20,
      left: 10,
      right: 10,
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Column(
          children: [
            if (distanceText.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 10), 
                child: Center(
                  child: Text(
                    'Jarak : $distanceText',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SquareButton(
                  icon: Icons.bluetooth,
                  label: 'Bluetooth',
                  onPressed: () => Navigator.pushNamed(context, '/bluetooth'),
                ),
                const SquareButton(
                  icon: Icons.downloading_outlined,
                  label: 'Download Peta',
                  onPressed: null,
                ),
                SquareButton(
                  icon: Icons.cloudy_snowing,
                  label: 'Cuaca',
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const WeatherPage())),
                ),
                SquareButton(
                  icon: Icons.settings,
                  label: 'Setting',
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingPage())),
                ),
              ],
            ),
            
          ],
        ),
      ),
    );
  }
}

class SquareButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  const SquareButton({
    super.key,
    required this.icon,
    required this.label,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[300],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(10), 
          ),
          onPressed: onPressed,
          child: Icon(icon, size: 24), 
        ),
        const SizedBox(height: 4), 
        Text(label, style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w700, fontSize: 12)), // Reduced font size for smaller buttons
      ],
    );
  }
}