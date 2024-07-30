import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  final List<String> items = [
    'Item 1',
    'Item 2',
  ];
  @override
  Widget build(BuildContext context) {
      return Scaffold(
      appBar: AppBar(
        title: Text('List Example'),
      ),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(items[index]),
            onTap: () {
            },
          );
        },
      ),
    );
  }
}
