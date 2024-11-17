import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../services/firebase_auth_methods.dart';
import '../pages/signup_email_password_screen.dart';

class LoginScreen extends StatefulWidget {
  static const String routeName = '/login-screen';

  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late int randomNum;
  late Future<String> _versionInfoFuture;
  bool isLoading = false;

  int generateRandomNum() {
    return Random().nextInt(3) + 1;
  }

  @override
  void initState() {
    super.initState();
    randomNum = generateRandomNum();
    _versionInfoFuture = _getVersionInfo();
  }

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
      print('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }

  Future<String> _getVersionInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return 'v ${packageInfo.version}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/kids/$randomNum.png"),
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: ElevatedButton(
                      onPressed: () async {
                        showModalBottomSheet<void>(
                          context: context,
                          builder: (BuildContext context) {
                            return StatefulBuilder(
                              builder: (BuildContext context, StateSetter setState) {
                                return Container(
                                  height: 300,
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,

                                      children: <Widget>[
                                        Text('HOŞ GELDİNİZ\n\nBir giriş yöntemi seçin.',style: TextStyle(color: Colors.grey,fontSize: 15),textAlign: TextAlign.center,),
                                        const SizedBox(height: 50,),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 40),
                                          child: ElevatedButton(
                                            onPressed: () async {

                                              await _requestNotificationPermission(context);
                                              await Navigator.pushNamed(context, EmailPasswordSignup.routeName);

                                            },
                                            style: ButtonStyle(
                                              backgroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  Colors.deepPurple),
                                              shape: MaterialStateProperty.all<
                                                  RoundedRectangleBorder>(
                                                RoundedRectangleBorder(
                                                  borderRadius:
                                                  BorderRadius.circular(10.0),
                                                ),
                                              ),
                                            ),
                                            child:  const Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.email,
                                                  color: Colors.white,
                                                  size: 30,
                                                ),
                                                SizedBox(width: 15.0),
                                                Text(
                                                  'E-Posta ile devam et',
                                                  style: TextStyle(color: Colors.white),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 10.0),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 40),
                                          child: ElevatedButton(
                                            onPressed: () async {
                                              setState(() {
                                                isLoading = true;
                                              });
                                              await context.read<FirebaseAuthMethods>().signInWithGoogle(context);
                                              await _requestNotificationPermission(context);
                                              setState(() {
                                                isLoading = false;
                                              });
                                            },
                                            style: ButtonStyle(
                                              backgroundColor:
                                              MaterialStateProperty.all<Color>(Colors.redAccent),
                                              shape: MaterialStateProperty.all<
                                                  RoundedRectangleBorder>(
                                                RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(10.0),
                                                ),
                                              ),
                                            ),
                                            child: isLoading ? SizedBox(
                                              height: 10,
                                              width: 10,
                                              child: CircularProgressIndicator(
                                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                              ),
                                            ) : const Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment.center,
                                              children: [
                                                FaIcon(
                                                  FontAwesomeIcons.google,
                                                  color: Colors.white,
                                                ),
                                                SizedBox(width: 15.0),
                                                Text(
                                                  'Google hesabı ile devam et',
                                                  style: TextStyle(color: Colors.white),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 10.0),
                                        if(Platform.isIOS)
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 40),
                                            child: ElevatedButton(
                                              onPressed: () async {
                                                setState(() {
                                                  isLoading = true;
                                                });
                                                await context.read<FirebaseAuthMethods>().signInWithApple(context);
                                                await _requestNotificationPermission(context);
                                                setState(() {
                                                  isLoading = false;
                                                });
                                              },
                                              style: ButtonStyle(
                                                backgroundColor:
                                                MaterialStateProperty.all<Color>(Colors.black),
                                                shape: MaterialStateProperty.all<
                                                    RoundedRectangleBorder>(
                                                  RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(10.0),
                                                  ),
                                                ),
                                              ),
                                              child: isLoading ? SizedBox(
                                                height: 10,
                                                width: 10,
                                                child: CircularProgressIndicator(
                                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                ),
                                              ) : const Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment.center,
                                                children: [
                                                  FaIcon(
                                                    FontAwesomeIcons.apple,
                                                    color: Colors.white,
                                                  ),
                                                  SizedBox(width: 15.0),
                                                  Text(
                                                    'Apple Kimliği ile devam et',
                                                    style: TextStyle(color: Colors.white),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        SizedBox(height: 25,),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                      style: ButtonStyle(
                        backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.deepPurple),
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Merhaba',
                            style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 18),
                          ),
                          SizedBox(width: 15.0),
                          Icon(
                            Icons.arrow_circle_right_outlined,
                            color: Colors.white,
                            size: 30,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft:  Radius.circular(10.0),
                        topRight:  Radius.circular(10.0),
                        bottomLeft: Radius.zero,
                        bottomRight: Radius.zero,
                      ),
                    ),
                    child: FutureBuilder<String>(
                      future: _versionInfoFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return const Text('Versiyon bilgisi alınamadı');
                        } else {
                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 20,left: 20,top: 6,bottom: 2),
                                child: Opacity(opacity: 0.5,
                                    child: Image.asset('assets/images/ic/e.png',height: 15,)),
                              ),
                              Text(
                                  snapshot.data ?? 'Versiyon bilgisi mevcut değil'),
                            ],

                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),

            if (isLoading)
              Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }
}

