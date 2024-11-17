import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/firebase_auth_methods.dart';

class NotifSettings extends StatefulWidget {
  static const String routeName = '/notif-settings';

  const NotifSettings({super.key});

  @override
  State<NotifSettings> createState() => _NotifSettingsState();
}

class _NotifSettingsState extends State<NotifSettings> {
  bool _blockMultipleNotifications = false;
  bool _muteNotificationsAtNight = false;
  bool _prioritizeChildModeNotifications = true;
  bool _appNotif = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _blockMultipleNotifications = prefs.getBool('blockMultipleNotifications') ?? false;
      _muteNotificationsAtNight = prefs.getBool('muteNotificationsAtNight') ?? false;
      _prioritizeChildModeNotifications = prefs.getBool('prioritizeChildModeNotifications') ?? false;
    _appNotif = prefs.getBool('appNotif') ?? false;;
    });
  }

  Future<void> _saveSetting(String key, bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bildirim Ayarları'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(0.0),
        child: Column(
          children: [
            SizedBox(height: 10.0,),
            const Divider(),
            ListTile(
              leading: const Text(
                'Uygulama bildirimlerini kalıcı\nolarak sessize al.',
                style: TextStyle(fontSize: 15),
              ),
              trailing: Switch(
                value: _appNotif,

                onChanged: (bool value) {
                  setState(() {
                    _appNotif = value;
                  });
                  _saveSetting('appNotif', value);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: const Text(
                'Bu ayar uygulama bildirimlerini sessize alır ama çocuk modu bildirimlerini sessize almaz.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            Divider(),
            ListTile(
              leading: const Text(
                'Birden çok bildirimi engelle.',
                style: TextStyle(fontSize: 15),
              ),
              trailing: Switch(
                value: _blockMultipleNotifications,

                onChanged: (bool value) {
                  setState(() {
                    _blockMultipleNotifications = value;
                  });
                  _saveSetting('blockMultipleNotifications', value);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: const Text(
                'Çocuk Modu ile üst üste gelen bildirimleri önlemek için bu ayarı açık tutun.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Text(
                'Bildirimleri gece saatlerinde\nsessize al.',
                style: TextStyle(fontSize: 15),
              ),
              trailing: Switch(
                value: _muteNotificationsAtNight,
                onChanged: (bool value) {
                  setState(() {
                    _muteNotificationsAtNight = value;
                  });
                  _saveSetting('muteNotificationsAtNight', value);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: const Text(
                'Gece saatlerinde uygulama size bildirim göndermez. Bu ayar bulunduğunuz bölgeye göre değişiklik gösterebilir.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Text(
                'Çocuk Modu bildirimlerine\nöncelik ver.',
                style: TextStyle(fontSize: 15),
              ),
              trailing: Switch(
                value: _prioritizeChildModeNotifications,
                onChanged: (bool value) {
                  setState(() {
                    _prioritizeChildModeNotifications = value;
                  });
                  _saveSetting('prioritizeChildModeNotifications', value);
                },
              ),
            ),

            const Divider(),
            const SizedBox(height: 40.0),
          ],
        ),
      ),
    );
  }
}
