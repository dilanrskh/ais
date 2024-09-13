import 'dart:async';
import 'package:camar_ais/data/models/fish_data.dart';
import 'package:camar_ais/pages/bluetooth_pages.dart';
import 'package:camar_ais/pages/data_pages.dart';
import 'package:camar_ais/pages/setting_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';


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
          mapController.move(location,10.0);


          if (lines.isNotEmpty) {
            lines[0] = location;
          }
        });
      });
    }
  }




  void drawLineToLocation(LatLng destination) {
    if (currentLocation != null) {
      setState(() {
        lines = [
          currentLocation!,
          destination,
        ];
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          StreamBuilder<DeviceData>(
            stream: widget.dataController.stream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final deviceData = snapshot.data!;
                // currentLocation = LatLng(deviceData.latitude, deviceData.longitude);
                // mapController.move(currentLocation!, 10.0);
                updateCurrentLocation(LatLng(deviceData.latitude, deviceData.longitude));
              }


              return FlutterMap(
                mapController: mapController,
                options: MapOptions(
                  initialCenter: currentLocation ?? const LatLng(-6.1751, 106.8650), // Default to Jakarta
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
                                  Icons.masks_rounded,
                                  color: Colors.orangeAccent,
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
                          point: updateCurrentLocation(currentLocation!) as LatLng,
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
      ),
    );
  }


  Widget buildBottomButtons() {
    return Positioned(
      bottom: 20,
      left: 10,
      right: 10,
      child: Row(
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
          const SquareButton(
            icon: Icons.cloudy_snowing,
            label: 'Cuaca',
            onPressed: null,
          ),
          SquareButton(
            icon: Icons.settings,
            label: 'Setting',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingPage())),
          ),
        ],
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(16),
          ),
          onPressed: onPressed,
          child: Icon(icon, size: 28),
        ),
        const SizedBox(height: 5),
        Text(label, style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w700)),
      ],
    );
  }
}



