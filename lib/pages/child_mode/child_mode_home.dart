import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gokid/models/image_model.dart';
import 'package:gokid/notification/request_notif_permission_screen.dart';
import 'package:gokid/pages/navigation_page.dart';
import 'package:gokid/pages/notification/notif_utils.dart';
import 'package:gokid/services/firebase_crud_methods.dart';
import 'package:gokid/services/local_methods.dart';
import 'package:gokid/utils/showSnackbar.dart';
import 'package:gokid/widgets/custom_button.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:vibration/vibration.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../services/firebase_auth_methods.dart';

class ChildLockScreen extends StatefulWidget {
  final bool isThis;
  static const String routeName = '/child-mode';

  const ChildLockScreen({Key? key, required this.isThis}) : super(key: key);

  @override
  State<ChildLockScreen> createState() => _ChildLockScreenState();
}

class _ChildLockScreenState extends State<ChildLockScreen> {
  final FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    WakelockPlus.enable();
    _initAsync();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    WakelockPlus.disable();
    super.dispose();
  }

  void _initAsync() async {
    await _checkNotificationPermission();
  }
  Future<void> _speak(String text) async {
    await flutterTts.setLanguage("tr-TR");
    await flutterTts.setPitch(1);
    await flutterTts.setVolume(1);
    await flutterTts.speak(text);
  }
  Future<void> _checkNotificationPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.getNotificationSettings();
    if (settings.authorizationStatus == AuthorizationStatus.notDetermined) {
      showSnackBar(context, 'Bildirim izni henüz verilmemiş.');
      Navigator.pushNamedAndRemoveUntil(    context,
        RequestNotifPermissionScreen.routeName,
            (route) => false,
           );
    } else if (settings.authorizationStatus == AuthorizationStatus.denied) {
      Navigator.pushNamedAndRemoveUntil(    context,
        RequestNotifPermissionScreen.routeName,
            (route) => false,
           );
      showSnackBar(context, 'Lütfen ayarlardan bildirim izinlerini açın.');
    } else if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print("İzin verildi");
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      showSnackBar(context, 'Geçici bildirim izni verildi.');
    }
  }


  @override
  Widget build(BuildContext context) {


    final user = context.read<FirebaseAuthMethods>().user;
    final device = context.read<LocalMethods>().getDeviceInfo();

    return Scaffold(
      floatingActionButton: Visibility(
        visible: widget.isThis,
        child: SizedBox(
          height: 50.0,
          child: GestureDetector(
            onLongPress: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Çocuk Modundan Çıkın'),
                    content: const Text(
                        'Çocuk modundan çıkmak için asma kilidi sonuna kadar kaydırın.\n\nÇocuk modu kapatıldığında oturum sonlandırılacaktır.'),
                    actions: <Widget>[
                      Builder(
                        builder: (context) {
                          final GlobalKey<SlideActionState> _key = GlobalKey();
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SlideAction(
                              key: _key,
                              text: 'Kaydır...',
                              sliderButtonIcon: const Icon(Icons.lock),
                              onSubmit: () async {
                                Future<String?> deviceInfo = device;
                                if (deviceInfo == 'childMode') {
                                  await context
                                      .read<FirebaseAuthMethods>()
                                      .signOut(context);
                                  if (!context.mounted) return;
                                  await Navigator.of(context)
                                      .pushNamedAndRemoveUntil(
                                    '/login-email-password',
                                        (route) => false,
                                  );
                                } else {
                                  SystemChrome.setEnabledSystemUIMode(
                                      SystemUiMode.edgeToEdge);

                                  Future.delayed(
                                    const Duration(seconds: 2),
                                        () => _key.currentState!.reset(),
                                  );
                                  Navigator.pushReplacementNamed(
                                      context, '/navigation');

                                  showSnackBar(context, 'Çocuk Modu kapatıldı.');
                                }
                              },
                            ),
                          );
                        },
                      ),
                      TextButton(
                        onPressed: () async {
                         Navigator.pop(context);
                        },
                        child: const Text('İptal'),
                      ),
                    ],
                  );
                },
              );
            },
            child: FloatingActionButton.extended(
              onPressed: () {
                showSnackBar(context, 'Çıkmak için butona biraz basılı tutun.');
              },
              icon: const Icon(Icons.exit_to_app),
              label: const Text(
                'Çocuk Modundan Çıkın',
                style: TextStyle(fontSize: 15),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },
          child: FutureBuilder<List<ImageModel>>(
            future: context
                .read<FirebaseCrudMethods>()
                .getPicturesFromChildrenCollections(user.uid),
            builder: (BuildContext context,
                AsyncSnapshot<List<ImageModel>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 80,
                          width: 80,
                          child: CircularProgressIndicator(
                            strokeWidth: 6,
                            color: Colors.deepPurpleAccent,
                          ),
                        ),
                        SizedBox(
                          height: 15.0,
                        ),
                        Text(
                          'Görseller Yükleniyor...',
                          style: TextStyle(fontSize: 20),
                        )
                      ]),
                );
              } else if (snapshot.hasData) {
                if (snapshot.data!.isEmpty) {
                  return ListView(
                    children: [
                      const SizedBox(
                        height: 50,
                      ),
                      SizedBox(
                          height: 300,
                          child: Image.asset(
                              'assets/images/ic/error_cat_ic.png',
                              height: 300)),
                      const SizedBox(height: 10.0),
                      const Text(
                        "Ebeveynin görsel eklemesi bekleniyor ...",
                        style: TextStyle(fontSize: 20),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 50.0),
                      CustomButton(
                          onTap: () {
                            setState(() {});
                          },
                          text: 'Yenile')
                    ],
                  );
                } else {
                  return GridView.builder(
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 1.0,
                      crossAxisSpacing: 1.0,
                    ),
                    itemBuilder: (BuildContext context, int index) {
                      List<ImageModel> filteredImages = snapshot.data!.where((imageModel) => imageModel.isEnabled).toList();

                      ImageModel imageModel = filteredImages[index];

                      return GestureDetector(
                        onTap: () async {
                          final currentDeviceToken = await context
                              .read<FirebaseCrudMethods>()
                              .getUserToken(user.uid);
                          print(currentDeviceToken);

                          final userChild = await context.read<FirebaseCrudMethods>().getChildrenByUserId(imageModel.userId);

                          NotifUtils().sendNotification(
                              currentDeviceToken,
                              imageModel.imageName,
                              '${userChild[0].childName} , "${imageModel.imageName}" isimli görsele tıkladı.');
                          Vibration.vibrate(duration: 500);
                          _speak(imageModel.imageName);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Card(
                            child: Image.network(
                              imageModel.imageURL,
                            ),
                          ),
                        ),
                      );
                    },
                    itemCount: snapshot.data!.where((imageModel) => imageModel.isEnabled).length,
                  );
                }
              } else {
                return const Text(
                    'Bir şeyler ters gitti :( \nLütfen daha sonra tekrar deneyin.');
              }
            },
          ),
        ),
      ),
      bottomNavigationBar: const Visibility(
        child: Opacity(
          opacity: 0.5,
          child: BottomAppBar(
            height: 150,
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.screen_lock_portrait,size: 40,),
                  SizedBox(width: 10.0,),
                  Text(
                    "Bu ekran siz uygulamayı \nkapatıncaya kadar açık kalacaktır.",

                    style: TextStyle(fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
