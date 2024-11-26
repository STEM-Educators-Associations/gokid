import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gokid/hardware/device_info_android.dart';
import 'package:gokid/hardware/device_info_ios.dart';
import 'package:gokid/pages/settings/notif_settings.dart';
import 'package:gokid/pages/settings/setup_settings.dart';
import 'package:gokid/pages/settings/voice_settings.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsMainPage extends StatefulWidget {
  static const String routeName = '/settings-main-screen';

  @override
  _SettingsMainPageState createState() => _SettingsMainPageState();
}

class _SettingsMainPageState extends State<SettingsMainPage> {
  TextEditingController _searchController = TextEditingController();
  String _searchText = "";

  @override
  Widget build(BuildContext context) {
    List<HelpItem> _helpItems = [
      HelpItem(
        title: 'Bildirimler',
        subtitle: 'Bildirim tercihleri ,bildirim sıklığı...',
        showAction: false,
        onPressedCallback: () {
          Navigator.pushNamed(context, NotifSettings.routeName);
        },
        icon: Icons.notifications,
      ),
      HelpItem(
        title: 'Seslendirme',
        subtitle: 'Ses ayarları ,ses türü ...',
        showAction: false,
        onPressedCallback: () {
          Navigator.pushNamed(context, VoiceSettings.routeName);


        },
        icon: Icons.volume_up,
      ),

      HelpItem(
        title: 'Cihaz Kurulumu',
        subtitle: 'Cihaz kurulumu ,hesap profilleri ...',
        showAction: false,
        onPressedCallback: () {
          Navigator.pushNamed(context, DeviceSetup.routeName);
        },
        icon: Icons.phone_android_outlined,
      ),

      HelpItem(
        title: 'Yardım Merkezi',
        subtitle: 'Daha fazla yardım alın.',
        icon: Icons.help,
        showAction: true,
        onPressedCallback: () async {
          const url = 'https://gorsel-bag-info-web-app.web.app';
      launchUrl(Uri.parse(url));
        },
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
        actions: [
          TextButton(
              onPressed: () {
                if (Platform.isAndroid) {
                  Navigator.pushNamed(context, DeviceInfoPageAndroid.routeName);
                } else if (Platform.isIOS) {
                  Navigator.pushNamed(context, DeviceInfoPageIOS.routeName);
                }
              },
              child: Text(
                'Cihaz Bilgileri',
                style: TextStyle(color: Colors.green, fontSize: 18),
              )),
          SizedBox(
            width: 10.0,
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 20.0,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.settings,
                            color: Colors.grey,
                            size: 30,
                          ),
                          SizedBox(
                            width: 5.0,
                          ),
                          const Text(
                            'Ayarlarınızı Güncelleyin',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text(
                        'Bazı ayarlar sadece\nYardım Merkezi üzerinden erişilebilir.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                              color: Colors.transparent, width: 0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                              color: Colors.transparent, width: 0),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        filled: true,
                        fillColor: const Color(0xffF5F6FA),
                        hintText: 'Ayarlarda Aratın',
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchText = value.toLowerCase();
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                crossAxisSpacing: 1,
                mainAxisSpacing: 1,
                childAspectRatio: 2,
              ),
              itemCount: _helpItems.length,
              itemBuilder: (context, index) {
                final item = _helpItems[index];
                if (_searchText.isEmpty ||
                    item.title.toLowerCase().contains(_searchText)) {
                  return GestureDetector(
                    onTap: item.onPressedCallback,
                    child: Card(
                      margin: EdgeInsets.all(10.0),
                      elevation: 4.0,
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              item.icon,
                              color: Colors.deepPurple,
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              item.title,
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple),
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              item.subtitle,
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                } else {
                  return SizedBox.shrink();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class HelpItem {
  final String title;
  final String subtitle;
  final bool showAction;
  final VoidCallback onPressedCallback;
  final IconData icon;

  HelpItem({
    required this.title,
    required this.subtitle,
    required this.showAction,
    required this.onPressedCallback,
    required this.icon,
  });
}
