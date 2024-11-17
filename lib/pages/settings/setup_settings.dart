import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gokid/pages/user_account_page.dart';
import 'package:gokid/widgets/custom_button.dart';

import '../../models/user_model.dart';
import '../../services/firebase_auth_methods.dart';
import '../../services/firebase_crud_methods.dart';

class DeviceSetup extends StatefulWidget {
  static const String routeName = '/device-setup-setting';

  const DeviceSetup({super.key});

  @override
  State<DeviceSetup> createState() => _DeviceSetupState();
}

class _DeviceSetupState extends State<DeviceSetup> {
  @override
  Widget build(BuildContext context) {
    final user = context.read<FirebaseAuthMethods>().user;

    final currentUser =
    context.read<FirebaseCrudMethods>().getUserFromFirebase(user.uid);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cihaz Kurulumu'),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            FutureBuilder<UserModel?>(
              future: currentUser,
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Text(
                    'Yükleniyor...',
                    style: TextStyle(fontSize: 10),
                  );
                } else if (snapshot.hasError) {
                  return Text(
                      'Error: ${snapshot.error}');
                } else {
                  return Padding(
                    padding:
                    const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        const Row(
                          mainAxisAlignment:
                          MainAxisAlignment
                              .center,
                          children: [
                            Icon(
                              Icons.info,
                              color: Colors.grey,
                            ),
                            SizedBox(
                              width: 20.0,
                            ),
                            Text(
                              'Cihaz ve oturum bilgileri sadece\nfarklı bir cihaz üzerinden oturum\naçıldığında değiştirilebilir.',
                              style: TextStyle(
                                  color: Colors.grey),
                            ),
                          ],
                        ),
                        const Divider(),
                        const SizedBox(
                          height: 30,
                        ),
                        SingleChildScrollView(
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment
                                .center,
                            children: [
                              Column(
                                children: [
                                  const Icon(Icons
                                      .phone_android),
                                  const SizedBox(
                                    height: 10.0,
                                  ),
                                  const Text(
                                    'Kayıtlı Profilim',
                                    style: TextStyle(
                                        fontSize: 15),
                                  ),
                                  Text(
                                      snapshot.data!
                                          .deviceInfo
                                          .toUpperCase(),
                                      style:
                                      const TextStyle(
                                        color: Colors
                                            .grey,
                                      )),
                                  const SizedBox(
                                    height: 40.0,
                                  ),
                                ],
                              ),
                              const SizedBox(width: 50.0),
                              Column(
                                children: [
                                  const Icon(Icons
                                      .tablet_mac_sharp),
                                  const SizedBox(
                                    height: 10.0,
                                  ),
                                  const Text(
                                    'Kayıtlı Çocuk Profili',
                                    style: TextStyle(
                                        fontSize: 15),
                                    textAlign:
                                    TextAlign
                                        .center,
                                  ),
                                  Text(
                                      snapshot.data!
                                          .otherDeviceInfo
                                          .toUpperCase()
                                          .isEmpty
                                          ? 'Kurulum bekleniyor...'
                                          : snapshot
                                          .data!
                                          .otherDeviceInfo
                                          .toUpperCase(),
                                      style:
                                      const TextStyle(
                                        color: Colors
                                            .grey,
                                      )),
                                  const SizedBox(
                                    height: 40.0,
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        const Row(
                          mainAxisAlignment:
                          MainAxisAlignment
                              .center,
                          children: [
                            Icon(
                              Icons.arrow_circle_right,
                              color: Colors.grey,
                            ),
                            SizedBox(
                              width: 20.0,
                            ),
                            Text(
                              'Kurulumları sıfırlamak için\nşimdi profil ayarlarından\noturumunuzu kapatın.',
                              style: TextStyle(
                                  color: Colors.grey),
                            ),
                          ],
                        ),
                        SizedBox(height: 50.0,),
                        SizedBox(
                            height: 80.0,
                            child: CustomButton(text: 'Profil üzerinden oturumu\nkapatın ve yeniden deneyin',onTap: (){
                              Navigator.pushNamed(context, UserAccountPage.routeName);
                            },))

                      ],

                    ),
                  );
                }
              },
            ),
            const SizedBox(
              height: 20.0,
            ),
          ],
        ),
      )
    );
  }
}
