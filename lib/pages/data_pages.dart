import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DeviceData {
  final DateTime time;
  final String deviceId;
  final int status;
  final double latitude;
  final double longitude;
  final double? additionalInfo;

  DeviceData({
    required this.time,
    required this.deviceId,
    required this.status,
    required this.latitude,
    required this.longitude,
    required this.additionalInfo,
  });
}

class DataPage extends StatelessWidget {
  final Stream<DeviceData> deviceDataStream;

  DataPage({required this.deviceDataStream});

  @override
  Widget build(BuildContext context) {
    final DateFormat dateFormat = DateFormat('HH:mm:ss.SSS');
    return Scaffold(
      appBar: AppBar(
        title: Text('Device Data'),
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        color: Colors.black,
        child: StreamBuilder<DeviceData>(
          stream: deviceDataStream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final deviceData = snapshot.data!;
              return ListView(
                children: <Widget>[
                  Text(
                    '#${deviceData.additionalInfo}',
                    style: TextStyle(color: Colors.green, fontSize: 20),
                  ),
                  Text(
                    '${dateFormat.format(deviceData.time)} CAMAR#${deviceData.deviceId}#${deviceData.status}#${deviceData.latitude}#${deviceData.longitude}#${deviceData.additionalInfo}',
                    style: TextStyle(color: Colors.green, fontSize: 16),
                  ),
                ],
              );
            } else if (snapshot.hasError) {
              return Text(
                'Error: ${snapshot.error}',
                style: TextStyle(color: Colors.red),
              );
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    );
  }
}