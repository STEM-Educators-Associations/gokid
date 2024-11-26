import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';

class DeviceInfoPageAndroid extends StatefulWidget {
  static const String routeName = '/android-device';

  const DeviceInfoPageAndroid({super.key});

  @override
  _DeviceInfoPageAndroidState createState() => _DeviceInfoPageAndroidState();
}

class _DeviceInfoPageAndroidState extends State<DeviceInfoPageAndroid> {
  Map<String, String> _deviceData = {};

  @override
  void initState() {
    super.initState();
    _getDeviceInfo();
  }

  Future<void> _getDeviceInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

    setState(() {
      _deviceData = {
        'Model': androidInfo.model,
        'ID': androidInfo.id,
        'Cihaz': androidInfo.device,
        'Marka': androidInfo.brand,
        'Üretici': androidInfo.manufacturer,
        'Android Sürümü': androidInfo.version.release,

      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cihaz Spesifik Bilgileri'),
      ),
      body: ListView.builder(
        itemCount: _deviceData.length,
        itemBuilder: (context, index) {
          String key = _deviceData.keys.elementAt(index);
          String value = _deviceData[key]!;
          return ListTile(
            title: Text(key),
            subtitle: Text(value),
          );
        },
      ),
    );
  }
}
