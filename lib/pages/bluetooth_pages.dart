// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:camar_ais/pages/data_pages.dart';

class BluePage extends StatefulWidget {
  final String title;
  final StreamController<DeviceData> dataController;

  BluePage({
    Key? key,
    required this.title,
    required this.dataController,
  }) : super(key: key);

  @override
  State<BluePage> createState() => _BluePageState();
}

class _BluePageState extends State<BluePage> {
  final List<BluetoothDevice> devicesList = <BluetoothDevice>[];
  BluetoothDevice? _connectedDevice;
  List<BluetoothService> _services = [];
  final Guid serviceUUID = Guid('d973f2e0-b19e-11e2-9e96-0800200c9a66');
  final Guid readCharacteristicUUID =
      Guid('d973f2e1-b19e-11e2-9e96-0800200c9a66');
  StreamSubscription<List<int>>? dataStreamSubscription;
  String partialData = '';
  Position? _currentLocation;
  Position? _currentPosition;
  StreamSubscription<Position>? _positionStreamSubscription;

  @override
  void initState() {
    super.initState();
    _initBluetooth();
    _initGeolocation();
  }

  _initBluetooth() async {
    var status = await Permission.location.status;
    if (status.isDenied) {
      final status = await Permission.location.request();
      if (status.isGranted || status.isLimited) {
        _startBluetoothScan();
      }
    } else if (status.isGranted || status.isLimited) {
      _startBluetoothScan();
    }

    if (await Permission.location.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  _startBluetoothScan() async {
    var subscription = FlutterBluePlus.scanResults.listen(
      (results) {
        if (results.isNotEmpty) {
          for (ScanResult result in results) {
            _addDeviceToList(result.device);
          }
        }
      },
      onError: (e) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error scanning for Bluetooth devices: $e')),
      ),
    );

    await FlutterBluePlus.adapterState
        .where((val) => val == BluetoothAdapterState.on)
        .first;

    await FlutterBluePlus.startScan(timeout: Duration(seconds: 10));

    await FlutterBluePlus.isScanning.where((val) => val == false).first;

    List<BluetoothDevice> devices = await FlutterBluePlus.connectedDevices;
    for (BluetoothDevice device in devices) {
      _addDeviceToList(device);
    }
  }

  _addDeviceToList(final BluetoothDevice device) {
    if (!devicesList.contains(device)) {
      setState(() {
        devicesList.add(device);
      });
    }
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    FlutterBluePlus.stopScan();
    try {
      await device.connect();
      _services = await device.discoverServices();
      for (BluetoothService service in _services) {
        if (service.uuid == serviceUUID) {
          for (BluetoothCharacteristic characteristic
              in service.characteristics) {
            if (characteristic.uuid == readCharacteristicUUID) {
              await characteristic.setNotifyValue(true);
              dataStreamSubscription = characteristic.value.listen((data) {
                String receivedData = String.fromCharCodes(data);
                print('Data received: $receivedData');
                _processReceivedData(receivedData, device);
              });
            }
          }
        }
      }
    } catch (e) {
      print('Error connecting to device: $e');
    }

    setState(() {
      _connectedDevice = device;
    });
  }

  void _processReceivedData(String data, BluetoothDevice device) {
    try {
      data = data.replaceAll(RegExp(r'[\x00-\x1F\x7F-\x9F]'), '');
      partialData += data;

      while (partialData.contains('#')) {
        int startIndex = partialData.indexOf('CAMAR#');
        int endIndex = partialData.indexOf('#', startIndex + 1);

        if (startIndex != -1 && endIndex != -1 && partialData.substring(endIndex + 1).contains('CAMAR#')) {
          String completeData = partialData.substring(startIndex, endIndex + 1);
          List<String> dataParts = completeData.split('#');

          if (dataParts.length >= 7) {
            try {
              String deviceId = dataParts[1];
              int status = int.parse(dataParts[2]);

              double? latitude;
              try {
                latitude = double.parse(dataParts[3]);
              } catch (e) {
                print('Invalid latitude format in data: ${dataParts[3]}');
                latitude = null;
              }

              double? longitude;
              try {
                longitude = double.parse(dataParts[4]);
              } catch (e) {
                print('Invalid longitude format in data: ${dataParts[4]}');
                longitude = null;
              }

              double? additionalInfo;
              try {
                additionalInfo = double.parse(dataParts[5]);
              } catch (e) {
                print('Invalid additional info format in data: ${dataParts[5]}');
                additionalInfo = null;
              }

              if (latitude != null && longitude != null) {
                DeviceData updatedDeviceData = DeviceData(
                  time: DateTime.now(),
                  deviceId: deviceId,
                  status: status,
                  latitude: latitude,
                  longitude: longitude,
                  additionalInfo: additionalInfo,
                );

                widget.dataController.add(updatedDeviceData);
              } else {
                print('Invalid latitude or longitude in data: $data');
              }
            } catch (e) {
              print('Error parsing data parts: $e');
            }
          } else {
            print('Incomplete data received: $partialData');
          }

          partialData = partialData.substring(endIndex + 1);
        } else {
          if (partialData.substring(endIndex + 1).startsWith('#')) {
          } else {
            partialData = '';
          }

          break;
        }
      }
    } catch (e) {
      print('Error processing data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error processing data: $e')),
      );
    }
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

    _positionStreamSubscription = Geolocator.getPositionStream().listen((Position position) {
      setState(() {
        _currentPosition = position;
      });

      if (_connectedDevice != null) {
        DeviceData updatedDeviceData = DeviceData(
          time: DateTime.now(),
          deviceId: _connectedDevice!.id.toString(),
          status: 1,
          latitude: position.latitude,
          longitude: position.longitude,
          additionalInfo: 0.0,
        );

        widget.dataController.add(updatedDeviceData);
      }
    });
  }

  @override
  void dispose() {
    widget.dataController.close();
    dataStreamSubscription?.cancel();
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  ListView _buildListViewOfDevices() {
    List<Widget> containers = <Widget>[];
    for (BluetoothDevice device in devicesList) {
      containers.add(
        SizedBox(
          height: 50,
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                        device.name.isEmpty ? '(unknown device)' : device.name),
                    Text(device.id.toString()),
                  ],
                ),
              ),
              TextButton(
                onPressed: () async {
                  await _connectToDevice(device);
                },
                child: const Text(
                  'Connect',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(8),
      children: <Widget>[...containers],
    );
  }

  Widget _buildConnectDeviceView() {
    return ListView(
      children: <Widget>[
        ListTile(
          title: const Text('Connected Device Information'),
          subtitle: Text(_connectedDevice?.name ?? 'Unknown Device'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_connectedDevice != null) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => DataPage(
                    deviceDataStream: widget.dataController.stream,
                  ),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No device connected')),
              );
            }
          },
          child: const Text('View Data'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: _connectedDevice == null
          ? _buildListViewOfDevices()
          : _buildConnectDeviceView(),
    );
  }
}