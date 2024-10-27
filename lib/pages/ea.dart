import 'dart:async';
import 'dart:math';
import 'package:camar_ais/pages/bluetooth_pages.dart';
import 'package:camar_ais/pages/data_pages.dart';
import 'package:camar_ais/pages/setting_page.dart';
import 'package:camar_ais/pages/weather.dart';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

void main() {
  final StreamController<DeviceData> dataController =
      StreamController<DeviceData>.broadcast();
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
        '/bluetooth': (context) =>
            BluePage(title: 'Bluetooth Page', dataController: dataController),
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
  String timeText = '';
  bool isLoading = false;

  List<List<dynamic>> _csvData = [];

  Future<void> _loadCsvData() async {
    final rawData = await rootBundle.loadString('assets/koordinat.csv');
    List<List<dynamic>> csvTable = CsvToListConverter().convert(rawData);
    setState(() {
      _csvData = csvTable;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadCsvData();
    mapController = MapController();
    widget.dataController.stream.listen((deviceData) {
      updateCurrentLocation(LatLng(deviceData.latitude, deviceData.longitude));
    });
  }

  void updateCurrentLocation(LatLng location) {
    if (currentLocation == null || currentLocation != location) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          currentLocation = location;
          mapController.move(location, 10.0);
          if (destinationLocation != null && lines.isNotEmpty) {
            lines.clear();
            _calculateDistance(currentLocation!, destinationLocation!);
          }
        });
      });
    }
  }

  void drawLineToLocation(LatLng destination) {
    if (currentLocation != null) {
      setState(() {
        destinationLocation = destination;
        lines.clear();
        _calculateDistance(currentLocation!, destinationLocation!);
      });
    }
  }

  void _calculateDistance(LatLng start, LatLng end) {
    const double radius = 6371e3; 
    final double lat1 = start.latitude * (pi / 180);
    final double lon1 = start.longitude * (pi / 180);
    final double lat2 = end.latitude * (pi / 180);
    final double lon2 = end.longitude * (pi / 180);
    final double dLat = lat2 - lat1;
    final double dLon = lon2 - lon1;
    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    final double distance = radius * c;

    final double distanceKm = distance / 1000;

    final double distanceMiles = distanceKm * 0.621371;
    final String distanceText = (distanceKm).toStringAsFixed(2) + ' km';

    lines.add(start);
    lines.add(end);

    setState(() {
       distanceText;
    });
  }

  Future<bool> _checkInternetConnection() async {
    try {
      final response = await http.get(Uri.parse('https://www.google.com'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<void> _startNavigation() async {
    final Position position = await Geolocator.getCurrentPosition();

    final LatLng destination = destinationLocation!;

    final double distance = Geolocator.distanceBetween(position.latitude,
        position.longitude, destination.latitude, destination.longitude);
    final double time = distance / 20; 
        lines.add(LatLng(position.latitude, position.longitude));
    lines.add(destination);

    setState(() {
      distanceText = (distance / 1000).toStringAsFixed(2) + ' km';
      timeText = (time / 60).toStringAsFixed(2) + ' menit';
    });

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Navigasi Dimulai'),
          content: const Text('Navigasi ke lokasi tujuan telah dimulai.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );

    await _navigateToDestination(position, destination);

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Navigasi Selesai'),
          content: const Text('Navigasi ke lokasi tujuan telah selesai.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _navigateToDestination(Position position, LatLng destination) async {
    while (position.latitude != destination.latitude ||
        position.longitude != destination.longitude) {
      position = await Geolocator.getCurrentPosition();

      final double distance = Geolocator.distanceBetween(position .latitude,
          position.longitude, destination.latitude, destination.longitude);

      setState(() {
        distanceText = (distance / 1000).toStringAsFixed(2) + ' km';
      });

      await Future.delayed(const Duration(seconds: 1));
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
                      updateCurrentLocation(
                          LatLng(deviceData.latitude, deviceData.longitude));
                    }
                    return FlutterMap(
                      mapController: mapController,
                      options: MapOptions(
                        initialCenter:
                            currentLocation ?? const LatLng(-6.1751, 106.8650),
                        minZoom: 10.0,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
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
                          markers: _csvData.map((row) {
                            if (row.length < 2) {
                              print('Invalid row: $row');
                              return const Marker(
                                point: LatLng(0,
                                    0), 
                                child: Icon(Icons.warning,
                                    color: Colors.red, size: 32),
                              );
                            }

                            final double? latitude =
                                double.tryParse(row[0].toString());
                            final double? longitude =
                                double.tryParse(row[1].toString());

                            if (latitude != null &&
                                longitude != null &&
                                latitude.isFinite &&
                                longitude.isFinite) {
                              return Marker(
                                point: LatLng(latitude, longitude),
                                child: GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text(
                                            'Titik Lokasi Ikan',
                                            textAlign: TextAlign.center,
                                          ),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                  'Latitude: ${latitude.toString()}'),
                                              Text(
                                                  'Longitude: ${longitude.toString()}'),
                                            ],
                                          ),
                                          actions: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.of(context)
                                                          .pop(),
                                                  child: const Text("Close"),
                                                ),
                                                TextButton(
                                                  onPressed: () async {
                                                    await _startNavigation();
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: Text("Mulai"),
                                                ),
                                              ],
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                    drawLineToLocation(
                                        LatLng(latitude, longitude));
                                  },
                                  child: const Icon(Icons.water_drop_sharp,
                                      color: Color.fromARGB(255, 221, 128, 7),
                                      size: 32),
                                ),
                              );
                            } else {
                              print('Invalid latitude or longitude: $row');
                              return const Marker(
                                point: LatLng(0,
                                    0), 
                                child: Icon(Icons.warning,
                                    color: Colors.red, size: 32),
                              );
                            }
                          }).toList(),
                        ),
                        if (currentLocation != null)
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: currentLocation!,
                                child: const Icon(Icons.location_on_sharp,
                                    color: Colors.red, size: 32),
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
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const WeatherPage())),
                ),
                SquareButton(
                  icon: Icons.settings,
                  label: 'Setting',
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SettingPage())),
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
        Text(label,
            style: TextStyle(
                color: Colors.grey[700],
                fontWeight: FontWeight.w700,
                fontSize: 12)),
      ],
    );
  }
}