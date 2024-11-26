import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gokid/pages/child_mode/child_mode_home.dart';
import 'package:gokid/pages/help_center/help_center_home.dart';
import 'package:gokid/pages/navigation_page.dart';
import 'package:gokid/services/firebase_crud_methods.dart';
import 'package:gokid/services/local_methods.dart';

import '../../services/firebase_auth_methods.dart';

class CheckToken extends StatelessWidget {
  static const String routeName = '/setup-token';

  const CheckToken({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.read<FirebaseAuthMethods>().user;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          'Cihaz Profili',
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            const Text(
              'Bu cihaz için bir kullanım profili belirleyin.',
              style: TextStyle(fontSize: 17),
            ),
            const SizedBox(
              height: 20,
            ),
            const Icon(
              Icons.phone_android_outlined,
              size: 100,
              color: Colors.blueGrey,
            ),
            const SizedBox(
              height: 20,
            ),
            FutureBuilder<String?>(
              future: context.read<FirebaseAuthMethods>().getToken(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  final token = snapshot.data;
                  return ListTile(
                    title: const Text('Ebeveyn İçin'),
                    leading: const Icon(Icons.people_alt_outlined),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("Kurulumu Tamamla"),
                            content: const Text(
                                "• Cihaz oturumu ebeveyn için oluşturulacaktır. Çocuk oturumu farklı cihazdan açılmalıdır.\n\n• Cihaz kurulumunu daha sonra farklı bir cihazdan oturum açarak değiştirebilirsiniz.\n\nDevam etmek istiyor musunuz ?"),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text("İptal"),
                              ),
                              TextButton(
                                onPressed: () async {
                                  await context
                                      .read<LocalMethods>()
                                      .saveTokenToLocalStorage(user.uid);

                                  await context
                                      .read<FirebaseCrudMethods>()
                                      .updateUserTokenn(user.uid, token);


                                  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
                                  String deviceDetails = 'Unsupported platform';

                                  if (Platform.isAndroid) {
                                    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
                                    deviceDetails = '${androidInfo.brand} ${androidInfo.device}';
                                  } else if (Platform.isIOS) {
                                    IosDeviceInfo iosDeviceInfo = await deviceInfo.iosInfo;
                                    deviceDetails = '${iosDeviceInfo.name} ${iosDeviceInfo.model}';
                                  }

                                  if (!context.mounted) return;

                                  await context
                                      .read<FirebaseCrudMethods>()
                                      .updateDeviceInfo(user.uid, deviceDetails);



                                  await context
                                      .read<LocalMethods>()
                                      .saveDeviceInfo('parent_mode');
                                  if (!context.mounted) return;
                                  Navigator.pushNamedAndRemoveUntil(
                                    context,
                                    NavigationPage.routeName,
                                    (route) => false,
                                  );
                                },
                                child: const Text("Evet"),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  );
                }
              },
            ),
            const Padding(
              padding: EdgeInsets.all(5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: Colors.grey,
                  ),
                  SizedBox(
                    width: 10.0,
                  ),
                  Text(
                    'Ebeveyn profili ile devam ederseniz\nbildirimler bu cihaza gönderilecektir.\nCihaz kurulumunu daha sonra\ndeğiştirebilirsiniz.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            const Divider(),
            const SizedBox(
              height: 40,
            ),

            const Icon(
              Icons.tablet_mac_sharp,
              size: 100,
              color: Colors.blueGrey,
            ),
            FutureBuilder<String?>(
              future: context.read<FirebaseAuthMethods>().getToken(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  final token = snapshot.data;
                  return ListTile(
                    title: const Text('Çocuk İçin'),
                    leading: const Icon(Icons.face),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("Kurulumu Tamamla"),
                            content: const Text(
                                "• Cihaz oturumu çocuk için oluşturulacak ve ebeveny farklı cihazdan yönetim sağlayacaktır.\n\n• Cihaz kurulumunu daha sonra farklı bir cihazdan oturum açarak değiştirebilirsiniz.\n\nDevam etmek istiyor musunuz ?"),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text("İptal"),
                              ),
                              TextButton(
                                onPressed: () async {
                                  await context
                                      .read<LocalMethods>()
                                      .saveTokenToLocalStorage(user.uid);

                                  await context
                                      .read<FirebaseCrudMethods>()
                                      .updateOtherDeviceToken(user.uid, token);

                                  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
                                  String deviceDetails = 'Unsupported platform';

                                  if (Platform.isAndroid) {
                                    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
                                    deviceDetails = '${androidInfo.brand} ${androidInfo.device}';
                                  } else if (Platform.isIOS) {
                                    IosDeviceInfo iosDeviceInfo = await deviceInfo.iosInfo;
                                    deviceDetails = '${iosDeviceInfo.name} ${iosDeviceInfo.model}';
                                  }

                                  if (!context.mounted) return;

                                  await context
                                      .read<FirebaseCrudMethods>()
                                      .updateOtherDeviceInfo(user.uid, deviceDetails);


                                  await context
                                      .read<LocalMethods>()
                                      .saveDeviceInfo('child_mode');
                                  if (!context.mounted) return;
                                  Navigator.pushNamedAndRemoveUntil(
                                    context,
                                    ChildLockScreen.routeName,
                                    (route) => false,
                                  );
                                },
                                child: const Text("Evet"),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  );
                }
              },
            ),
            const Padding(
              padding: EdgeInsets.all(5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: Colors.grey,
                  ),
                  SizedBox(
                    width: 10.0,
                  ),
                  Text(
                    'Çocuk profili ile devam ederseniz\nbildirimler bu cihaz üzerinden\ngönderilecektir.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 100,
            ),
            TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, HelpCenterHome.routeName);
                },
                child: const Text('Yardım Merkezi'))
          ],
        ),
      ),
    );
  }
}
