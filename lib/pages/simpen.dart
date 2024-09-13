import 'package:camar_ais/pages/bluetooth_pages.dart';
import 'package:camar_ais/pages/setting_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Center Text with Buttons',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const CenterTextScreen(),
    );
  }
}

class CenterTextScreen extends StatefulWidget {
  const CenterTextScreen({super.key});

  @override
  _CenterTextScreenState createState() => _CenterTextScreenState();
}

class _CenterTextScreenState extends State<CenterTextScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            options: const MapOptions(
              initialCenter: LatLng(-6.1751, 106.8650), // Koordinat Jakarta
              minZoom: 10.0,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
              ),
              const MarkerLayer(
                markers: [
                  Marker(
                    point: LatLng(-6.075, 106.875),
                    child: Icon(Icons.location_on_sharp),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            bottom: 20,
            left: 10,
            right: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SquareButton(
                  icon: Icons.bluetooth,
                  label: 'Bluetooth',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              BluePage(title: 'Bluetooth Page')),
                    );
                  },
                ),
                SquareButton(
                  icon: Icons.downloading_outlined,
                  label: 'Download Peta',
                  onPressed: () {},
                ),
                SquareButton(
                  icon: Icons.cloudy_snowing,
                  label: 'Cuaca',
                  onPressed: () {},
                ),
                SquareButton(
                  icon: Icons.settings,
                  label: 'Setting',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SettingPage()),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SquareButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const SquareButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
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
        Text(label,
            style: TextStyle(
                color: Colors.grey[700], fontWeight: FontWeight.w700)),
      ],
    );
  }
}