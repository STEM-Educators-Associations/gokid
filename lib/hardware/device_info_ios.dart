import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';

class DeviceInfoPageIOS extends StatefulWidget {
  static const String routeName = '/device-ios';

  const DeviceInfoPageIOS({super.key});

  @override
  _DeviceInfoPageIOSState createState() => _DeviceInfoPageIOSState();
}

class _DeviceInfoPageIOSState extends State<DeviceInfoPageIOS> {
  Map<String, String> _deviceData = {};

  @override
  void initState() {
    super.initState();
    _getDeviceInfo();
  }

  Future<void> _getDeviceInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    IosDeviceInfo iosInfo = await deviceInfo.iosInfo;

    setState(() {
      _deviceData = {
        'Model': iosInfo.model,
        'İsim': iosInfo.name,
        'Sistem Adı': iosInfo.systemName,
        'Sürüm': iosInfo.systemVersion,
        'İşlemci': iosInfo.utsname.machine,
        'İşletim Sistemi': iosInfo.utsname.sysname,
        'Sürüm': iosInfo.utsname.release,

      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cihaz Spesifik Bilgileri'),
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
