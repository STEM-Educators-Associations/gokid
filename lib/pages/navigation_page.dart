import 'dart:async';
import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gokid/pages/child_mode/child_mode_home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/user_model.dart';
import '../services/firebase_auth_methods.dart';
import '../services/firebase_crud_methods.dart';
import 'blog/blog_page_main.dart';
import 'home_page.dart';
import 'dart:io';

class NavigationPage extends StatefulWidget {
  static const String routeName = '/navigation';

  NavigationPage({Key? key, required this.currentIndex}) : super(key: key);
  int currentIndex = 0;
  static const navigation = <NavigationDestination>[
    NavigationDestination(
      selectedIcon: Icon(Icons.image),
      icon: Icon(Icons.home_outlined),
      label: 'Koleksiyonlar',
    ),
    NavigationDestination(
      selectedIcon: Icon(Icons.textsms),
      icon: Icon(Icons.sms_outlined),
      label: 'Blog Yazıları',
    ),
  ];

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  int drawerIndex = 0;
  bool light = false;
  bool initMode = false;

  final page = [const HomeScreen(), const BlogPage()];

  @override
  void initState() {
    super.initState();
    _checkNavigation();
  }

  Future<void> _checkNavigation() async {
    final prefs = await SharedPreferences.getInstance();

    final String? mode = prefs.getString('mode');

    if (mode=="child_mode") {
      Navigator.of(context).pushReplacementNamed(ChildLockScreen.routeName);
    } else {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<FirebaseAuthMethods>().user;
    final currentUser =
        context.read<FirebaseCrudMethods>().getUserFromFirebase(user.uid);
    final checkValidity =
        context.read<FirebaseCrudMethods>().checkTokenValidity(user.uid);

    final otherDeviceTokenForMenu = context
        .read<FirebaseCrudMethods>()
        .getOtherDeviceTokenForMenu(user.uid);


    return Scaffold(
      appBar: AppBar(
        title: Text(NavigationPage.navigation[widget.currentIndex].label),

      ),
      drawer: NavigationDrawer(
        selectedIndex: drawerIndex,
        onDestinationSelected: (int drawerI) {
          setState(() {
            drawerIndex = drawerI;
            if (drawerI == 0) {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => NavigationPage(currentIndex: 0)),
              );
            } else if (drawerIndex == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => NavigationPage(currentIndex: 1)),
              );
            } else if (drawerIndex == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => NavigationPage(currentIndex: 2)),
              );
            } else if (drawerIndex == 3) {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => NavigationPage(currentIndex: 3)),
              );
            } else {}
          });
        },
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.deepPurple[100],
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Column(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  Center(
                      child: initMode
                          ? const Text(
                              'Çocuk Modu Aktif',
                              style: TextStyle(fontSize: 20),
                            )
                          : const Text('Çocuk Modu Kapalı')),
                  Divider(
                    color: Colors.grey[200],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Transform.scale(
                    scale: 1.7,
                    child: Switch(
                      value: light,
                      onChanged: (bool value1) {
                        setState(() {
                          light = value1;
                          if (initMode) {
                            initMode = false;
                          } else {
                            initMode = true;
                          }

                          Timer(const Duration(seconds: 1), () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const ChildLockScreen(
                                  isThis: true,
                                ),
                              ),
                            );
                          });
                        });
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Card(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        badges.Badge(
                          position:
                              badges.BadgePosition.topStart(start: -10, top: -30),
                          ignorePointer: true,
                          badgeAnimation: const badges.BadgeAnimation.fade(
                            animationDuration: Duration(milliseconds: 700),
                            colorChangeAnimationDuration: Duration(seconds: 1),
                            loopAnimation: true,
                          ),
                          badgeStyle: badges.BadgeStyle(
                            badgeColor: Colors.indigo,
                            padding: const EdgeInsets.all(2),
                            borderRadius: BorderRadius.circular(4),
                            elevation: 0,
                          ),
                        ),
                        const Icon(
                          Icons.phone_android,
                          color: Colors.grey,
                        ),
                        FutureBuilder<bool>(
                          future: checkValidity,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Text(
                                'yükleniyor ...',
                                style: TextStyle(fontSize: 10),
                              );
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else {
                              return Text(
                                  snapshot.data!
                                      ? '  Ebeveyn Cihazı '
                                      : 'Cihaz tanımlanamadı.\nLütfen ayarlarınızı gözden geçirin.',
                                  style: const TextStyle(
                                    color: Colors.deepPurple,
                                  ));
                            }
                          },
                        ),
                        IconButton(
                            onPressed: () {
                              showModalBottomSheet<void>(
                                context: context,
                                builder: (BuildContext context) {
                                  return SingleChildScrollView(
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
                                  );
                                },
                              );
                            },
                            icon: const Icon(
                              Icons.info_outline,
                              color: Colors.indigo,
                              size: 30,
                            ))
                      ],
                    ),
                  ),
                  FutureBuilder<UserModel?>(
                    future: currentUser,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Text(
                          ' ',
                          style: TextStyle(fontSize: 10),
                        );
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        return Text(snapshot.data!.deviceInfo.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.grey,
                            ));
                      }
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Divider(
                    color: Colors.white,
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  FutureBuilder<bool?>(
                    future: otherDeviceTokenForMenu,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        return snapshot.data!
                            ? const Text(
                                'Diğer cihaz kurulumu tamamlandı.',
                                style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: Colors.green,
                                ),
                              )
                            : const Text(
                                'Diğer cihaz kurulumu bekleniyor...',
                                style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: Colors.red,
                                ),
                              );
                      }
                    },
                  ),
                  IconButton(
                      onPressed: () {
                        setState(() {});
                      },
                      icon: const Icon(Icons.refresh_rounded)),
                  const SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10.0),

                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: ListTile(
                      title: const Text('Kullanıcı Profili'),
                      leading: const Icon(Icons.account_box_rounded),
                      onTap: () {
                        Navigator.pushNamed(context, '/user-account-page');
                      },
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10.0,
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: ListTile(
                    title: const Text('Yardım Merkezi'),
                    leading: const Icon(Icons.live_help_rounded),
                    onTap: () {
                      Navigator.pushNamed(context, '/help-center');
                    },
                  ),
                ),
                // SizedBox(
                //   height: 10.0,
                // ),
                // Container(
                //   decoration: BoxDecoration(
                //     color: Colors.grey[200],
                //     borderRadius: BorderRadius.circular(10.0),
                //   ),
                //   child: ListTile(
                //     title: const Text('Uzmana Sor'),
                //     leading: const Icon(Icons.question_answer_outlined),
                //     onTap: () {
                //       Navigator.pushNamed(context, '/ask-q');
                //
                //     },
                //   ),
                // ),
                const SizedBox(
                  height: 10.0,
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: ListTile(
                    title: const Text('Ayarlar'),
                    leading: const Icon(Icons.settings),
                    onTap: () {
                      Navigator.pushNamed(context, '/settings-main-screen');
                    },
                  ),
                ),
                const SizedBox(
                  height: 10.0,
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: ListTile(
                    title: const Text('Bağış Yap'),
                    leading: const Icon(Icons.volunteer_activism),
                    onTap: () {
                      Navigator.pushNamed(context, '/donation');
                    },
                  ),
                ),
                const SizedBox(
                  height: 10.0,
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: ListTile(
                    title: const Text('Uygulama Hakkında'),
                    leading: const Icon(Icons.info_outline),
                    onTap: () {
                      Navigator.pushNamed(context, '/about-app');
                    },
                  ),
                ),
                const SizedBox(
                  height: 20.0,
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.purple, Colors.greenAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: ListTile(
                    title: const Text(
                      'Bizi Değerlendirin',
                      style: TextStyle(color: Colors.white),
                    ),
                    leading: const Icon(
                      Icons.star,
                      color: Colors.white,
                    ),
                    onTap: () {
                      if (Platform.isAndroid) {
                        launchUrl(Uri.parse(
                            'https://play.google.com/store/apps/dev?id=6038725709925103359'));
                      } else if (Platform.isIOS) {
                        launchUrl(Uri.parse(
                            'https://apps.apple.com/us/app/gokid/id6654923599'));
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 200,
          ),
        ],
      ),
      body: page[widget.currentIndex],
      bottomNavigationBar: NavigationBar(
        animationDuration: const Duration(seconds: 1),
        selectedIndex: widget.currentIndex,
        elevation: 0,
        onDestinationSelected: (int index) {
          setState(() {
            widget.currentIndex = index;
          });

          //co.updateIndex(index);
        },
        destinations: NavigationPage.navigation,
      ),
    );
  }
}
