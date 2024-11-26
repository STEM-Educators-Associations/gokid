import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:gokid/pages/child_mode/child_mode_home.dart';
import 'package:gokid/widgets/custom_button.dart';
import 'package:permission_handler/permission_handler.dart';

class RequestNotifPermissionScreen extends StatelessWidget {
  static const String routeName = '/req-permission';

  const RequestNotifPermissionScreen({super.key});

  Future<void> _requestNotificationPermission(BuildContext context) async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      Navigator.pushNamedAndRemoveUntil(context, ChildLockScreen.routeName, (route)=> false );

      print('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
      _showSettingsDialog(context);
    }
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('İzin Gerekli'),
        content: const Text(
          'Devam etmeden önce lütfen bildirim izinlerini açın.'

        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _openAppSettings();
            },
            child: const Text('Açmak İçin Ayarlara Git'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/navigation',
                    (route) => false,
              );
            },
            child: const Text('İptal'),
          ),


        ],
      ),
    );
  }

  void _openAppSettings() {
    openAppSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bildirim İzni'),
        leading: null,
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Image.asset('assets/images/ic/request_notif_ic.png'),
              const SizedBox(
                height: 20.0,
              ),
              const Text(
                'Uygulamanın çalışması için bildirim izinlerine ihtiyacımız var.',
                style: TextStyle(
                  fontSize: 20,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 40.0,
              ),

              const Padding(
                padding: EdgeInsets.all(10.0),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.grey,
                    ),
                    SizedBox(
                      width: 10.0,
                    ),
                    Text(
                      'Bildirim izni olmadan\nÇocuk Modu kullanılamaz.',
                      style: TextStyle(fontSize: 15, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 40.0,
              ),
              CustomButton(
                  onTap: () async {
                    await _requestNotificationPermission(context);
                  },
                  text: 'İzin Ver'),
              const SizedBox(
                height: 20.0,
              ),
              TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/help-center');
                  },
                  child: const Text('Yardım Merkezi'))
            ],
          ),
        ),
      ),
    );
  }
}
